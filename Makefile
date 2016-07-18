default: build run

build:
	docker build --pull -t cs50/cli:latest .
	docker build --pull -t cs50/cli:ubuntu .

rebuild:
	docker build --no-cache -t cs50/cli:ubuntu .

run:
	docker run -i --name cli50 --rm -v "$(PWD)"/:/home/ubuntu/workspace -t cs50/cli:ubuntu
