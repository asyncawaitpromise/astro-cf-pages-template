#!/usr/bin/env bash
# Bootstrap a new dev environment by decrypting .env.local.enc from the repo.
#
# Prerequisites (one-time, on the new machine):
#   gh auth login
#   gh repo clone <owner>/<repo>
#   cd <repo>
#
# Then run:
#   ./scripts/bootstrap.sh
#
# To create the initial encrypted file (first time only):
#   ./scripts/env-crypt.sh encrypt
#   git add .env.local.enc && git commit -m "chore: add encrypted env"

set -euo pipefail

ENC_FILE=".env.local.enc"
ENV_FILE=".env.local"

if [[ ! -f "$ENC_FILE" ]]; then
  echo "Error: $ENC_FILE not found. Are you in the project root?" >&2
  echo "First time setup: copy .env.example to .env.local, fill in values, then run:" >&2
  echo "  ./scripts/env-crypt.sh encrypt" >&2
  exit 1
fi

if [[ -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE already exists. Remove it first to re-bootstrap." >&2
  exit 1
fi

if ! command -v gpg &>/dev/null; then
  echo "Error: gpg not found. Install gnupg (brew install gnupg / apt install gnupg)." >&2
  exit 1
fi

echo "Decrypting $ENC_FILE..."
./scripts/env-crypt.sh decrypt

echo ""
echo "Next: run ./scripts/scaffold.sh to create the CF Pages project."
echo "Then: run ./scripts/sync-secrets.sh to push CI secrets to GitHub."
