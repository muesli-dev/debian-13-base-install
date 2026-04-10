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

## Notes
 
- tested on **Debian 13 (Trixie)**
- **root** is a must
- pgAdmin4 Web-Setup start:
  ```bash
  sudo /usr/pgadmin4/bin/setup-web.sh
  ```
 
