all: build test

build:
	@`npm bin`/coffee -c *.coffee

clean:
	rm -rf index.js

test:
	@`npm bin`/tap --tap test/*.coffee | `npm bin`/tap-min

coverage: build
	@coffee -c test
	@`npm bin`/browserify -t coffeeify -t coverify --bare test/*.js | node | `npm bin`/coverify

.PHONY: build clean test
