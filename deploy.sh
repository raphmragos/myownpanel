#!/bin/bash
# ==============================================================================
# VIRGOZKI PANEL • QWIKLABS ULTIMATE FIX • DIRECT SOURCE DEPLOY
# WALANG KAILANGANG PERMISSION SA CLOUD BUILD / GCR / ARTIFACT REGISTRY
# ==============================================================================

BOLD='\033[1m'; RESET='\033[0m'
GREEN='\033[1;32m'; RED='\033[1;31m'; CYAN='\033[1;36m'
YELLOW='\033[1;33m'; MAGENTA='\033[1;35m'; WHITE='\033[1;37m'

# ==============================================
# 🗺️ LAHAT NG REGION + BANSA (NUMBERED)
# ==============================================
ALL_REGIONS=(
  "01:asia-east1:Taiwan"
  "02:asia-east2:Hong Kong"
  "03:asia-northeast1:Japan (Tokyo)"
  "04:asia-northeast2:Japan (Osaka)"
  "05:asia-northeast3:South Korea (Seoul)"
  "06:asia-south1:India (Mumbai)"
  "07:asia-south2:India (Delhi)"
  "08:asia-southeast1:Singapore"
  "09:asia-southeast2:Indonesia (Jakarta)"
  "10:australia-southeast1:Australia (Sydney)"
  "11:australia-southeast2:Australia (Melbourne)"
  "12:europe-central2:Poland (Warsaw)"
  "13:europe-north1:Finland"
  "14:europe-southwest1:Spain (Madrid)"
  "15:europe-west1:Belgium"
  "16:europe-west2:United Kingdom (London)"
  "17:europe-west3:Germany (Frankfurt)"
  "18:europe-west4:Netherlands"
  "19:europe-west6:Switzerland (Zurich)"
  "20:europe-west8:Italy (Milan)"
  "21:europe-west9:France (Paris)"
  "22:northamerica-northeast1:Canada (Montreal)"
  "23:northamerica-northeast2:Canada (Toronto)"
  "24:southamerica-east1:Brazil (Sao Paulo)"
  "25:southamerica-west1:Chile (Santiago)"
  "26:us-central1:USA (Iowa)"
  "27:us-east1:USA (South Carolina)"
  "28:us-east4:USA (North Virginia)"
  "29:us-east5:USA (Columbus)"
  "30:us-south1:USA (Texas)"
  "31:us-west1:USA (Oregon)"
  "32:us-west2:USA (Los Angeles)"
  "33:us-west3:USA (Salt Lake City)"
  "34:us-west4:USA (Las Vegas)"
)

loading() {
    local t="$1"
    local s="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    for ((i=0;i<5;i++)); do 
        for ((j=0;j<${#s};j++)); do 
            echo -ne "\r  ${CYAN}${s:$j:1} ${t}...${RESET}"
            sleep 0.05
        done
    done
    echo -ne "\r  ${GREEN}✅ DONE: ${t}${RESET}\n"
}

clear
echo ""
echo -e "  ${BOLD}${WHITE}VIRGOZKI PANEL • QWIKLABS 100% WORKING${RESET}"
echo -e "  ${MAGENTA}MADE BY VIRGOZKI${RESET}"
echo -e "  ${GREEN}✅ DIRECT SOURCE DEPLOY • NO EXTRA PERMISSIONS NEEDED${RESET}"
echo ""

PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
if [ -z "$PROJECT_ID" ]; then
    echo -e "  ${RED}❌ ERROR: No active project. Run 'gcloud init' first.${RESET}"
    exit 1
fi
echo -e "  ${CYAN}PROJECT: ${GREEN}${PROJECT_ID}${RESET}"
echo ""

# ==============================================
# 🔢 MANUAL REGION SELECT
# ==============================================
echo -e "  ${CYAN}📋 PUMILI NG REGION:${RESET}"
for i in "${!ALL_REGIONS[@]}"; do
  IFS=':' read -r num reg_name country <<< "${ALL_REGIONS[$i]}"
  printf "  ${YELLOW}%s) ${GREEN}%-25s ${CYAN}(%s)${RESET}\n" "$num" "$reg_name" "$country"
done
echo ""
read -r -p "$(echo -e "  ${CYAN}ILAGAY ANG NUMBER: ${RESET}")" REG_CHOICE

REGION=""
for item in "${ALL_REGIONS[@]}"; do
  IFS=':' read -r num reg_name _ <<< "$item"
  if [ "$num" = "$REG_CHOICE" ]; then
    REGION="$reg_name"
    break
  fi
done

if [ -z "$REGION" ]; then
  echo -e "  ${RED}❌ INVALID NUMBER!${RESET}"
  exit 1
fi
echo -e "  ${CYAN}✅ PINILING REGION: ${GREEN}${REGION}${RESET}"
echo ""

# ==============================================
# 🔐 GITHUB TOKEN (OPTIONAL)
# ==============================================
GH_TOKEN=""
if curl -sL --connect-timeout 5 "https://pastebin.com/raw/a1VAU15h" | grep -q "^gh[pousr]_"; then
    GH_TOKEN=$(curl -sL --connect-timeout 5 "https://pastebin.com/raw/a1VAU15h" | tr -d '\r\n[:space:]')
    echo -e "  ${GREEN}✅ LOADED TOKEN FROM PASTEBIN${RESET}"
else
    echo -e "  ${YELLOW}⚠️ SKIPPING GITHUB SYNC${RESET}"
fi

read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [virgozki-panel]: ${RESET}")" INPUT_NAME
INPUT_NAME=$(echo "$INPUT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
SERVICE_NAME=${INPUT_NAME:-virgozki-panel}

echo ""
echo -e "  ${CYAN}SELECT DEPLOY MODE:${RESET}"
echo -e "  ${YELLOW}1) AUTO   (1 vCPU / 2Gi RAM) ✅ Qwiklabs Recommended${RESET}"
echo -e "  ${YELLOW}2) HIGH   (2 vCPU / 4Gi RAM)${RESET}"
echo -e "  ${YELLOW}3) STABLE (4 vCPU / 8Gi RAM)${RESET}"
echo ""
read -r -p "$(echo -e "  ${CYAN}CHOICE: ${RESET}")" MODE_CHOICE

case "$MODE_CHOICE" in
    1) CPU="1"; RAM="2Gi"; MAX_INSTANCES="2";;
    2) CPU="2"; RAM="4Gi"; MAX_INSTANCES="2";;
    3) CPU="4"; RAM="8Gi"; MAX_INSTANCES="1";;
    *) CPU="1"; RAM="2Gi"; MAX_INSTANCES="2";;
esac

echo ""
loading "CHECKING FILES"
for f in config.json nginx.conf Dockerfile index.html; do
    if [ ! -f "$f" ]; then
        echo -e "  ${RED}❌ MISSING: $f${RESET}"
        exit 1
    fi
done

# ==============================================
# 🚀 DIRECT SOURCE DEPLOY (WALANG BUILD/PUSH!)
# ==============================================
loading "DEPLOYING DIRECTLY TO CLOUD RUN"
gcloud run deploy "$SERVICE_NAME" \
  --source . \
  --platform managed \
  --region "$REGION" \
  --cpu "$CPU" --memory "$RAM" --port 8080 \
  --concurrency 800 --timeout 3600 \
  --min-instances 0 --max-instances "$MAX_INSTANCES" \
  --allow-unauthenticated \
  --project "$PROJECT_ID"

if [ $? -ne 0 ]; then 
    echo -e "  ${RED}❌ DEPLOY FAILED${RESET}"
    exit 1
fi

# ==============================================
# ✅ GENERATE LINKS
# ==============================================
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format='value(status.url)')
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

VMESS_UUID="b831381d-6324-4d53-ad4f-8cda48b30811"
SS_B64=$(echo -n "aes-256-gcm:virgozki" | base64 -w0)

VLESS_WS="vless://${VMESS_UUID}@${CLEAN_HOST}:443?encryption=none&type=ws&path=/vless-virgozki&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#VLESS-WS"
VLESS_HU="vless://${VMESS_UUID}@${CLEAN_HOST}:443?encryption=none&type=httpupgrade&path=/vless-virgozki-hu&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#VLESS-HU"
VLESS_XHTTP="vless://${VMESS_UUID}@${CLEAN_HOST}:443?encryption=none&type=xhttp&path=/vless-virgozki-xhttp&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}&mode=packet-upstream#VLESS-XHTTP"
TROJAN_WS="trojan://virgozki@${CLEAN_HOST}:443?type=ws&path=/virgozki&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#TROJAN-WS"

echo ""
echo -e "  ${GREEN}✅ SUCCESS! DEPLOYED IN ${REGION}${RESET}"
echo -e "  ${CYAN}DASHBOARD: ${GREEN}${SERVICE_URL}${RESET}"
echo ""
echo -e "  ${YELLOW}🔗 CONNECT LINKS:${RESET}"
echo -e "  ${CYAN}VLESS WS:     ${GREEN}${VLESS_WS}${RESET}"
echo -e "  ${CYAN}VLESS HU:     ${GREEN}${VLESS_HU}${RESET}"
echo -e "  ${CYAN}VLESS XHTTP:  ${GREEN}${VLESS_XHTTP}${RESET}"
echo -e "  ${CYAN}TROJAN WS:    ${GREEN}${TROJAN_WS}${RESET}"

echo -e "\n  ${GREEN}✅ DONE – WALA NANG ERROR!${RESET}"
