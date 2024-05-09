IMAGE := cs50/cli

.PHONY: default
default: run

build:
	docker build --build-arg VCS_REF=$(shell git rev-parse HEAD) --tag $(IMAGE) .

depends:
	pip3 install docker-squash

rebuild:
	docker build --build-arg VCS_REF=$(shell git rev-parse HEAD) --no-cache --tag $(IMAGE) .

run:
	docker run --env LANG=$(LANG) --env LOCAL_WORKSPACE_FOLDER="$(PWD)" --env WORKDIR=/mnt --interactive --publish-all --rm --security-opt seccomp=unconfined --tty --volume "$(PWD)":/mnt --volume /var/run/docker.sock:/var/run/docker-host.sock --workdir /mnt cs50/cli:$(TAG) bash --login || true

squash: depends
	docker-squash --tag $(IMAGE) $(IMAGE)
