#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PACKAGE=$(awk -F': ' '/^Package:/{print $2}' control)
NAME=$(awk -F': ' '/^Name:/{print $2}' control)
VERSION=$(awk -F': ' '/^Version:/{print $2}' control)

run_command() {
    local cmd="$1"
    local log_file
    log_file=$(mktemp)

    eval "$cmd" > "$log_file" 2>&1
    local status=$?

    if [ $status -ne 0 ]; then
        echo -e "${RED}命令执行失败! 错误日志:${NC}"
        cat "$log_file"
    fi

    rm -f "$log_file"
    return $status
}

echo -e "${BLUE}==>${NC} 开始清理..."
if run_command "make clean"; then
    echo -e "${GREEN}==>${NC} 清理完成"
else
    echo -e "${RED}==>${NC} 清理失败"
fi

echo -e "${BLUE}==>${NC} 开始标准打包..."
if run_command "make package FINALPACKAGE=1 RELEASE=1"; then
    echo -e "${GREEN}==>${NC} 标准打包完成"
else
    echo -e "${RED}==>${NC} 标准打包失败"
fi

echo -e "${BLUE}==>${NC} 开始打包 roothide ..."
if run_command "make package SCHEME=roothide FINALPACKAGE=1 RELEASE=1"; then
    echo -e "${GREEN}==>${NC} 打包 roothide 完成"
else
    echo -e "${RED}==>${NC} 打包 roothide 失败"
fi

echo -e "${BLUE}==>${NC} 开始 rootless 打包..."
if run_command "make package SCHEME=rootless INSTALL=1 FINALPACKAGE=1 RELEASE=1"; then
    echo -e "${GREEN}==>${NC} rootless 打包完成"
else
    echo -e "${RED}==>${NC} rootless 打包失败"
fi

echo -e "${GREEN}==>${NC} 所有任务完成！"

mkdir -p packages
cd packages || exit 1
for f in "${PACKAGE}_${VERSION}_iphoneos-arm"*.deb; do
    if [ -f "$f" ]; then
        arch=${f##*arm}
        arch=${arch%%.deb}
        mv "$f" "${NAME}_${VERSION}-arm${arch}.deb"
    fi
done

cp "../.theos/obj/${NAME}.dylib" . 2>/dev/null || true
