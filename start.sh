#!/bin/bash

set -e

echo "🛑 Stopping existing containers..."
docker compose down

echo "🔨 Rebuilding node-exporter (no cache)..."
docker compose build --no-cache node-exporter

echo "🚀 Starting all services..."
docker compose --env-file .env up -d

echo "⏳ Waiting for Elasticsearch to be healthy..."
until docker exec elasticsearch curl -s -u "elastic:${ELASTIC_PASSWORD}" \
  http://localhost:9200/_cluster/health | grep -q '"status":"green"\|"status":"yellow"'; do
  echo "   ... still waiting"
  sleep 5
done

echo "🔐 Setting kibana_system password..."
docker exec elasticsearch curl -s \
  -u "elastic:${ELASTIC_PASSWORD}" \
  -X POST "http://localhost:9200/_security/user/kibana_system/_password" \
  -H "Content-Type: application/json" \
  -d "{\"password\": \"${KIBANA_SYSTEM_PASSWORD}\"}"

echo ""
echo "✅ All done! Services running:"
docker compose ps