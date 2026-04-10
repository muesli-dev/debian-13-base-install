# debian-13-base-install

Automatic setup script for a Debian 13 (Trixie) server on Hetzner.

## What is installed?

- **Node.js LTS** + pm2
- **PostgreSQL** + pgAdmin4
- **nginx**
- **unzip**

## Usage

```bash
curl -sSL https://raw.githubusercontent.com/muesli-dev/debian-13-base-install/refs/heads/main/install.sh | sudo bash
```

### OpenVPN Install Script and Changes

- **Install and Read Inscrutions from this Repo:**
  https://github.com/angristan/openvpn-install
  
- **If Server should not route internet - remove any of these:**
```
push "dhcp-option DNS ......."
```

- **Example server.conf**
```
port 1194
proto udp
dev tun
user nobody
group nogroup
persist-key
persist-tun
keepalive 10 120
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "route 10.8.0.0 255.255.255.0"
push "route 10.8.0.1 255.255.255.255"
dh none
ecdh-curve prime256v1
tls-crypt tls-crypt.key
crl-verify crl.pem
ca ca.crt
cert server_XXXXX.crt
key server_XXXXX.key
auth SHA256
cipher AES-128-GCM
ncp-ciphers AES-128-GCM
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
client-config-dir /etc/openvpn/ccd
status /var/log/openvpn/status.log
verb 3


```

## Notes
 
- tested on **Debian 13 (Trixie)**
- **root** is a must
- pgAdmin4 Web-Setup start:
  ```bash
  sudo /usr/pgadmin4/bin/setup-web.sh
  ```



  # PostgreSQL + pgAdmin Fix Summary (VPN + Remote Access)

## 1. PostgreSQL User Passwort setzen

```bash
sudo -u postgres psql
ALTER USER postgres PASSWORD 'DEIN_PASSWORT';
\q
```

---

## 2. PostgreSQL für Netzwerkzugriff aktivieren

Datei:
`/etc/postgresql/*/main/postgresql.conf`

```conf
listen_addresses = '*'
```

---

## 3. VPN Zugriff erlauben

Datei:
`/etc/postgresql/*/main/pg_hba.conf`

```conf
host    all     all     10.8.0.0/24     scram-sha-256
```

---

## 4. PostgreSQL neu starten

```bash
sudo systemctl restart postgresql
```

---

## 5. Firewall (falls aktiv)

```bash
sudo ufw allow from 10.8.0.0/24 to any port 5432
```

---

## 6. pgAdmin Verbindung

- Host: 10.8.0.1
- Port: 5432
- User: postgres
- Password: (wie gesetzt in Schritt 1)

---

## Ergebnis

- Zugriff über VPN funktioniert
- pgAdmin kann remote verbinden
- vorheriger localhost-only Zugriff ist deaktiviert

 
