#!/bin/bash
# ================================================
# Debian 13 Base Server Setup
# Node.js + pm2 + PostgreSQL + pgAdmin4 + nginx + unzip
# ================================================

set -e  # Bei Fehler abbrechen

echo "======================================================"
echo "🚀 Debian 13 Base Server Setup"
echo "======================================================"
echo ""

# Root-Check
if [ "$EUID" -ne 0 ]; then
  echo "❌ Bitte als root ausführen: sudo bash $0"
  exit 1
fi

# System aktualisieren
echo "📦 System wird aktualisiert..."
apt-get update -y
apt-get upgrade -y
echo ""

# Vollinstallation oder Custom?
read -p "Alles auf einmal installieren? (y/n – empfohlen bei fresh install): " FULL_INSTALL

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

# ================================================
# unzip
# ================================================
if [[ $INSTALL_UNZIP == "y" || $INSTALL_UNZIP == "Y" ]]; then
  echo "📦 unzip wird installiert..."
  apt-get install -y --reinstall unzip
  echo "✅ unzip fertig"
fi

# ================================================
# Node.js + pm2 (Reinstall möglich)
# ================================================
if [[ $INSTALL_NODE == "y" || $INSTALL_NODE == "Y" ]]; then
  echo "📦 Node.js LTS + pm2 wird (neu) installiert..."

  # Alte Versionen entfernen
  npm uninstall -g pm2 2>/dev/null || true
  apt-get remove --purge -y nodejs 2>/dev/null || true
  rm -rf /usr/local/bin/node /usr/local/bin/npm /opt/nodejs 2>/dev/null || true

  # Frische Installation
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt-get install -y nodejs
  npm install -g pm2

  echo "✅ Node.js $(node -v) + pm2 installiert"
fi

# ================================================
# PostgreSQL + pgAdmin4 (Datenbanken werden geschützt!)
# ================================================
if [[ $INSTALL_POSTGRES == "y" || $INSTALL_POSTGRES == "Y" ]]; then
  echo "📦 PostgreSQL + pgAdmin4 wird installiert..."

  apt-get install -y postgresql postgresql-contrib
  systemctl enable --now postgresql

  # pgAdmin4
  apt-get install -y curl ca-certificates gnupg lsb-release
  curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

  echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
    | tee /etc/apt/sources.list.d/pgadmin4.list > /dev/null

  apt-get update
  apt-get install -y pgadmin4-web

  echo "✅ PostgreSQL + pgAdmin4 installiert"
  echo "   → Web-Setup später starten mit:"
  echo "     sudo /usr/pgadmin4/bin/setup-web.sh"
fi

# ================================================
# nginx (saubere Reinstall)
# ================================================
if [[ $INSTALL_NGINX == "y" || $INSTALL_NGINX == "Y" ]]; then
  echo "📦 nginx wird sauber (neu) installiert..."

  # Alte Reste komplett entfernen
  systemctl stop nginx 2>/dev/null || true
  apt-get remove --purge -y nginx nginx-common nginx-full nginx-core 2>/dev/null || true
  rm -rf /etc/nginx /var/www/html

  apt-get update
  apt-get install -y nginx

  systemctl enable --now nginx
  echo "✅ nginx installiert und gestartet"
  echo "   Web-Ordner:    /var/www/html"
  echo "   Konfig-Ordner: /etc/nginx/"
fi


# ================================================
# Fertig
# ================================================
echo ""
echo "======================================================"
echo "🎉 Debian 13 Base Server Setup ABGESCHLOSSEN!"
echo "======================================================"
echo ""
echo "Nützliche Befehle:"
echo "  systemctl status postgresql"
echo "  systemctl status nginx"
echo "  pm2 list"
echo "  sudo -u postgres psql"
echo ""
echo "Viel Erfolg mit deinem Server!"
