NAME := selion
VERSION := $(or $(VERSION),$(VERSION),'1.0.0')
PLATFORM := $(shell uname -s)
SELION_GRID_VERSION := $(or $(SELION_GRID_VERSION), $(SELION_GRID_VERSION), 'RELEASE')
REPO := $(or $(REPO), $(REPO), 'releases')
SELENIUM_VERSION := $(or $(SELENIUM_VERSION), $(SELENIUM_VERSION), '2.48')
SELENIUM_FIX := $(or $(SELENIUM_FIX), $(SELENIUM_FIX), '2')

all: hub chrome firefox phantomjs

build: all

ci: build test

generate_all: \
	generate_base \
	generate_hub \
	generate_nodebase \
	generate_chrome \
	generate_firefox \
	generate_phantomjs

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

generate_phantomjs:
	cd ./nodePhantomjs && ./generate.sh $(VERSION)

base: generate_base
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

check_release_version:
	@if [[ ! $(VERSION) =~ [[:digit:]].[[:digit:]].[[:digit:]] ]]; then echo "'$(VERSION)' is not an acceptable revision for a release target."; false; fi

release: check_release_version tag_latest deploy
	@echo "*** Don't forget to create a tag. git tag v$(VERSION) && git push origin v$(VERSION)"

check_dev_release_version:
		@if [[ $(VERSION) =~ [[:digit:]].[[:digit:]].[[:digit:]] ]]; then echo "'$(VERSION)' is not an acceptable revision for a develop target."; false; fi

dev_release: check_dev_release_version deploy

deploy:
	@if ! docker images $(NAME)/base:$(VERSION) | grep -q -F $(VERSION); then echo "$(NAME)/base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/hub:$(VERSION) | grep -q -F $(VERSION); then echo "$(NAME)/hub version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-base:$(VERSION) | grep -q -F $(VERSION); then echo "$(NAME)/node-base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-chrome:$(VERSION) | grep -q -F $(VERSION); then echo "$(NAME)/node-chrome version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-firefox:$(VERSION) | grep -q -F $(VERSION); then echo "$(NAME)/node-firefox version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-phantomjs:$(VERSION) | grep -q -F $(VERSION); then echo "$(NAME)/node-phantomjs version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/hub:$(VERSION)
	docker push $(NAME)/node-base:$(VERSION)
	docker push $(NAME)/node-chrome:$(VERSION)
	docker push $(NAME)/node-firefox:$(VERSION)
	docker push $(NAME)/node-phantomjs:$(VERSION)

test:
	VERSION=$(VERSION) ./test.sh

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
