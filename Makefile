NAME := selion
VERSION := $(or $(VERSION),$(VERSION),'develop')
PLATFORM := $(shell uname -s)
SELION_GRID_VERSION := $(or $(SELION_GRID_VERSION), $(SELION_GRID_VERSION), '1.1.0-SNAPSHOT')
REPO := $(or $(REPO), $(REPO), 'snapshots')
SELENIUM_VERSION := $(or $(SELENIUM_VERSION), $(SELENIUM_VERSION), '2.53')
SELENIUM_FIX := $(or $(SELENIUM_FIX), $(SELENIUM_FIX), '0')
BUILD_ARGS := $(BUILD_ARGS)

all: hub chrome firefox standalone_phantomjs standalone_firefox standalone_chrome

build: all

ci: build test

generate_all: \
	generate_base \
	generate_hub \
	generate_nodebase \
	generate_chrome \
	generate_firefox \
	generate_standalone_phantomjs \
	generate_standalone_firefox \
	generate_standalone_chrome

generate_base:
	cd ./base && ./generate.sh $(SELENIUM_VERSION) $(SELENIUM_FIX) $(REPO) $(SELION_GRID_VERSION)

generate_hub:
	cd ./hub && ./generate.sh $(VERSION)

generate_nodebase:
	cd ./nodeBase && ./generate.sh $(VERSION)

generate_chrome:
	cd ./nodeChrome && ./generate.sh $(VERSION)

generate_firefox:
	cd ./nodeFirefox && ./generate.sh $(VERSION)

generate_standalone_phantomjs:
	cd ./standalonePhantomjs && ./generate.sh $(VERSION)

base: generate_base
	cd ./base && docker build $(BUILD_ARGS) -t $(NAME)/base:$(VERSION) .

hub: base generate_hub
	cd ./hub && docker build $(BUILD_ARGS) -t $(NAME)/hub:$(VERSION) .

nodebase: base generate_nodebase
	cd ./nodeBase && docker build $(BUILD_ARGS) -t $(NAME)/node-base:$(VERSION) .

chrome: nodebase generate_chrome
	cd ./nodeChrome && docker build $(BUILD_ARGS) -t $(NAME)/node-chrome:$(VERSION) .

standalone_chrome: generate_standalone_chrome chrome
	cd ./standaloneChrome && docker build $(BUILD_ARGS) -t $(NAME)/standalone-chrome:$(VERSION) .

generate_standalone_chrome:
	cd ./standaloneChrome && ./generate.sh $(VERSION)

firefox: nodebase generate_firefox
	cd ./nodeFirefox && docker build $(BUILD_ARGS) -t $(NAME)/node-firefox:$(VERSION) .

standalone_firefox: generate_standalone_firefox firefox
	cd ./standaloneFirefox && docker build $(BUILD_ARGS) -t $(NAME)/standalone-firefox:$(VERSION) .

generate_standalone_firefox:
	cd ./standaloneFirefox && ./generate.sh $(VERSION)

standalone_phantomjs: nodebase generate_standalone_phantomjs
	cd ./standalonePhantomjs && docker build $(BUILD_ARGS) -t $(NAME)/standalone-phantomjs:$(VERSION) .

tag_latest:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:latest
	docker tag $(NAME)/hub:$(VERSION) $(NAME)/hub:latest
	docker tag $(NAME)/node-base:$(VERSION) $(NAME)/node-base:latest
	docker tag $(NAME)/node-chrome:$(VERSION) $(NAME)/node-chrome:latest
	docker tag $(NAME)/standalone-chrome:$(VERSION) $(NAME)/standalone-chrome:latest
	docker tag $(NAME)/node-firefox:$(VERSION) $(NAME)/node-firefox:latest
	docker tag $(NAME)/standalone-firefox:$(VERSION) $(NAME)/standalone-firefox:latest
	docker tag $(NAME)/standalone-phantomjs:$(VERSION) $(NAME)/standalone-phantomjs:latest

release: tag_latest deploy
	@echo "*** Don't forget to create a tag. git tag v$(VERSION) && git push origin v$(VERSION)"

dev_release: deploy

deploy:
	@if ! docker images $(NAME)/base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/hub | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/hub version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-chrome | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-chrome version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-chrome | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-chrome version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-firefox | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-firefox version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-firefox | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-firefox version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-phantomjs | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-phantomjs version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/hub:$(VERSION)
	docker push $(NAME)/node-base:$(VERSION)
	docker push $(NAME)/node-chrome:$(VERSION)
	docker push $(NAME)/standalone-chrome:$(VERSION)
	docker push $(NAME)/node-firefox:$(VERSION)
	docker push $(NAME)/standalone-firefox:$(VERSION)
	docker push $(NAME)/standalone-phantomjs:$(VERSION)

test:
	VERSION=$(VERSION) ./test.sh
	VERSION=$(VERSION) ./sa-test.sh

.PHONY: \
	all \
	base \
	build \
	chrome \
	ci \
	firefox \
	hub \
	nodebase \
	release \
    sa-test \
	standalone_chrome \
	standalone_firefox \
	standalone_phantomjs \
	tag_latest \
	test
