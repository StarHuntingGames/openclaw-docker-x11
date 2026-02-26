VERSION = 2026.2.24

.DEFAULT_GOAL := onboard
.PHONY: onboard
all: build-brew build-nodejs build-openclaw build-playwright build-onboard build-gateway

build-brew:
	docker build -t brew -f Dockerfile.brew .

build-nodejs: build-brew
	docker build -t nodejs -f Dockerfile.nodejs .

build-openclaw: build-nodejs
	docker build --build-arg VERSION=$(VERSION) -t openclaw -f Dockerfile.openclaw .

build-playwright: build-openclaw
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
	docker exec -it openclaw-gateway openclaw config set browser.executablePath "/usr/bin/google-chrome"
	docker exec -it openclaw-gateway openclaw config set browser.enabled  true
	docker exec -it openclaw-gateway openclaw config set browser.headless true
	docker exec -it openclaw-gateway openclaw config set browser.noSandbox true
	docker exec -it openclaw-gateway openclaw config set browser.defaultProfile "openclaw"
	docker exec -it openclaw-gateway openclaw browser --browser-profile openclaw start

openclaw:
	docker exec -it openclaw-gateway openclaw



