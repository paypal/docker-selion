NAME := selion
VERSION := $(or $(VERSION),$(VERSION),'1.0.0')
PLATFORM := $(shell uname -s)

all: hub chrome firefox

build: all

ci: build test

generate_all: \
	generate_hub \
	generate_nodebase \
	generate_chrome \
	generate_firefox \
	generate_phantomjs

generate_hub:
	cd ./hub && ./generate.sh $(VERSION)

generate_nodebase:
	cd ./nodeBase && ./generate.sh $(VERSION)

generate_chrome:
	cd ./nodeChrome && ./generate.sh $(VERSION)

generate_firefox:
	cd ./nodeFirefox && ./generate.sh $(VERSION)

generate_phantomjs:
	cd ./nodePhantomjs && ./generate.sh $(VERSION)

base:
	cd ./base && docker build -t $(NAME)/base:$(VERSION) .

hub: base generate_hub
	cd ./hub && docker build -t $(NAME)/hub:$(VERSION) .

nodebase: base generate_nodebase
	cd ./nodeBase && docker build -t $(NAME)/node-base:$(VERSION) .

chrome: nodebase generate_chrome
	cd ./nodeChrome && docker build -t $(NAME)/node-chrome:$(VERSION) .

firefox: nodebase generate_firefox
	cd ./nodeFirefox && docker build -t $(NAME)/node-firefox:$(VERSION) .

phantomjs: nodebase generate_phantomjs
	cd ./nodePhantomjs && docker build -t $(NAME)/node-phantomjs:$(VERSION) .

tag_latest:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:latest
	docker tag $(NAME)/hub:$(VERSION) $(NAME)/hub:latest
	docker tag $(NAME)/node-base:$(VERSION) $(NAME)/node-base:latest
	docker tag $(NAME)/node-chrome:$(VERSION) $(NAME)/node-chrome:latest
	docker tag $(NAME)/node-firefox:$(VERSION) $(NAME)/node-firefox:latest
	docker tag $(NAME)/node-phantomjs:$(VERSION) $(NAME)/node-phantomjs:latest

release: tag_latest
	@if ! docker images $(NAME)/base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/hub | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/hub version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-chrome | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-chrome version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-firefox | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-firefox version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-phantomjs | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-phantomjs version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)/base
	docker push $(NAME)/hub
	docker push $(NAME)/node-base
	docker push $(NAME)/node-chrome
	docker push $(NAME)/node-firefox
	docker push $(NAME)/node-phantomjs
	@echo "*** Don't forget to create a tag. git tag v$(VERSION) && git push origin v$(VERSION)"

test:
	./test.sh

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
	tag_latest \
	test
