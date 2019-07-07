default: run

build:
	docker build -t cs50/cli .

rebuild:
	docker build --no-cache -t cs50/cli .

run:
	docker run -it -P --rm -v "$(PWD)":/mnt cs50/cli
