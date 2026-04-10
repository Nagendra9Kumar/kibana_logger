#!/bin/bash

set -e

# Load .env variables into shell
export $(grep -v '^#' .env | xargs)

echo "🛑 Stopping existing containers..."
docker compose down

echo "🔨 Rebuilding node-exporter (no cache)..."
docker compose build --no-cache node-exporter

echo "🚀 Starting all services..."
docker compose --env-file .env up -d

echo ""
echo "✅ All done! Services running:"
docker compose ps