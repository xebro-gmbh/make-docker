#--------------------------
# xebro GmbH - Docker - 0.0.1
#--------------------------

.PHONY: docker.build.dev docker.build.prod docker.init

# @see https://docs.docker.com/compose/environment-variables/envvars/
export COMPOSE_PROJECT_NAME=${XEBRO_PROJECT_NAME}

docker.restart: docker.network
	@${DOCKER_COMPOSE} ${DOCKER_FILES} down --remove-orphans
	@${DOCKER_COMPOSE} ${DOCKER_FILES} up -d

docker.build.prod: ## build all docker images located at ${XEBRO_MODULES_DIR}
	@find  ${XEBRO_MODULES_DIR} -type f -name "Dockerfile" | sed 's/.Dockerfile//' | sed 's/^docker\///' | sed 's|${XEBRO_MODULES_DIR}/||' | xargs -i  docker build . \
	--build-arg "USER_ID=$$(id -u)" \
	--build-arg "GROUP_ID=$$(id -g)" \
	--build-arg "UNAME=$$(whoami)" \
 	--rm --no-cache -f ${XEBRO_MODULES_DIR}/{}/Dockerfile -t ${XEBRO_PROJECT_NAME}_{}

docker.build.dev:
	@${DOCKER_COMPOSE} ${DOCKER_FILES} build --build-arg USER_ID=$$(id -u) --build-arg GROUP_ID=$$(id -g) --build-arg UNAME=$$(whoami)

docker.logs: ## show logs for all container
	@${DOCKER_COMPOSE} ${DOCKER_FILES} logs -f

docker.up: docker.network ## Start all docker container for development
	@${DOCKER_COMPOSE} ${DOCKER_FILES} up -d

docker.stop: ## Stop all docker container for development
	@${DOCKER_COMPOSE} ${DOCKER_FILES} stop

docker.down: ## Stop all docker container for development
	@${DOCKER_COMPOSE} ${DOCKER_FILES} down --remove-orphans

docker.clean: ## Remove all docker Container and clean up System
	@${DOCKER_COMPOSE} ${DOCKER_FILES} down --remove-orphans
	@docker images | awk '$$2 == "<none>" {print $$3}' | xargs docker image rm -f

docker.kill:
	@docker stop $$(docker ps -aq) | xargs docker rm

docker.pull: ## Update all docker container
	@${DOCKER_COMPOSE} ${DOCKER_FILES} pull

docker.cmd:
	${DOCKER_COMPOSE} $$CMD

docker.network:
	@docker network inspect ${XEBRO_PROJECT_NAME} >/dev/null 2>&1 || docker network create ${XEBRO_PROJECT_NAME}

docker.config: ## output the overall config for all included docker-compose.yaml files
	@${DOCKER_COMPOSE} ${DOCKER_FILES} config

docker.show.services: ## List all docker services
	@${DOCKER_COMPOSE} ${DOCKER_FILES} config --services

docker.docker-ignore:
	@touch .dockerignore
	$(call add_config,".dockerignore","docker/docker/.dockerignore")

docker.help:
	$(call add_help,./docker/docker/Makefile,"Docker")

.dockerignore: docker.docker-ignore
help: docker.help
start: docker.up
stop: docker.stop
build: docker.network
