# SearXNG Deployment Guide (Render + Aiven Valkey + Cloudflare)

Setup for hosting a private or public **SearXNG** metasearch engine instance on **Render** using **Aiven Valkey** (Redis-compatible) for caching/rate-limiting.



## Overview

```
                          ┌───────────────────────────┐
                          │     Client / Browser      │
                          └─────────────┬─────────────┘
                                        │
                                        ▼ HTTPS (search.tom123.something.sth)
                          ┌───────────────────────────┐
                          │         Cloudflare        │
                          └─────────────┬─────────────┘
                                        │ CNAME Proxy
                                        ▼
                          ┌───────────────────────────┐
                          │   Render Web Service      │
                          │    (SearXNG Docker)       │
                          └─────────────┬─────────────┘
                                        │ TLS (rediss://)
                                        ▼
                          ┌───────────────────────────┐
                          │   Aiven Valkey (Redis)    │
                          │   (Cache & Rate Limiting) │
                          └───────────────────────────┘
```

## Project Structure

```
.
├── Dockerfile          # Custom Docker image building from official SearXNG
├── settings.yml        # Main SearXNG engine & server configuration
├── limiter.toml        # Rate-limiting & bot protection configuration
└── README.md           # Deployment documentation
```

## Deployment Steps

### Retrieve Aiven Valkey URI
1. Log in to the **Aiven Console**.
2. Open your Valkey service and locate the **Service URI**.
3. Format: `rediss://default:YOUR_PASSWORD@YOUR_AIVEN_HOST:PORT`
   *(Ensure you use `rediss://` with double 's' for TLS/SSL)*.

### Push Repository to GitHub
Create a repository containing `Dockerfile`, `settings.yml`, `limiter.toml`, and push your code.

### Deploy Service on Render
1. Go to the **Render Dashboard** > **New +** > **Web Service**.
2. Select your repository.
3. Under **Environment Variables**, add:

| Key | Value | Description |
|---|---|---|
| `PORT` | `8080` | Internal listening port |
| `SEARXNG_SECRET` | `<random-32-char-string>` | Secret key for session management |
| `SEARXNG_REDIS_URL` | `rediss://default:pass@host:port` | Aiven Valkey connection string |

## Custom Domain Setup

### Configure Cloudflare DNS
1. Log in to **Cloudflare** and go to your domain's DNS settings.
2. **Add Record**:
   * **Type:** `CNAME`
   * **Name:** `search`
   * **Target:** `your-render-app.onrender.com`
   * **Proxy Status:** **DNS Only** (Gray Cloud).
3. Save the record.

### Add Custom Domain in Render
1. In the Render Dashboard, navigate to **Settings** > **Custom Domains**.
2. Click **Add Custom Domain** and enter `search.yourcloudflaredomain.sth`.
3. Wait for Render to verify the DNS record and issue an SSL certificate.

### Enable Cloudflare Proxy & SSL
1. Switch the Cloudflare DNS Proxy status to **Proxied** (Orange Cloud).
2. Go to **SSL/TLS** in Cloudflare and set the mode to **Full (strict)** to avoid infinite redirect loops.
