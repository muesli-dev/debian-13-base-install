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
 
