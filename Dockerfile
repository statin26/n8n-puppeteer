# Use a standard, complete Alpine base image
FROM alpine:3.20

# Install Chromium, native dependencies, Node, and Git
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont \
    ghostscript \
    bash \
    nodejs \
    npm \
    git

# Global environment variables for Puppeteer and n8n behavior
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Step 1: Install n8n globally by itself to let its dependency tree lock correctly
RUN npm install -g n8n --unsafe-perm=true

# Step 2: Install puppeteer and the community node alongside it smoothly
RUN npm install -g puppeteer n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

# Create the 'node' system group and user manually in Alpine
RUN addgroup -g 1000 node && \
    adduser -u 1000 -G node -s /bin/sh -D node

# Set up the data directories with the correct permissions
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node

# --- NETWORKING & RAILWAY BINDING FIXES ---
# Force n8n to listen on all interfaces so Railway's healthcheck proxy can see it
ENV N8N_PORT=5678
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# Expose n8n's standard runtime port
EXPOSE 5678
# ------------------------------------------

# Switch to the secure non-root user
USER node
WORKDIR /home/node

# Start n8n directly
CMD ["n8n", "start"]
