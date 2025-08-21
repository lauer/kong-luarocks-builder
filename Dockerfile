FROM kong:3.9-ubuntu

USER root

RUN apt-get update \
    && apt-get install -y git unzip ca-certificates luarocks \
    && rm -rf /var/lib/apt/lists/*

ENV HOME=/opt/rocks \
    LUAROCKS_CACHE=/opt/rocks/.cache

RUN mkdir -p /opt/rocks /opt/rocks/.cache
RUN chown kong:0 /opt/rocks && chmod g=rwx -R /opt/rocks

USER kong

SHELL ["/bin/sh", "-lc"]
RUN luarocks --version

CMD ["sh", "-lc", "sleep infinity"]