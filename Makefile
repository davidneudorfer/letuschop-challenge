export SHELL := /bin/bash

WORKDIR=$(pwd)/../

# Platform-specific variables
# ---------------------------
PLATFORM_INFO:= $(shell python -m platform)
ifeq ($(findstring Ubuntu,$(PLATFORM_INFO)),Ubuntu)
	PLATFORM:= ubuntu
endif
ifeq ($(findstring Darwin,$(PLATFORM_INFO)),Darwin)
	PLATFORM:= darwin
endif

# Common targets
# --------------

build: bucket aws ## first time setup to ensure terraform config bucket exists

aws: ami terraform ## run both packer and terraform

terraform: global-plan global-apply west-plan west-apply prod-plan prod-apply ## terraform all environments

global: global-plan global-apply # plan and apply global env

west: west-plan west-apply # plan and apply us-west-1 env

prod: prod-plan prod-apply # plan and apply prod env

destroy: prod-plan-destroy prod-apply west-plan-destroy west-apply global-plan-destroy global-apply ## destroy all environments

bucket:
	@BUCKET="$$(aws s3 ls | grep letuschop-terraform | wc -l)"; \
	if [[ $$? -eq 1 ]]; then \
	  echo "$$BUCKET"; \
		aws s3 mb s3://letuschop-terraform; \
	else \
		echo "bucket already exists"; \
	fi

ami: ## build an ami with packer
	cd local && docker-compose run letuschop -d ami

global-setup:
	cd local && docker-compose run letuschop -d global-setup

global-plan: global-setup ## terraform plan global env
	cd local && docker-compose run letuschop -d global-plan

global-plan-destroy: global-setup
	cd local && docker-compose run letuschop -d global-destroy

global-apply: ## terraform apply an existing plan global env
	cd local && docker-compose run letuschop -d global-apply

west-setup:
	cd local && docker-compose run letuschop -d west-setup

west-plan: west-setup ## build plan for west env
	cd local && docker-compose run letuschop -d west-plan

west-plan-destroy: west-setup
	cd local && docker-compose run letuschop -d west-plan-destroy

west-apply: ## apply existing terraform.tfplan to west env
	cd local && docker-compose run letuschop -d west-apply

prod-setup:
	cd local && docker-compose run letuschop -d prod-setup

prod-plan: prod-setup ## build plan for prod env
	cd local && docker-compose run letuschop -d prod-plan

prod-plan-destroy: prod-setup
	cd local && docker-compose run letuschop -d prod-plan-destroy

prod-apply: ## apply existing terraform.tfplan to prod env
	cd local && docker-compose run letuschop -d prod-apply

# PHONY (non-file) Targets
# ------------------------
.PHONY: help global-setup west-setup prod-setup global-plan-destroy
	west-plan-destroy prod-plan-destroy
# `make help` -  see http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# ------------------------------------------------------------------------------------

.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
