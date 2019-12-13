# 自动生成 Docker TLS 证书脚本

[中文](https://github.com/warriorBrian/auto-tls/blob/master/README_zh.md) | [English](https://github.com/warriorBrian/auto-tls/blob/master/README.md)

自动生成Docker TLS证书，使 Docker **跨平台**连接更安全！

## 使用方式

1. 编辑脚本，并编辑修改配置信息：

使用`vi/vim` 来打开 `auto-tls.sh`文件：

```sh
# 配置服务器IP，(必须):
ip="127.0.0.1"

# 配置密码信息 (必须):
password="any"

# 配置生成文件名 (必须):
filename="tls"

# default
days=1000
```

2. 配置docker文件

运行该脚本将自动生成两个tar存档：

* tls-server.tar.gz
* tls-client.tar.gz

**配置 docker TLS 传输的两种方式：**

1). 修改 `daemon.json`文件：

```sh
$ cd /etc/docker/
```

```sh
$ vi daemon.json

  {
	"tlsverify": true,
	"tlscacert": "/etc/cert path", 			// ca-xxx.pem
	"tlscert": "/etc/cert path",   			// server-cert-xxx.pem
	"tlskey": "/etc/cert path",		        // server-key-xxx.pem
	"hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]
  }  
```

```sh
$ systemctl daemon-reload
```

```sh
$ systemctl restart docker
```

-----------------------------------------------------------------------
> 提示: 如果重新启动期间发生错误，请修改文件：

**修改 `docker.service` 文件, 改文件位于： `/usr/lib/systemd/system/docker.service`**

```sh
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
# modify:
ExecStart=/usr/bin/dockerd
```
-----------------------------------------------------------------------

2). 修改 docker.service

```sh
$ vi /usr/lib/systemd/system/docker.service
```
```sh
# 添加修改代码:

  ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/etc/<cert path> --tlscert=/etc/<cert path> --tlskey=/etc/<cert path> -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock

$ systemctl daemon-reload

$ systemctl restart docker
```

3. 连接方式：

复制 `tls-client.tar.gz` 到另外一台服务器并解压，使用证书连接：

```sh
$ docker --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=key.pem -H tcp://ip:2375 ps
```