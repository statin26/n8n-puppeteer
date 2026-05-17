FROM n8nio/n8n:latest

USER root

RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    fonts-freefont-ttf \
    ghostscript \
    libnss3 \
    libxss1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    ca-certificates \
    wget \
    bash \
    && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN npm install -g puppeteer n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

USER node
