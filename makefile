#!/usr/bin/make

SHELL = /bin/bash

# devcontainer user
USER_UID := $(shell id -u)
USER_GID := $(shell id -g)
USERNAME := $(shell whoami)-devcontainer
export USER_UID
export USER_GID
export USERNAME

up:
	docker-compose up -d
	
stop:
	docker-compose stop

rm:
	docker-compose rm

rmi:
	docker rmi web-summarizer-python web-summarizer-redis

.PHONY: up stop rm