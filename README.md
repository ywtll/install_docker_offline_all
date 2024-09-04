# install_docker_offine
国内在linux上安装docker是一件没苦硬吃的事，不如自己动手丰衣足食，一键离线docker安装脚本，这里提供绝大部分的linux系统和版本，和一键离线部署的脚本，并保持更新...


## 版本
|os_version|arch|more|
|---|---|---|
|ubuntu20.04|arm64 amd64||
|ubuntu18.04|arm64 amd64||
|ubuntu16.04|arm64 amd64||
|centos9|aarch64 x86_64||
|centos8|aarch64 x86_64||
|centos7|aarch64 x86_64|没有build和compose|
|debian12|arm64 amd64||
|debian11|arm64 amd64||
|debian10|arm64 amd64||


## 使用教程
```sh
# 提权
chmod +x ./scripts/install_docker_offine.sh
# 离线安装
./scripts/install_docker_offine.sh install [os_version] [arch]
# 自动识别版本安装
./scripts/install_docker_offine.sh install
# 列出可安装的系统
./scripts/install_docker_offine.sh install
```


## 其他
全部下载文件较大，可以进入install_packages/docker目录仔细寻找要下载的内容
如需要其他版本，发issues，应该会一直更新