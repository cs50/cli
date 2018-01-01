default: run

build:
	docker build -t cs50/cli:ubuntu .

rebuild:
	docker build --no-cache -t cs50/cli:ubuntu .

run:
	docker run --interactive --publish-all --rm --tty --volume "$(PWD)":/home/ubuntu/workspace cs50/cli:ubuntu
