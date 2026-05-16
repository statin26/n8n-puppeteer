FROM ghcr.io/puppeteer/puppeteer:latest

USER root

# Install n8n on top of a Chromium-ready base
RUN npm install -g n8n --unsafe-perm=true

RUN npm install -g n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

USER pptruser

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

EXPOSE 5678

CMD ["n8n"]
