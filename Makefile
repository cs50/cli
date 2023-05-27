default: run

build:
	docker build --build-arg VCS_REF="$(shell git rev-parse HEAD)" -t cs50/cli .

rebuild:
	docker build --no-cache -t cs50/cli .

run:
	docker run --env LANG="$(LANG)" -it -P --rm --security-opt seccomp=unconfined -v "$(PWD)":/home/ubuntu cs50/cli bash --login || true
