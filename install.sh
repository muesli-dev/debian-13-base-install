#!/bin/bash
# ================================================
# Debian 13 Base Server Setup
# Node.js + pm2 + PostgreSQL + pgAdmin4 + nginx + unzip
# ================================================

set -e

echo "======================================================"
echo "🚀 Debian 13 Base Server Setup"
echo "======================================================"
echo ""

if [ "$EUID" -ne 0 ]; then
  echo "❌ Bitte als root ausführen: sudo bash $0"
  exit 1
fi

echo "📦 System wird aktualisiert..."
apt-get update -y
apt-get upgrade -y
echo ""

read -p "Alles auf einmal installieren? (y/n): " FULL_INSTALL

if [[ $FULL_INSTALL == "y" || $FULL_INSTALL == "Y" ]]; then
  INSTALL_NODE="y"
  INSTALL_POSTGRES="y"
  INSTALL_NGINX="y"
  INSTALL_UNZIP="y"
  INSTALL_OPENVPN="y"
else
  echo ""
  read -p "Node.js + pm2 installieren? (y/n): " INSTALL_NODE
  read -p "PostgreSQL + pgAdmin4 installieren? (y/n): " INSTALL_POSTGRES
  read -p "nginx installieren? (y/n): " INSTALL_NGINX
  read -p "unzip installieren? (y/n): " INSTALL_UNZIP
  read -p "OpenVPN Server installieren? (y/n): " INSTALL_OPENVPN
fi
echo ""

# unzip
if [[ $INSTALL_UNZIP == "y" || $INSTALL_UNZIP == "Y" ]]; then
  echo "📦 unzip wird installiert..."
  apt-get install -y --reinstall unzip
  echo "✅ unzip fertig"
fi

# Node.js + pm2
if [[ $INSTALL_NODE == "y" || $INSTALL_NODE == "Y" ]]; then
  echo "📦 Node.js LTS + pm2 wird (neu) installiert..."
  npm uninstall -g pm2 2>/dev/null || true
  apt-get remove --purge -y nodejs 2>/dev/null || true
  rm -rf /usr/local/bin/node /usr/local/bin/npm /opt/nodejs 2>/dev/null || true

  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt-get install -y nodejs
  npm install -g pm2
  echo "✅ Node.js $(node -v) + pm2 installiert"
fi

# PostgreSQL + pgAdmin4 (Datenbanken bleiben erhalten!)
if [[ $INSTALL_POSTGRES == "y" || $INSTALL_POSTGRES == "Y" ]]; then
  echo "📦 PostgreSQL + pgAdmin4 wird installiert..."
  apt-get install -y postgresql postgresql-contrib
  systemctl enable --now postgresql

  apt-get install -y curl ca-certificates gnupg lsb-release
  curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

  echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
    | tee /etc/apt/sources.list.d/pgadmin4.list > /dev/null

  apt-get update
  apt-get install -y pgadmin4-web

  echo "✅ PostgreSQL + pgAdmin4 installiert"
  echo "   → Web-Setup später starten mit: sudo /usr/pgadmin4/bin/setup-web.sh"
fi

# nginx (saubere Reinstall)
if [[ $INSTALL_NGINX == "y" || $INSTALL_NGINX == "Y" ]]; then
  echo "📦 nginx wird sauber (neu) installiert..."

  # Was belegt Port 80?
  PORT80_PID=$(ss -tlnp | grep ':80' | grep -oP 'pid=\K[0-9]+' | head -1)
  if [[ -n "$PORT80_PID" ]]; then
    echo "⚠️  Port 80 belegt von PID $PORT80_PID – wird beendet..."
    kill -9 "$PORT80_PID" 2>/dev/null || true
  fi

  # Apache entfernen falls vorhanden
  systemctl stop apache2 2>/dev/null || true
  apt-get remove --purge -y apache2 apache2-bin apache2-data 2>/dev/null || true

  # Alte nginx Reste entfernen
  systemctl stop nginx 2>/dev/null || true
  apt-get remove --purge -y nginx nginx-common nginx-full nginx-core 2>/dev/null || true
  rm -rf /etc/nginx /var/www/html

  apt-get update
  apt-get install -y nginx

  set +e
  systemctl enable --now nginx
  NGINX_STATUS=$?
  set -e

  if [ $NGINX_STATUS -eq 0 ]; then
    echo "✅ nginx installiert und gestartet"
  else
    echo "⚠️  nginx installiert aber Start fehlgeschlagen."
    echo "   Prüfe mit: journalctl -xeu nginx.service"
  fi

  echo "   Web-Ordner:    /var/www/html"
  echo "   Konfig-Ordner: /etc/nginx/"
fi

# OpenVPN
if [[ $INSTALL_OPENVPN == "y" || $INSTALL_OPENVPN == "Y" ]]; then
  echo "🔐 OpenVPN Installer wird gestartet..."
  curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
  chmod +x openvpn-install.sh
  ./openvpn-install.sh interactive
fi

echo ""
echo "======================================================"
echo "🎉 Setup ABGESCHLOSSEN!"
echo "======================================================"
echo "Viel Erfolg mit deinem Server!"
