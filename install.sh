#!/bin/bash
# ================================================
# FSW Server Setup Script – Debian 13 (Hetzner)
# Node.js + pm2 + PostgreSQL + pgAdmin + nginx + unzip + OpenVPN
# ================================================

set -e  # Bei Fehler abbrechen

echo "======================================================"
echo "🚀 FSW Server Setup Script für Debian 13 (Hetzner)"
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
  apt-get install -y unzip
  echo "✅ unzip fertig"
fi

# ================================================
# Node.js + pm2
# ================================================
if [[ $INSTALL_NODE == "y" || $INSTALL_NODE == "Y" ]]; then
  echo "📦 Node.js LTS + pm2 wird installiert..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt-get install -y nodejs
  npm install -g pm2
  echo "✅ Node.js $(node -v) + pm2 installiert"
fi

# ================================================
# PostgreSQL + pgAdmin4
# ================================================
if [[ $INSTALL_POSTGRES == "y" || $INSTALL_POSTGRES == "Y" ]]; then
  echo "📦 PostgreSQL + pgAdmin4 wird installiert..."

  # PostgreSQL
  apt-get install -y postgresql postgresql-contrib
  systemctl enable --now postgresql

  # pgAdmin4 – Debian 13 (trixie) noch nicht offiziell unterstützt,
  # daher Fallback auf bookworm-Repo bis pgAdmin4 trixie bereitstellt
  apt-get install -y curl ca-certificates lsb-release gnupg

  DIST=$(lsb_release -cs)
  if [[ "$DIST" == "trixie" || "$DIST" == "forky" ]]; then
    echo "⚠️  pgAdmin4 hat noch kein Repo für '$DIST' – Fallback auf 'bookworm'"
    PGADMIN_DIST="bookworm"
  else
    PGADMIN_DIST="$DIST"
  fi

  curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub \
    | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

  echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] \
https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/${PGADMIN_DIST} pgadmin4 main" \
    | tee /etc/apt/sources.list.d/pgadmin4.list > /dev/null

  # set -e kurz deaktivieren – falls Repo doch Probleme macht, nicht alles abbrechen
  set +e
  apt-get update 2>&1 | grep -v "^W:"
  PGADMIN_UPDATE_OK=$?
  set -e

  if [ $PGADMIN_UPDATE_OK -ne 0 ]; then
    echo "❌ pgAdmin4-Repo konnte nicht geladen werden. pgAdmin4 wird übersprungen."
    echo "   PostgreSQL ist trotzdem installiert und läuft."
  else
    apt-get install -y pgadmin4-web
    echo "✅ PostgreSQL + pgAdmin4 installiert"
    echo "   → Web-Setup später manuell starten mit:"
    echo "     sudo /usr/pgadmin4/bin/setup-web.sh"
  fi
fi

# ================================================
# nginx
# ================================================
if [[ $INSTALL_NGINX == "y" || $INSTALL_NGINX == "Y" ]]; then
  echo "📦 nginx wird installiert..."
  apt-get install -y nginx
  systemctl enable --now nginx
  echo "✅ nginx installiert und gestartet"
fi

# ================================================
# OpenVPN (originales Script – immer aktuell)
# ================================================
if [[ $INSTALL_OPENVPN == "y" || $INSTALL_OPENVPN == "Y" ]]; then
  echo "🔐 OpenVPN Installer wird gestartet (original von angristan)..."
  curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
  chmod +x openvpn-install.sh
  ./openvpn-install.sh
fi

# ================================================
# Fertig
# ================================================
echo ""
echo "======================================================"
echo "🎉 FSW Server Setup ABGESCHLOSSEN!"
echo "======================================================"
echo ""
echo "Nützliche Befehle:"
echo "  systemctl status postgresql"
echo "  systemctl status nginx"
echo "  pm2 list"
echo "  sudo -u postgres psql"
echo ""
echo "Viel Spaß mit deinem FSW Prod / Dev Server! 🦌"
echo "Bei Fragen einfach fragen – ich helfe sofort weiter."
