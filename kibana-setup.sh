#!/bin/bash

KIBANA_URL=${KIBANA_URL:-http://localhost:5601}
ES_URL=${ES_URL:-http://localhost:9200}
INDEX="instacks-metrics"

echo "🔧 Setting up Kibana index pattern..."

# Create index pattern via Kibana API
curl -X POST "$KIBANA_URL/api/saved_objects/index-pattern" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d "{
    \"attributes\": {
      \"title\": \"$INDEX\",
      \"timeFieldName\": \"@timestamp\"
    }
  }" 2>/dev/null | grep -q '"id"' && echo "✅ Index pattern created: $INDEX" || echo "⚠️  Index pattern may already exist or Kibana not ready"

echo ""
echo "📊 Kibana is ready at http://localhost:5601"
echo "   Go to Stack Management → Index Patterns → Create index pattern"
echo "   Pattern name: $INDEX"
echo "   Time field: @timestamp"
echo ""
echo "   Or use Discover to explore your metrics!"
