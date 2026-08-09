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
Create one with **Cloudflare Pages: Edit** permissions. If you'll also set `CF_CUSTOM_DOMAIN`, add **Zone: Zone: Read** too — `scaffold.sh` looks up the zone ID before attaching the domain, and that call needs zone read access.

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
| Push to `main`/`master` with `[deploy]` anywhere in the commit message | Build + deploy to production |
| Manual trigger (Actions tab → Deploy → Run workflow) | Build + deploy to production |
| PR labeled `preview` (or updated/reopened while labeled) | Build + deploy a branch preview |
| PR closed | Delete that PR's preview deployment |

Deploys are opt-in per commit/merge so routine PRs don't ship automatically — put `[deploy]` in the commit message (or PR title, for merge/squash commits) when you actually want it live.

Branch preview URLs: `https://pr-<number>.<project>.pages.dev`

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
