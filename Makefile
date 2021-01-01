default: run

build:
	docker build -t cs50/cli:focal .

rebuild:
	docker build --no-cache -t cs50/cli:focal .

run:
	docker run -it -P --rm --security-opt seccomp=unconfined -v "$(PWD)":/home/ubuntu/workspace cs50/cli:focal
