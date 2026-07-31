FROM openresty/openresty:alpine
RUN apk add --no-cache ca-certificates wget unzip tini curl

# ✅ Download tamang Xray (walang error sa link)
RUN wget --timeout=120 -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v24.10.31/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp/xray/ && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mkdir -p /usr/local/share/xray /etc/xray && \
    mv /tmp/xray/geoip.dat /usr/local/share/xray/ && \
    mv /tmp/xray/geosite.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray /tmp/xray.zip

# ✅ Kopyahin ang lahat ng files
COPY config.json /etc/xray/config.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY index.html /usr/local/openresty/nginx/html/index.html

ENV PORT=8080
ENV XRAY_LOCATION_ASSET=/usr/local/share/xray
EXPOSE 8080

# ✅ Health check na gumagana sa Cloud Run
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# ✅ Siguradong sabay tatakbo ang Xray at Nginx
ENTRYPOINT ["/sbin/tini", "--"]
CMD sh -c "xray run -c /etc/xray/config.json > /var/log/xray.log 2>&1 & exec openresty -g 'daemon off;'"
