const axios = require("axios");
const { Client } = require("@elastic/elasticsearch");

// Config
const ES_NODE = process.env.ES_NODE || "http://localhost:9200";
const API_URL =
  process.env.API_URL ||
  "https://instacks.co/api/v1/coding-execution-activity";
const INDEX = "instacks-metrics";
const INTERVAL = 30000;

// Elasticsearch client
const client = new Client({
  node: ES_NODE,
  auth: {
    username: "elastic",
    password: process.env.ELASTIC_PASSWORD || "",
  },
});

// Transform API response → structured metrics
function transform(data) {
  return {
    "@timestamp": new Date().toISOString(),

    service: "instacks",
    type: "code-execution",

    rt_tests: data?.RT_TESTS ?? 0,
    rt_practice: data?.RT_PRACTICE ?? 0,
  };
}

// Ensure index exists (basic mapping)
async function ensureIndex() {
  const exists = await client.indices.exists({ index: INDEX });

  if (!exists) {
    await client.indices.create({
      index: INDEX,
      mappings: {
        properties: {
          "@timestamp": { type: "date" },
          service: { type: "keyword" },
          type: { type: "keyword" },
          rt_tests: { type: "integer" },
          rt_practice: { type: "integer" },
        },
      },
    });

    console.log("✅ Index created:", INDEX);
  }
}

// Fetch + push
async function fetchAndPush() {
  try {
    const res = await axios.get(API_URL);

    const doc = transform(res.data);

    await client.index({
      index: INDEX,
      document: doc,
    });

    console.log(
      `✅ Indexed @ ${doc["@timestamp"]} | tests=${doc.rt_tests}, practice=${doc.rt_practice}`
    );
  } catch (err) {
    console.error("❌ Error:", err.message);
  }
}

// Start
async function start() {
  await ensureIndex();

  console.log("🚀 Logger started (every 30s)");

  fetchAndPush();
  setInterval(fetchAndPush, INTERVAL);
}

start();
