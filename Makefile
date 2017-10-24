
clean:
	rm -f plainflow*.gem

test:
	rake spec

build:
	gem build ./plainflow-ruby.gemspec

.PHONY: test build
