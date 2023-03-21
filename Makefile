#!/bin/bash
include .makerc

DOCKER_BE = ${PROJECT_NAME}-web
DOCKER_NETWORK = ${PROJECT_NAME}-network
OS := $(shell uname)

ifeq ($(OS),Linux)
	UID = $(shell id -u)
else
	true = $true
	UID = 1000
endif

help: ## Show this help message
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

run: ## Start the containers
	docker network create ${DOCKER_NETWORK} || echo $(true)
	U_ID=${UID} docker-compose up -d
	U_ID=${UID} docker run -p 8100:8100 -it ionic-app_ionic-app-web ash

stop: ## Stop the containers
	docker-compose stop

restart: ## Restart the containers
	$(MAKE) stop && $(MAKE) run

build: ## Rebuilds all the containers
	docker-compose stop && U_ID=${UID} docker-compose build && $(MAKE) run

web-logs: ## Tails the Symfony dev log
	docker exec -it --user ${UID} ${DOCKER_WEB} tail -f var/log/dev.log
# End backend commands

ssh-web-root: ## ssh's into the be container
	docker exec -it --user 0 ${DOCKER_WEB} bash

ssh-web: ## ssh's into the be container
	docker exec -it --user ${UID} ${DOCKER_WEB} bash

prune-all-containers:
	docker rm marcas-seniales-server-db
