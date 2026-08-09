# astro-cf-pages

Static site starter: Astro 5 + React + Tailwind + DaisyUI + Lucide icons, deployed to Cloudflare Pages.

No server, no Docker, no registry. CF Pages handles deploys and branch previews natively.

## Stack

- [Astro 5](https://astro.build) — static site generator
- [React 19](https://react.dev) — interactive components via `client:load`
- [Tailwind CSS](https://tailwindcss.com) + [DaisyUI](https://daisyui.com) — styling
- [Lucide React](https://lucide.dev) — icons
- [Cloudflare Pages](https://pages.cloudflare.com) — hosting + branch previews

## First-time setup

### 1. Clone and configure env

```bash
cp .env.example .env.local
# fill in CF_ACCOUNT_ID, CF_API_TOKEN, CF_PAGES_PROJECT
```

Get your API token at [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens).  
Create one with **Cloudflare Pages: Edit** permissions.

### 2. Scaffold CF Pages project

```bash
./scripts/scaffold.sh
```

Creates the Pages project and optional custom domain via the CF API.

### 3. Sync CI secrets to GitHub

```bash
./scripts/sync-secrets.sh
```

Pushes `CF_ACCOUNT_ID`, `CF_API_TOKEN`, `CF_PAGES_PROJECT` to GitHub Secrets so CI can deploy.

### 4. Encrypt your env for the repo (optional but recommended)

```bash
./scripts/env-crypt.sh encrypt
git add .env.local.enc && git commit -m "chore: add encrypted env"
```

Future devs/machines: `./scripts/bootstrap.sh` to decrypt.

## CI

| Event | Action |
|---|---|
| Push to `main` | Build + deploy to production |
| Push to any other branch | Build + deploy branch preview |

Branch preview URLs: `https://<branch>.<project>.pages.dev`

## Local dev

```bash
pnpm install
pnpm dev
```

## Scripts

| Script | Purpose |
|---|---|
| `scripts/scaffold.sh` | One-time CF Pages project creation |
| `scripts/sync-secrets.sh` | Sync `.env.local` → GitHub Secrets |
| `scripts/env-crypt.sh` | GPG encrypt/decrypt `.env.local` |
| `scripts/bootstrap.sh` | New machine setup via encrypted env |
