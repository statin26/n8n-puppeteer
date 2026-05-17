# n8n with Puppeteer & Chromium on Railway
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/deploy?template=https://github.com/statin26/n8n-puppeteer)

This repository contains a highly optimized, custom Docker configuration designed to run **n8n** alongside **Puppeteer** and a headless **Chromium** browser on [Railway](https://www.google.com/search?q=https://railway.app/).

Because Railway containers execute without root kernel privileges (`SYS_ADMIN`), standard headless Chrome installations will crash. This setup is explicitly engineered to bypass sandbox permission errors and handle resource constraints seamlessly.

---

## 🚀 Quick Start on Railway

1. **Fork or Clone** this repository to your GitHub account.
2. Go to your **Railway Dashboard** and click **New Project** -> **Deploy from GitHub repo**.
3. Select this repository.
4. Add the required [Environment Variables](https://www.google.com/search?q=%23-environment-variables) in the Railway UI.
5. Click **Deploy**.

---

## 🛠️ Deep Dive: The Dockerfile Explained

The included `Dockerfile` uses a multi-layered approach to ensure stability, tiny footprint sizes, and secure permission handling. Here is exactly what happens under the hood:

### 1. Base Image & System Dependencies

```dockerfile
FROM alpine:3.20

```

* **Alpine Linux:** Chosen for its ultra-lightweight footprint to conserve Railway memory and disk usage.
* **Native Packages (`apk add`):** Installs the exact system libraries required to render web pages headlessly (e.g., `freetype`, `harfbuzz`, `ttf-freefont`) alongside core binaries like `nodejs`, `npm`, and `git`.
* **Chromium:** Installs the Alpine-native Chromium package directly, matching system architecture flawlessly.

### 2. Environment Configurations

```dockerfile
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

```

* `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD`: Instructs npm to skip downloading a bundled Chromium binary during setup, avoiding bloated build sizes.
* `PUPPETEER_EXECUTABLE_PATH`: Points Puppeteer directly to the lightweight system-level Chromium binary installed via Alpine.
* `N8N_COMMUNITY_PACKAGES_ENABLED`: Pre-authorizes n8n to load external nodes like `n8n-nodes-puppeteer`.

### 3. Decoupled Dependency Tree (The Stability Layer)

```dockerfile
RUN npm install -g n8n --unsafe-perm=true
RUN npm install -g puppeteer n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

```

* **Separated Runs:** n8n and Puppeteer are installed in sequential steps. This forces npm to evaluate dependency conflicts (such as internal `zod` schema maps or `@oclif/core` CLI mismatches) separately, preventing the dreaded `Error: command start not found` runtime issue.

### 4. Non-Root Security Enforcement

```dockerfile
RUN addgroup -g 1000 node && adduser -u 1000 -G node -s /bin/sh -D node
USER node

```

* Standardizes container execution under an unprivileged `node` user instead of running natively as `root`, aligning with modern cloud-native security benchmarks.

---

## ⚙️ Environment Variables

Configure these keys inside your **Railway Service Variables** tab to customize performance and silence platform noise:

| Variable | Recommended Value | Description |
| --- | --- | --- |
| `N8N_DIAGNOSTICS_ENABLED` | `false` | Disables internal telemetry calls to prevent PostHog `401 Unauthorized` errors from flooding logs. |
| `N8N_VERSION_NOTIFICATIONS_ENABLED` | `false` | Hides the UI warning banner regarding newer core releases if your customized build is performing stably. |
| `N8N_RUNNERS_ENABLED` | `true` | Activates modern task runner frameworks to scale workflows and handle asynchronous load. |
| `N8N_ENCRYPTION_KEY` | *(Auto-generated if blank)* | A unique cryptographic key string used to safely encrypt your workflow credentials in the database. |

---

## ⚠️ Critical Node Configuration (Required)

Because Railway containers isolate processes, Chromium cannot instantiate its native kernel namespace sandbox inside the host environment. **If left unconfigured, your Puppeteer workflow nodes will fail with a `Permission Denied` fatal check.**

### Required Puppeteer Node Parameters

Whenever you use the **Puppeteer Node** in an n8n canvas, you **must** add the following configuration keys under its Advanced/Launch Arguments:

1. **Arguments (Array):**
* `--no-sandbox`
* `--disable-setuid-sandbox`


2. **Protocol Timeout:**
* `60000` *(or higher)* — This prevents heavy JS-rendered tracking scripts from causing a `Network.enable timed out` error during scraping sequences.



#### Target JSON Representation within n8n:

```json
{
  "args": [
    "--no-sandbox",
    "--disable-setuid-sandbox"
  ],
  "protocolTimeout": 60000
}

```

---

## 🔄 Updating n8n

Since the Dockerfile downloads the latest version from npm when executing a build layer, your instance will not auto-update on a standard application restart.

To pull the newest updates and features released by the n8n team:

1. Navigate to your n8n service dashboard on **Railway**.
2. Go to the **Settings** tab.
3. Scroll down to the **Build** card.
4. Click **Clear Build Cache and Deploy**.

This completely clears Railway's local cache layers, prompting the container to run a fresh `npm install` directly pulling the latest stable releases from the registry.
