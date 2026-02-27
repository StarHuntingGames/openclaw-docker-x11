VERSION = 2026.2.24
USER = app

.DEFAULT_GOAL := onboard
.PHONY: onboard
all: build-brew build-nodejs build-openclaw build-playwright build-onboard build-gateway

build-brew:
	docker build -t brew -f Dockerfile.brew .

build-nodejs: build-brew
	docker build -t nodejs -f Dockerfile.nodejs .

build-openclaw: build-nodejs
	docker build --build-arg VERSION=$(VERSION) -t openclaw -f Dockerfile.openclaw .

build-claude: build-openclaw
	docker build --build-arg VERSION=$(VERSION) -t claude -f Dockerfile.claude .

build-playwright: build-claude
	docker build --build-arg VERSION=$(VERSION) -t playwright -f Dockerfile.playwright .

build-onboard: build-playwright
	docker build -t onboard -f Dockerfile.onboard .

build-gateway: build-playwright
	docker build -t gateway -f Dockerfile.gateway .

onboard: build-onboard
	docker run -v `pwd`/config/openclaw:/home/app/.openclaw --rm -it onboard

gateway: build-gateway
	docker run -p127.0.0.1:18789:18789 -v `pwd`/config/openclaw:/home/app/.openclaw --rm -it gateway

compose: build-onboard build-gateway
	docker compose up

down:
	docker compose down

dashboard:
	docker exec -it openclaw-gateway openclaw dashboard

devices:
	docker exec -it openclaw-gateway openclaw devices list

approve:
	docker exec -it openclaw-gateway openclaw devices approve --latest

chrome:
	docker exec -it openclaw-gateway openclaw config set agents.defaults.sandbox.browser.allowHostControl true
	docker exec -it openclaw-gateway openclaw config set browser.executablePath "/usr/bin/google-chrome"
	docker exec -it openclaw-gateway openclaw config set browser.enabled  true
	docker exec -it openclaw-gateway openclaw config set browser.headless true
	docker exec -it openclaw-gateway openclaw config set browser.noSandbox true
	docker exec -it openclaw-gateway openclaw config set browser.defaultProfile "openclaw"
	docker exec -it openclaw-gateway openclaw browser --browser-profile openclaw start

chromium:
	docker exec -it openclaw-gateway chromium --user-data-dir=/data/personas/Default/chrome_profile --profile-directory=Default --disable-gpu --disable-features=dbus --disable-dev-shm-usage --start-maximized --no-sandbox --disable-setuid-sandbox --no-zygote --disable-sync --no-first-run

playwright:
	docker exec -it openclaw-gateway /home/$(USER)/.venv/bin/playwright open https://www.google.com/?`docker exec -it openclaw-gateway grep token /home/$(USER)/.openclaw/openclaw.json|grep -v mode | cut -d '"' -f 4`

extension:
	docker exec -it openclaw-gateway openclaw browser extension install

token:
	docker exec -it openclaw-gateway grep token /home/$(USER)/.openclaw/openclaw.json|grep -v mode | cut -d '"' -f 4

openclaw:
	docker exec -it openclaw-gateway openclaw




