default: build run

build:
	docker build --pull -t cs50/cli .

rebuild:
	docker build --no-cache -t cs50/cli .

run:
	#docker run -i --name cli50 --rm -v "$(PWD)"/:/home/ubuntu/workspace -t cs50/cli:ubuntu
	docker run -i --name cli50 --rm -v "$(PWD)"/:/root -t cs50/cli
