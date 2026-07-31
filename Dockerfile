# Opisyal na Xray Core image (latest stable)
FROM xtls/xray:latest

# Impormasyon
LABEL maintainer="Virgozki"
LABEL description="Virgozki VPN Panel + Xray Server (WS/HTTPupgrade/XHTTP/SS/VLESS/Trojan/VMess)"

# Gumamit ng non-root user para sa seguridad
RUN adduser -D -h /etc/xray -s /sbin/nologin xray

# Kopyahin ang config file
COPY config.json /etc/xray/config.json

# I-set ang tamang karapatan
RUN chown -R xray:xray /etc/xray && chmod 644 /etc/xray/config.json

# Ilantad ang mga port na gagamitin
EXPOSE 10000 10001 10002 10003 10004 10005 10006 10007 10008 10009 10010 10011

# Gamitin ang tamang command at config path
USER xray
ENTRYPOINT ["/usr/bin/xray", "run", "-c", "/etc/xray/config.json"]
