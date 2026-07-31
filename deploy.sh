#!/bin/bash
set -e

echo "🔧 VIRGOZKI VPN DEPLOY SCRIPT"
echo "=============================="

# Check kung nandoon ang kailangang files
REQUIRED=("Dockerfile" "config.json")
for f in "${REQUIRED[@]}"; do
  if [ ! -f "$f" ]; then
    echo "❌ KULANG ANG FILE: $f"
    exit 1
  fi
done
echo "✅ Lahat ng kailangang files ay nandoon"

# Stop at tanggalin ang lumang container kung meron na
if docker ps -a --format '{{.Names}}' | grep -q "^virgozki-xray$"; then
  echo "⚠️  Tinatanggal ang lumang container..."
  docker stop virgozki-xray || true
  docker rm virgozki-xray || true
fi

# I-build ang bagong image
echo "🔨 Binubuo ang Docker image..."
docker build -t virgozki-xray:latest .

# Patakbuhin ang container
echo "🚀 Pinapatakbo ang server..."
docker run -d \
  --name virgozki-xray \
  --restart always \
  --network host \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  virgozki-xray:latest

echo "✅ TAPOS NA! Server ay tumatakbo na."
echo "📊 I-check ang status: docker ps | grep virgozki"
echo "📜 Tingnan ang logs: docker logs virgozki-xray"
