# debian-13-base-install
 
Automatisches Setup-Script für einen Debian 13 (Trixie) Server auf Hetzner.
 
## Was wird installiert?
 
- **Node.js LTS** + pm2
- **PostgreSQL** + pgAdmin4
- **nginx**
- **unzip**
- **OpenVPN** (via angristan/openvpn-install)
 
## Verwendung
 
```bash
curl -sSL https://raw.githubusercontent.com/muesli-dev/debian-13-base-install/refs/heads/main/install.sh | sudo bash
```
 
## Hinweise
 
- Nur für **Debian 13 (Trixie)** getestet
- Muss als **root** ausgeführt werden
- pgAdmin4 Web-Setup nach Installation manuell starten:
  ```bash
  sudo /usr/pgadmin4/bin/setup-web.sh
  ```
 
