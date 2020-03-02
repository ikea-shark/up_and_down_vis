# Makefile for up_and_down_vis Project

SHELL              := /bin/bash
GITROOT            := $(shell git rev-parse --show-toplevel)
PROJECT_NAME       := up_and_down_vis

.DEFAULT_GOAL      := help
DATABASE           := sqlite
ORGANIZATION       := tesri
DB_VERSION         ?= 1.0
SERVICE_VERSION    ?= 1.0
SAVE_METHOD        := txt sql

# Change here
YEAR               ?= 2009
LIMIT              ?= 300
ALL                ?= true
SAVE               ?= sql

# Font
BOLD              := \033[1m
GREEN             := \033[1;32m
NORMAL            := \033[0m

.PHONY: help
help:
	@echo
	@echo -e "       $(BOLD)How to use this Project$(NORMAL)"
	@echo
	@echo -e "   $(GREEN)save-txt$(NORMAL)     Save data as txt."
	@echo -e "   $(GREEN)save-sql$(NORMAL)     Save data as sqlite."
	@echo -e "   $(GREEN)build$(NORMAL)        Build docker image."


define SAVE
.PHONY: save-$(1)
save-$(1):
	@if [ '$(ALL)' == 'false' ]; then \
		python3 data.py --year '$(YEAR)' --limit '$(LIMIT)' --save '$(1)'; \
	else \
		python3 data.py --year '$(YEAR)' --limit '$(LIMIT)' --save '$(1)' --all; \
	fi
endef
$(foreach mode,$(SAVE_METHOD),$(eval $(call SAVE,$(mode))))

# TODO(alexsu): build app
.PHONY: build
build:
	@docker build . \
		-t $(ORGANIZATION)/$(PROJECT_NAME):$(SERVICE_VERSION)

# TODO(alexsu) generate data in container
define DATA
.PHONY: data-$(1)
data-$(1):
	@if [ '$(ALL)' == 'false' ]; then \
		docker run \
			-it \
			$(ORGANIZATION)/$(PROJECT_NAME):$(SERVICE_VERSION) \
			/bin/bash -c "python3 data.py --year '$(YEAR)' --limit '$(LIMIT)' --save $(1)"; \
	else \
		docker run \
			$(ORGANIZATION)/$(PROJECT_NAME):$(SERVICE_VERSION) \
			python3 data.py --year '$(YEAR)' --limit '$(LIMIT)' --save '$(1)' --all; \
	fi
endef
$(foreach mode,$(SAVE_METHOD),$(eval $(call DATA,$(mode))))
