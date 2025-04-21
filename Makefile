.PHONY: gen

CURRENT_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
VERSION := $(subst v,,$(CURRENT_TAG))
MAJOR := $(word 1,$(subst ., ,$(VERSION)))
MINOR := $(word 2,$(subst ., ,$(VERSION)))
PATCH := $(word 3,$(subst ., ,$(VERSION)))
NEXT_MINOR := $(shell echo $$(($(MINOR)+1)))
NEXT_TAG := v$(MAJOR).$(NEXT_MINOR).0
PROTO_FILES := $(shell find proto -name '*.proto')

help:
	@echo "gen - regenerate proto files"
	@echo "bump - push proto files with auto incrementing release version"
	@echo "list - list all .proto files in this repository"

list:
	@echo "Found proto files:"
	@echo $(PROTO_FILES) | tr ' ' '\n'

gen:
	@echo "Recompiling proto files..."
	export GOPATH=$HOME/go
	export PATH=$PATH:$GOPATH/bin
	protoc --go_out=gen/go --go-grpc_out=gen/go   --go_opt=paths=source_relative   --go-grpc_opt=paths=source_relative $(PROTO_FILES)
	protoc --grpc-gateway_out=gen/go --grpc-gateway_opt=paths=source_relative   --grpc-gateway_opt=generate_unbound_methods=true $(PROTO_FILES)

# Авто инкремент версии с отправкой в репозиторий
bump:
	@echo "Current version: $(CURRENT_TAG)"
	@echo "Next version: $(NEXT_TAG)"
	git add .
	git commit -m "Auto-commit before version bump" || true
	git tag -a $(NEXT_TAG) -m "Version $(NEXT_TAG)"
	git push origin master --tags
	@echo "Pushed new tag: $(NEXT_TAG)"