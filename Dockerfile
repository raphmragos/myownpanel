FROM openresty/openresty:alpine
RUN apk add --no-cache ca-certificates wget unzip tini

# ✅ Download tamang Xray v24.10.31 (gumagana ang link)
RUN wget --timeout=120 -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v24.10.31/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp/xray/ && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mkdir -p /usr/local/share/xray/ /etc/xray/ && \
    mv /tmp/xray/geoip.dat /usr/local/share/xray/ && \
    mv /tmp/xray/geosite.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    chmod 644 /usr/local/share/xray/*.dat && \
    rm -rf /tmp/xray /tmp/xray.zip

# ✅ Tama na ang path ng config
COPY config.json /etc/xray/config.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY index.html /usr/local/openresty/nginx/html/index.html

ENV XRAY_LOCATION_ASSET=/usr/local/share/xray/
EXPOSE 8080

# ✅ Health check para sa Cloud Run
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# ✅ Tamang pagpapatakbo ng dalawang serbisyo
ENTRYPOINT ["/sbin/tini", "--"]
CMD sh -c "xray run -c /etc/xray/config.json & exec openresty -g 'daemon off;'"
