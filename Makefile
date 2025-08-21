.PHONY: help

IMAGE_NAME=kong-luarocks-builder

help: ## Help
	@echo "Targets:"
	@echo ""
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""

build:: ## build docker image
	docker build -t ${IMAGE_NAME} .

run:: ## start builed docker image
	docker run --rm -it ${IMAGE_NAME} bash