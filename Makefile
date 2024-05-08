ifeq ($(shell uname -m), arm64)
    TAG := arm64
else
	TAG := amd64
endif

.PHONY: default
default: run

build:
	docker build --build-arg TAG=$(TAG) --build-arg VCS_REF=$(shell git rev-parse HEAD) --tag cs50/cli:$(TAG) .

depends:
	pip3 install docker-squash

rebuild:
	docker build --build-arg TAG=$(TAG) --build-arg VCS_REF=$(shell git rev-parse HEAD) --no-cache --tag cs50/cli:$(TAG) .

run:
	docker run --env LANG=$(LANG) --env LOCAL_WORKSPACE_FOLDER="$(PWD)" --env WORKDIR=/mnt --interactive --publish-all --rm --security-opt seccomp=unconfined --tty --volume "$(PWD)":/mnt --volume /var/run/docker.sock:/var/run/docker-host.sock --workdir /mnt cs50/cli:$(TAG) bash --login || true

squash: depends
	docker-squash --tag cs50/cli:$(TAG) cs50/cli:$(TAG)
