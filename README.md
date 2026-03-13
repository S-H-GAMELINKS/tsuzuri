# Tsuzuri

Tsuzuri (綴り) is a single-user ActivityPub blog engine. Write posts and distribute them across the Fediverse.

## Features

- Single-user blog with ActivityPub federation
- Publish plaintext posts that are delivered to Fediverse followers
- Accept Follow / Undo(Follow) from remote instances
- HTTP Signature verification (Cavage / RSA-SHA256)
- WebFinger discovery
- Self-destruct mechanism for clean server shutdown
- Admin dashboard for managing posts, followers, and settings
- PWA support for offline access

## Tech Stack

- Ruby 4.0 / Rails 8.1
- SQLite3
- Solid Queue (background jobs)
- Rodauth (authentication)
- Hotwire / Turbo
- Kamal (deployment)
- Docker

## Setup (Development)

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Generate ActivityPub keys
bin/rails tsuzuri:generate_keys

# Start the server
bin/rails server
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `TSUZURI_BASE_URL` | Public base URL of the instance | `http://localhost:3000` |
| `TSUZURI_DOMAIN` | Domain name for WebFinger/ActivityPub | `localhost` |
| `TSUZURI_USERNAME` | Username for the single user account | — |
| `TSUZURI_EMAIL` | Account email (seed) | `admin@example.com` |
| `TSUZURI_PASSWORD` | Account password (seed) | `password` |
| `TSUZURI_PRIVATE_KEY_PATH` | Path to RSA private key | `config/keys/private.pem` |
| `TSUZURI_PUBLIC_KEY_PATH` | Path to RSA public key | `config/keys/public.pem` |
| `TSUZURI_SOURCE_URL` | Source code URL (AGPL compliance) | `https://github.com/S-H-GAMELINKS/tsuzuri` |

## Deployment

See the deployment guides:

- [Japanese / 日本語](docs/deployment-ja.md)
- [English](docs/deployment-en.md)

## License

AGPL-3.0
