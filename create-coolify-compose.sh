#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="docker-compose.coolify.yml"

cat > "$OUTPUT_FILE" <<'EOF'
services:
  db:
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: paperclip
      POSTGRES_PASSWORD: paperclip
      POSTGRES_DB: paperclip
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U paperclip -d paperclip"]
      interval: 2s
      timeout: 5s
      retries: 30
    volumes:
      - pgdata:/var/lib/postgresql/data

  server:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgres://paperclip:paperclip@db:5432/paperclip
      PORT: "3100"
      SERVE_UI: "true"

      PAPERCLIP_DEPLOYMENT_MODE: "authenticated"
      PAPERCLIP_DEPLOYMENT_EXPOSURE: "private"

      PAPERCLIP_PUBLIC_URL: "${PAPERCLIP_PUBLIC_URL}"
      BETTER_AUTH_SECRET: "${BETTER_AUTH_SECRET}"
    volumes:
      - paperclip-data:/paperclip
    depends_on:
      db:
        condition: service_healthy

volumes:
  pgdata:
  paperclip-data:
EOF

echo "Created $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "1. Commit this file to your repo."
echo "2. In Coolify, set Docker Compose Location to: $OUTPUT_FILE"
echo "3. Add env vars:"
echo "   PAPERCLIP_PUBLIC_URL=https://your-domain.com"
echo "   BETTER_AUTH_SECRET=\$(openssl rand -base64 32)"
