#!/bin/bash
# IndexNow submission script for club777-claw.github.io
# Run after Hugo build to notify search engines of new/updated pages

SITE="https://club777-claw.github.io"
KEY="d38cbcf439ae2df6f747302a1ad9aaaa"
KEY_LOCATION="${SITE}/${KEY}.txt"

# Get all post URLs from sitemap
URLS=$(grep -oP '<loc>\K[^<]+' public/sitemap.xml 2>/dev/null | head -100)

if [ -z "$URLS" ]; then
  echo "No URLs found in sitemap.xml"
  exit 0
fi

# Build JSON payload
URL_ARRAY=""
for url in $URLS; do
  if [ -n "$URL_ARRAY" ]; then
    URL_ARRAY="${URL_ARRAY},"
  fi
  URL_ARRAY="${URL_ARRAY}\"${url}\""
done

PAYLOAD="{\"host\":\"club777-claw.github.io\",\"key\":\"${KEY}\",\"keyLocation\":\"${KEY_LOCATION}\",\"urlList\":[${URL_ARRAY}]}"

# Submit to IndexNow (Bing endpoint, shared with Yandex/Naver)
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "https://api.indexnow.org/IndexNow" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

echo "IndexNow submission: HTTP ${RESPONSE}"
if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "202" ]; then
  echo "OK — URLs submitted successfully"
else
  echo "WARNING — Unexpected response code"
fi
