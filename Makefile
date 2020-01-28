.PHONY: build
build: Gemfile.lock
	docker build -t network-tools .

Gemfile.lock: Gemfile
	docker run --rm -v "$$PWD":/usr/src/app -w /usr/src/app ruby:2.7.0-buster bundle install

graph.png: build
	docker run --rm -it -v "$$PWD":/usr/src/app/out network-tools rake graph