all: build test

build:
	@`npm bin`/coffee -c *.coffee

clean:
	rm -rf index.js

test:
	@`npm bin`/tap --tap test | `npm bin`/tap-min

.PHONY: build clean test
