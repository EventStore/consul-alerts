APP_NAME = consul-alerts
VERSION ?= latest
BUILD_ARCHS=linux-amd64 darwin-amd64 linux-arm64 darwin-arm64

all: clean build

clean:
	@echo "--> Cleaning build"
	@rm -rf ./build

prepare:
	@for arch in ${BUILD_ARCHS}; do \
		mkdir -p build/bin/$${arch}; \
	done
	@mkdir -p build/test
	@mkdir -p build/doc
	@mkdir -p build/tar

format:
	@echo "--> Formatting source code"
	@go fmt ./...

# TODO: fix tests
# test: prepare format
# 	@echo "--> Testing application"
# 	@go test -outputdir build/test ./...

build: prepare format
	@echo "--> Building local application"
	@go build -o build/bin/`uname -s`-`uname -p`/${VERSION}/${APP_NAME} -v .

build-all: prepare format
	@echo "--> Building all application"
	@for arch in ${BUILD_ARCHS}; do \
		echo "... $${arch}"; \
		GOOS=`echo $${arch} | cut -d '-' -f 1` \
		GOARCH=`echo $${arch} | cut -d '-' -f 2` \
		go build -mod=readonly -o build/bin/$${arch}/${VERSION}/${APP_NAME} . ; \
	done

package: build-all
	@echo "--> Packaging application"
	@for arch in ${BUILD_ARCHS}; do \
		tar czf build/tar/${APP_NAME}-${VERSION}-$${arch}.tgz -C build/bin/$${arch}/${VERSION} ${APP_NAME} ; \
		shasum -a 256 build/tar/${APP_NAME}-${VERSION}-$${arch}.tgz ; \
	done

# TODO: make this work
# release: package
# ifeq ($(VERSION) , latest)
# 	@echo "Github Release"
# 	@gh-release create EventStore/consul-alerts ${VERSION}
