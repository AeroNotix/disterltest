REBAR := ./rebar3

release:
	rm -rf _build && $(REBAR) release

build-docker:
	docker build -t disterltest .
