# Tsuzuri Deployment Guide (Kamal)

## Prerequisites

- Docker installed on your local machine
- SSH access to your deployment server
- Domain DNS configured (A record pointing to server IP)

## Initial Setup

### 0. Prepare the server (Ubuntu)

Run the following on the deployment server:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y docker.io curl git
sudo usermod -a -G docker <Server Username>
```

After `usermod`, re-login as that user (or run `newgrp docker`) before deploying.

### 1. Configure `.env`

Copy `.env.sample` to create your `.env` file and set the values for your environment:

```bash
cp .env.sample .env
```

```bash
SERVER_IP=203.0.113.1          # Your deployment server's IP address
SERVER_USERNAME=ubuntu         # SSH username
SERVER_SSH_PORT=22             # SSH port
TSUZURI_BASE_URL=https://your-domain.example
TSUZURI_DOMAIN=your-domain.example
TSUZURI_USERNAME=your-username
TSUZURI_EMAIL=admin@example.com
TSUZURI_PASSWORD=change-me
TSUZURI_SOURCE_URL=https://github.com/S-H-GAMELINKS/tsuzuri
```

`config/deploy.yml` is an ERB template that automatically picks up values from `.env`, so you generally don't need to edit it directly.

`TSUZURI_SOURCE_URL` is used for the source code link (AGPL compliance). If you fork the project, change this to your repository URL.

`TSUZURI_EMAIL` / `TSUZURI_PASSWORD` are used for the initial seed account during first `db:prepare` (seeding is skipped if an account already exists).

### 2. Generate production credentials

Generate `config/credentials/production.yml.enc` and `config/credentials/production.key`:

```bash
RAILS_ENV=production bin/rails credentials:edit
```

When you close the editor, Rails creates (or updates) both files.

### 3. Configure `.kamal/secrets`

```bash
RAILS_MASTER_KEY=$(cat config/credentials/production.key)
```

Only `RAILS_MASTER_KEY` is needed. No registry password is required when using the local registry.

Do not commit `config/credentials/production.key` to git.

### 4. About the Registry

The default `registry.server: localhost:5555` works as-is. Kamal automatically runs a local registry on the deployment server, so no external registry account or token is required.

> **Using a remote registry (optional)**
>
> If you prefer to use ghcr.io, Docker Hub, or another remote registry, update the `registry` section in `config/deploy.yml` as follows and add `KAMAL_REGISTRY_PASSWORD` to `.kamal/secrets`:
>
> ```yaml
> registry:
>   server: ghcr.io
>   username: your-user
>   password:
>     - KAMAL_REGISTRY_PASSWORD
> ```

## Deploy

### First Deployment

```bash
bin/kamal setup
```

This installs Docker on the server, starts the local registry, builds and pushes the container image, and initializes the server.

### Subsequent Deployments

```bash
bin/kamal deploy
```

## Useful Commands

Defined in the `aliases` section of `config/deploy.yml`:

```bash
# Rails console
bin/kamal console

# Server shell
bin/kamal shell

# Logs
bin/kamal logs

# Database console
bin/kamal dbc
```

## Database

Tsuzuri uses SQLite3. The database files are stored in a Docker volume:

```yaml
volumes:
  - "tsuzuri_storage:/rails/storage"
```

SQLite3 database files, Solid Queue data, etc. are stored under `/rails/storage`.

### Backups

It is recommended to back up the Docker volume on the server:

```bash
# Find volume location
docker volume inspect tsuzuri_storage

# Backup example
sudo cp -r /var/lib/docker/volumes/tsuzuri_storage/_data /path/to/backup/
```

## Troubleshooting

### Container fails to start

```bash
bin/kamal app logs
```

Check the logs. A missing `RAILS_MASTER_KEY` is the most common cause.

### Database migration errors

```bash
bin/kamal app exec "bin/rails db:migrate"
```

### SSL certificate not obtained

- Verify DNS A record points to the correct server IP
- Verify ports 80/443 are open in the firewall

### Assets return 404

A redeployment usually resolves this:

```bash
bin/kamal deploy
```
