#!/bin/bash

# 获取脚本所在的目录
SCRIPT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# 日志文件夹和文件路径
LOGDIR="$SCRIPT_DIR/logs"
LOGFILE="$LOGDIR/install_docker.log"

if [[ $EUID -ne 0 ]]; then
   echo "这个脚本必须以 root 权限运行"
   exit 1
fi

# 检查并创建日志目录
mkdir -p "$LOGDIR"

# 写入日志函数
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S"): $@" | tee -a "$LOGFILE"
}

# 函数：检查 Docker 是否安装
check_docker_installed() {
    if ! command -v docker &> /dev/null; then
        log "Docker is not installed. Starting installation..."
        install_docker "$1" "$2"
    else
        log "Docker is already installed."
        echo -e "\e[31mdocker already exists \e[0m"
        exit 1
    fi
}

# 函数：离线安装 Docker
install_docker() {
    local os_version=$1
    local arch=$2
    log "Installing Docker for $os_version ($arch) from offline package..."
    
    case $os_version in
        ubuntu*|debian*)
            sudo apt install -y $SCRIPT_DIR/../install_packages/docker/$os_version/$arch/*.deb
            ;;
        centos*)
            sudo yum localinstall -y $SCRIPT_DIR/../install_packages/docker/$os_version/$arch/*.rpm
            ;;
        *)
            log "Unsupported OS version: $os_version"
            exit 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log "Docker installed successfully for $os_version ($arch)."
        ensure_docker_service_running
    else
        log "Failed to install Docker for $os_version ($arch)."
        echo -e "\e[31mFailed to install Docker for $os_version ($arch). \e[0m"
        exit 1
    fi
}

# 函数：确保 Docker 服务正在运行
ensure_docker_service_running() {
    log "Enabling and starting Docker service..."
    sudo systemctl daemon-reload
    sudo systemctl enable docker
    sudo systemctl start docker
    
    if [ $? -eq 0 ]; then
        log "Docker service started successfully."
    else
        log "Failed to start Docker service. Checking the status..."
        sudo systemctl status docker | tee -a "$LOGFILE"
        exit 1
    fi
}

# 函数：自动检测 OS 版本和架构
detect_os_version_and_arch() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_version="$ID$VERSION_ID"
        arch=$(uname -m)
        echo "$os_version $arch"
    else
        log "Unable to detect OS version."
        echo -e "\e[31Unable to detect OS version. \e[0m"
        exit 1
    fi
}

# 函数：列出所有支持的操作系统版本
list_supported_os() {
    log "Listing all supported OS versions..."
    for dir in "$SCRIPT_DIR/../install_packages/docker/"*; do
        if [ -d "$dir" ]; then
            os_version=$(basename "$dir")
            echo "$os_version"
        fi
    done
}

# 主流程
if [ "$1" == "install" ]; then
    if [ -n "$2" ] && [ -n "$3" ]; then
        os_version=$2
        arch=$3
    else
        read -r os_version arch <<< "$(detect_os_version_and_arch)"
        echo "Detected OS version: $os_version, Architecture: $arch"
        read -p "Do you want to continue with the installation? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            log "Installation cancelled."
            exit 0
        fi
    fi
    log "Starting script..."
    check_docker_installed "$os_version" "$arch"
    log "Script completed successfully."
    echo -e "\e[32mScript completed successfully. \e[0m"
elif [ "$1" == "list" ]; then
    list_supported_os
else
    echo "Usage: $0 install [os_version] [arch]"
    echo "       $0 list"
    exit 1
fi
