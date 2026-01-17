.PHONY: build up down bash server build_development_container  build_ci_container push_development_container push_ci_container prune prune_postgres prune_rubygems ci_rubocop ci_rspec ci_test

include .env

build: build_development_container

up:
	docker compose up -d
	docker compose exec web ./build.sh

down:
	docker compose down

bash:
	docker compose exec web bash

server:
	docker compose exec web foreman start --procfile Procfile.dev

web_server:
	docker compose exec web bundle exec rails s -b 0.0.0.0

stripe_server:
	docker compose exec web stripe login --api-key $$STRIPE_SECRET_KEY
	docker compose exec web stripe listen --forward-to localhost:3000/webhooks/stripe
	# Uses STRIPE_SECRET_KEY environment variable from docker-compose.yml
	# If authentication fails, try: docker compose exec web stripe login --interactive first

production_server:
	docker compose exec web bundle exec rails s -b 0.0.0.0 -e production

css_server:
	docker compose exec web foreman start --procfile Procfile.dev --formation css=1

background_jobs:
	docker compose exec web rails solid_queue:start

bundle:
	docker compose exec web bundle

console:
	docker compose exec web rails c

rspec:
	docker compose exec web rspec

guard:
	docker compose exec web bundle exec guard

rubocop:
	docker compose exec web rubocop

test: rubocop rspec

prune: down prune_postgres prune_rubygems

prune_postgres: down
	@volume_name="$(shell basename $(shell pwd))_db-data"; \
	echo "Removing $$volume_name"; \
	if [ "$$(docker volume ls -q --filter name=$$volume_name)" ]; then \
		docker volume rm $$volume_name; \
	else \
		echo "No postgres volume to remove"; \
	fi

prune_rubygems: down
	@volume_name="$(shell basename $(shell pwd))_rubygems"; \
	echo "Removing volume: $$volume_name"; \
	if [ "$$(docker volume ls -q --filter name=$$volume_name)" ]; then \
		docker volume rm $$volume_name; \
	else \
		echo "No rubygems volume to remove"; \
	fi

ci_rubocop:
	bundle exec rubocop

ci_rspec:
	bundle exec rake assets:precompile
	bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml

ci_test: ci_rubocop ci_rspec

load_backup:
	docker compose up -d
	docker compose exec web ./restore_latest_backup.sh
	docker compose exec web rails runner 'User.all.each { |u| u.password="testing"; u.save! }'

restore_latest_db: download_backup up

CONTAINER_ID := $(shell docker compose ps -q web)

speed_snail:
	docker update --cpus=0.3 $(CONTAINER_ID)

speed_flying_saucer:
	docker update --cpus=32 $(CONTAINER_ID)

build_args=$(shell grep -v '^#' .env | sed 's/^/--build-arg /')

build_development_container:
	docker build --target development -t ${APP_NAME}-development:${APP_VERSION} ${build_args} .
	docker tag ${APP_NAME}-development:${APP_VERSION} ${DOCKER_USERNAME}/${APP_NAME}:development-${APP_VERSION}

build_ci_container:
	docker build --target ci -t ${APP_NAME}-ci:${APP_VERSION} ${build_args}.
	docker tag ${APP_NAME}-ci:${APP_VERSION} ${DOCKER_USERNAME}/${APP_NAME}:ci-${APP_VERSION}

build_production_container:
	docker build --target production -t ${APP_NAME}-production:${APP_VERSION} ${build_args} .
	docker tag ${APP_NAME}-production:${APP_VERSION} ${DOCKER_USERNAME}/${APP_NAME}:production-${APP_VERSION}

images_ls:
	docker images | grep ${APP_NAME}

push_containers: push_development_container push_ci_container push_production_container

push_development_container: build_development_container
	docker push ${DOCKER_USERNAME}/${APP_NAME}:development-${APP_VERSION}

push_ci_container: build_ci_container
	docker push ${DOCKER_USERNAME}/${APP_NAME}:ci-${APP_VERSION}

push_production_container: build_production_container
	docker push ${DOCKER_USERNAME}/${APP_NAME}:production-${APP_VERSION}
