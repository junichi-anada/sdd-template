SHELL := /bin/bash

.PHONY: init stack spec plan test ci-local up down logs ps artisan test-docker

init:
	bash scripts/init.sh

stack:
	@cat sdd.config.json

spec:
	@if [ -z "$$TITLE" ]; then echo "Usage: make spec TITLE='My feature'"; exit 2; fi
	bash scripts/gen.sh spec "$(TITLE)"

plan:
	@if [ -z "$$TITLE" ]; then echo "Usage: make plan TITLE='My plan'"; exit 2; fi
	bash scripts/gen.sh plan "$(TITLE)"

test:
	bash scripts/test.sh

ci-local:
	@echo "[ci-local] Running a subset of CI checks"
	@if [ -f composer.json ]; then composer validate --no-check-lock; fi
	$(MAKE) test

# Docker/Sail helpers
up:
	@if [ -f vendor/bin/sail ]; then bash vendor/bin/sail up -d; \
	elif [ -f sdd-app/vendor/bin/sail ]; then bash sdd-app/vendor/bin/sail up -d; \
	else echo "No Sail found. Initialize Laravel first (make init)."; fi

down:
	@if [ -f vendor/bin/sail ]; then bash vendor/bin/sail down; \
	elif [ -f sdd-app/vendor/bin/sail ]; then bash sdd-app/vendor/bin/sail down; \
	else echo "No Sail found."; fi

logs:
	@if [ -f vendor/bin/sail ]; then bash vendor/bin/sail logs -f; \
	elif [ -f sdd-app/vendor/bin/sail ]; then bash sdd-app/vendor/bin/sail logs -f; \
	else echo "No Sail found."; fi

ps:
	@if [ -f vendor/bin/sail ]; then bash vendor/bin/sail ps; \
	elif [ -f sdd-app/vendor/bin/sail ]; then bash sdd-app/vendor/bin/sail ps; \
	else echo "No Sail found."; fi

artisan:
	@if [ -z "$$CMD" ]; then echo "Usage: make artisan CMD='migrate'"; exit 2; fi
	@if [ -f vendor/bin/sail ]; then bash vendor/bin/sail artisan $(CMD); \
	elif [ -f sdd-app/vendor/bin/sail ]; then bash sdd-app/vendor/bin/sail artisan $(CMD); \
	else echo "No Sail found."; fi

test-docker:
	@if [ -f vendor/bin/sail ]; then bash vendor/bin/sail artisan test; \
	elif [ -f sdd-app/vendor/bin/sail ]; then bash sdd-app/vendor/bin/sail artisan test; \
	else echo "No Sail found."; fi
