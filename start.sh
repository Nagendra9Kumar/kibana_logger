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

echo "⏳ Waiting for Elasticsearch to be healthy..."
until docker exec elasticsearch curl -s \
  -u "elastic:${ELASTIC_PASSWORD}" \
  "http://localhost:9200/_cluster/health" | grep -q '"status":"green"\|"status":"yellow"'; do
  echo "   ... still waiting"
  sleep 5
done

echo "✅ Elasticsearch is healthy!"

if [ ! -f .kibana_password_set ]; then
  echo "🔐 Setting kibana_system password..."
  docker exec elasticsearch curl -s \
    -u "elastic:${ELASTIC_PASSWORD}" \
    -X POST "http://localhost:9200/_security/user/kibana_system/_password" \
    -H "Content-Type: application/json" \
    -d "{\"password\": \"${KIBANA_SYSTEM_PASSWORD}\"}"
 
  echo ""
  echo "✅ kibana_system password set"
else
  echo "⏭️  kibana_system password already set, skipping"
fi

echo ""
echo "✅ All done! Services running:"
docker compose ps