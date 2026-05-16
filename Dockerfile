FROM node:22-bookworm

# Install Chromium and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install n8n + puppeteer packages
RUN npm install -g n8n puppeteer n8n-nodes-puppeteer

# Puppeteer config
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Railway
ENV N8N_PORT=5678
EXPOSE 5678

CMD ["n8n"]
