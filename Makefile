.PHONY: default
default: run

build:
	docker build --build-arg VCS_REF="$(shell git rev-parse HEAD)" --tag cs50/cli .
	$(MAKE) squash

depends:
	pip3 install docker-squash

rebuild:
	docker build --no-cache --tag cs50/cli .
	$(MAKE) squash

run:
	docker run --env LANG="$(LANG)" --interactive --publish-all --rm --security-opt seccomp=unconfined --tty --volume "$(PWD)":/home/ubuntu cs50/cli bash --login || true

squash: depends
	docker-squash --tag cs50/cli cs50/cli
