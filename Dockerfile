FROM ghcr.io/puppeteer/puppeteer:latest

USER root

RUN npm install -g n8n

RUN npm install -g n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

EXPOSE 5678

CMD ["n8n"]
