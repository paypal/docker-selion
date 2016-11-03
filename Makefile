NAME := selion
VERSION := $(or $(VERSION),$(VERSION),'develop')
PLATFORM := $(shell uname -s)
SELION_GRID_VERSION := $(or $(SELION_GRID_VERSION), $(SELION_GRID_VERSION), '2.0.0-SNAPSHOT')
REPO := $(or $(REPO), $(REPO), 'snapshots')
SELENIUM_VERSION := $(or $(SELENIUM_VERSION), $(SELENIUM_VERSION), '3.0')
SELENIUM_FIX := $(or $(SELENIUM_FIX), $(SELENIUM_FIX), '1')
BUILD_ARGS := $(BUILD_ARGS)

all: hub chrome firefox phantomjs standalone_phantomjs standalone_firefox standalone_chrome

build: all

ci: build test

generate_all: \
	generate_base \
	generate_hub \
	generate_nodebase \
	generate_chrome \
	generate_firefox \
	generate_phantomjs \
	generate_standalone_phantomjs \
	generate_standalone_firefox \
	generate_standalone_chrome

generate_base:
	@echo "Generating sources for $(NAME)/base:$(VERSION) ..."
	cd ./base && ./generate.sh $(SELENIUM_VERSION) $(SELENIUM_FIX) $(REPO) $(SELION_GRID_VERSION)

base: generate_base
	@echo "Building $(NAME)/base:$(VERSION) ..."
	cd ./base && docker build $(BUILD_ARGS) -t $(NAME)/base:$(VERSION) .

generate_hub:
	@echo "Generating sources for $(NAME)/hub:$(VERSION) ..."
	cd ./hub && ./generate.sh $(VERSION)

hub: base generate_hub
	@echo "Building $(NAME)/hub:$(VERSION) ..."
	cd ./hub && docker build $(BUILD_ARGS) -t $(NAME)/hub:$(VERSION) .

generate_nodebase:
	@echo "Generating sources for $(NAME)/node-base:$(VERSION) ..."
	cd ./nodeBase && ./generate.sh $(VERSION)

nodebase: base generate_nodebase
	@echo "Building $(NAME)/node-base:$(VERSION) ..."
	cd ./nodeBase && docker build $(BUILD_ARGS) -t $(NAME)/node-base:$(VERSION) .

generate_chrome:
	@echo "Generating sources for $(NAME)/node-chrome:$(VERSION) ..."
	cd ./nodeChrome && ./generate.sh $(VERSION)

chrome: nodebase generate_chrome
	@echo "Building $(NAME)/node-chrome:$(VERSION) ..."
	cd ./nodeChrome && docker build $(BUILD_ARGS) -t $(NAME)/node-chrome:$(VERSION) .

generate_standalone_chrome:
	@echo "Generating sources for $(NAME)/standalone-chrome:$(VERSION) ..."
	cd ./standaloneChrome && ./generate.sh $(VERSION)

standalone_chrome: generate_standalone_chrome chrome
	@echo "Building $(NAME)/standalone-chrome:$(VERSION) ..."
	cd ./standaloneChrome && docker build $(BUILD_ARGS) -t $(NAME)/standalone-chrome:$(VERSION) .

generate_firefox:
	@echo "Generating sources for $(NAME)/node-firefox:$(VERSION) ..."
	cd ./nodeFirefox && ./generate.sh $(VERSION)

firefox: nodebase generate_firefox
	@echo "Building $(NAME)/node-firefox:$(VERSION) ..."
	cd ./nodeFirefox && docker build $(BUILD_ARGS) -t $(NAME)/node-firefox:$(VERSION) .

generate_standalone_firefox:
	@echo "Generating sources for $(NAME)/standalone-firefox:$(VERSION) ..."
	cd ./standaloneFirefox && ./generate.sh $(VERSION)

standalone_firefox: generate_standalone_firefox firefox
	@echo "Building $(NAME)/standalone-firefox:$(VERSION) ..."
	cd ./standaloneFirefox && docker build $(BUILD_ARGS) -t $(NAME)/standalone-firefox:$(VERSION) .

generate_phantomjs:
	@echo "Generating sources for $(NAME)/node-phantomjs:$(VERSION) ..."
	cd ./nodePhantomjs && ./generate.sh $(VERSION)

phantomjs: nodebase generate_phantomjs
	@echo "Building $(NAME)/node-phantomjs:$(VERSION) ..."
	cd ./nodePhantomjs && docker build $(BUILD_ARGS) -t $(NAME)/node-phantomjs:$(VERSION) .

generate_standalone_phantomjs:
	@echo "Generating sources for $(NAME)/standalone-phantomjs:$(VERSION) ..."
	cd ./standalonePhantomjs && ./generate.sh $(VERSION)

standalone_phantomjs: generate_standalone_phantomjs phantomjs
	@echo "Building $(NAME)/standalone-phantomjs:$(VERSION) ..."
	cd ./standalonePhantomjs && docker build $(BUILD_ARGS) -t $(NAME)/standalone-phantomjs:$(VERSION) .

tag_latest:
	@echo "Tagging $(VERSION) as latest ..."
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:latest
	docker tag $(NAME)/hub:$(VERSION) $(NAME)/hub:latest
	docker tag $(NAME)/node-base:$(VERSION) $(NAME)/node-base:latest
	docker tag $(NAME)/node-chrome:$(VERSION) $(NAME)/node-chrome:latest
	docker tag $(NAME)/node-firefox:$(VERSION) $(NAME)/node-firefox:latest
	docker tag $(NAME)/node-phantomjs:$(VERSION) $(NAME)/node-phantomjs:latest
	docker tag $(NAME)/standalone-chrome:$(VERSION) $(NAME)/standalone-chrome:latest
	docker tag $(NAME)/standalone-firefox:$(VERSION) $(NAME)/standalone-firefox:latest
	docker tag $(NAME)/standalone-phantomjs:$(VERSION) $(NAME)/standalone-phantomjs:latest

release: tag_latest deploy
	@echo "*** Don't forget to create a tag. git tag v$(VERSION) && git push origin v$(VERSION)"

dev_release: deploy

deploy:
	@echo "Deploying to docker registry ..."
	@if ! docker images $(NAME)/base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/hub | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/hub version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-chrome | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-chrome version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-firefox | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-firefox version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-phantomjs | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-phantomjs version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-chrome | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-chrome version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-firefox | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-firefox version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-phantomjs | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-phantomjs version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/hub:$(VERSION)
	docker push $(NAME)/node-base:$(VERSION)
	docker push $(NAME)/node-chrome:$(VERSION)
	docker push $(NAME)/node-firefox:$(VERSION)
	docker push $(NAME)/node-phantomjs:$(VERSION)
	docker push $(NAME)/standalone-chrome:$(VERSION)
	docker push $(NAME)/standalone-firefox:$(VERSION)
	docker push $(NAME)/standalone-phantomjs:$(VERSION)

test:
	@echo "Running tests ..."
	VERSION=$(VERSION) ./test.sh
	VERSION=$(VERSION) ./sa-test.sh

clean:
	@echo "Cleaning up generated Dockerfiles ..."
	@if [ -f base/Dockerfile ]; then rm base/Dockerfile; fi
	@if [ -f hub/Dockerfile ]; then rm hub/Dockerfile; fi
	@if [ -f nodeBase/Dockerfile ]; then rm nodeBase/Dockerfile; fi
	@if [ -f nodeChrome/Dockerfile ]; then rm nodeChrome/Dockerfile; fi
	@if [ -f nodeFirefox/Dockerfile ]; then rm nodeFirefox/Dockerfile; fi
	@if [ -f nodePhantomjs/Dockerfile ]; then rm nodePhantomjs/Dockerfile; fi
	@if [ -f standaloneChrome/Dockerfile ]; then rm standaloneChrome/Dockerfile; fi
	@if [ -f standaloneFirefox/Dockerfile ]; then rm standaloneFirefox/Dockerfile; fi
	@if [ -f standalonePhantomjs/Dockerfile ]; then rm standalonePhantomjs/Dockerfile; fi
	@echo "Removing all exited $(NAME) $(VERSION) containers ..."
	@if [ `docker ps -a | grep $(NAME) | grep Exit | grep $(VERSION) | awk '{print $$1}' | wc -l | sed -e 's/^[ \t]*//'` -ne 0 ]; then\
		docker rm `docker ps -a | grep Exit | grep $(NAME) | grep $(VERSION) | awk '{print $$1}'`;\
	fi
	@echo "Removing all $(NAME) $(VERSION) images ..."
	@if [ `docker images | grep $(NAME) | grep $(VERSION) | awk '{print $$3}' | wc -l | sed -e 's/^[ \t]*//'` -ne 0 ]; then\
		docker rmi -f `docker images | grep $(NAME) | grep $(VERSION) | awk '{print $$3}'`;\
	fi

.PHONY: \
	all \
	base \
	build \
	chrome \
	ci \
	firefox \
	phantomjs \
	hub \
	nodebase \
	release \
	sa-test \
	standalone_chrome \
	standalone_firefox \
	standalone_phantomjs \
	tag_latest \
	test
