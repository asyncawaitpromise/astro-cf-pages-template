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

Get your API token at [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens) → **Create Custom Token**.

Cloudflare's token editor scopes each permission row to a single resource type, so add two rows ("+ Add more"):

| Row | Resources | Permission |
|---|---|---|
| 1 (required) | Account → your account | Developer Platform → **Pages** → Edit |
| 2 (only if setting `CF_CUSTOM_DOMAIN`) | Zone → your domain (or All zones) | DNS & Zones → **Zone** → Read |

Row 2 is read-only and only used by `scaffold.sh` to look up your zone ID — it doesn't grant DNS record access.

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

Future devs/machines: `./scripts/env-crypt.sh decrypt` to restore `.env.local`.

### 5. Trigger your first deploy

Pushes only deploy when tagged (see [CI](#ci) below) — a plain push won't do anything yet:

```bash
git commit --allow-empty -m "chore: initial deploy [deploy]"
git push
```

Or trigger it manually from the Actions tab (**Deploy** → **Run workflow**).

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
