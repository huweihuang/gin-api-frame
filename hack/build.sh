#!/bin/bash
set -x
set -e

# 应用参数
APP="gin-api-frame"
BUILD_DIR=./_output
BASE_DIR="github.com/huweihuang/gin-api-frame"
VERSION_PACKAGE="${BASE_DIR}/pkg/version"

# 构建参数
TARGET_OS=linux
TARGET_ARCH=amd64
VERSION=$(git describe --abbrev=0 --always --tags | sed 's/-/./g')
GIT_COMMIT=$(git rev-parse HEAD)
GIT_TREE_STATE="clean"

GO_LDFLAGS="-X ${VERSION_PACKAGE}.gitVersion=${VERSION} \
	-X ${VERSION_PACKAGE}.gitCommit=${GIT_COMMIT} \
	-X ${VERSION_PACKAGE}.gitTreeState=${GIT_TREE_STATE} \
	-X ${VERSION_PACKAGE}.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

# 初始化构建目录
rm -fr $BUILD_DIR
mkdir -p "$BUILD_DIR/bin"

# 构建二进制
function gobuild () {
    bin=${1}
    echo "Building ${bin} now."
    CGO_ENABLED=0 GOOS="$TARGET_OS" GOARCH="$TARGET_ARCH" go build -i -v -ldflags "${GO_LDFLAGS}" \
        -o $BUILD_DIR/bin/"${bin}" ${BASE_DIR}/cmd/server
    if [[ $? -ne 0 ]]; then
        echo "Failed to build ${bin}"
        exit 1
    fi
    echo "Building ${bin} succeeded."
}

gobuild ${APP}
