default: run

build:
	docker build -t cs50/cli:minimal .

rebuild:
	docker build --no-cache -t cs50/cli:minimal .

run:
	docker run -it -P --rm --security-opt seccomp=unconfined -v "$(PWD)":/mnt cs50/cli:minimal bash --login || true
