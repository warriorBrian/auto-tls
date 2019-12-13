# Automatically generate Docker TLS certificate script

[中文](https://github.com/warriorBrian/auto-tls/blob/master/README_zh.md) | [English](https://github.com/warriorBrian/auto-tls/blob/master/README_zh.md)

Automatically generate Docker TLS certificate to make docker cross-platform connection more secure!

## How to use

### 1. Edit the script, changes need to be configured

Open the `auto-tls.sh` file using `vi/vim`, Example:

```sh
# configure IP *(Required):
ip="127.0.0.1"

# configure password *(Required):
password="any"

# configure filename *(Required):
filename="tls"

# default
days=1000
```

### 2. Configure docker file

The script will automatically generate two tar archives:

* tls-server.tar.gz
* tls-client.tar.gz

**Configure docker TLS two ways:**

#### 1). Modify the `daemon.json` file

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
> TIPS: If an error occurs during restart, modify the file:

**Modify the `docker.service` file, which is located at `/usr/lib/systemd/system/docker.service`**

```sh
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
# modify:
ExecStart=/usr/bin/dockerd
```
-----------------------------------------------------------------------

#### 2). Modify docker.service

```sh
$ vi /usr/lib/systemd/system/docker.service
```
```sh
# Add modification code:

  ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/etc/<cert path> --tlscert=/etc/<cert path> --tlskey=/etc/<cert path> -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock

$ systemctl daemon-reload

$ systemctl restart docker
```

### 3. Connection method

Copy `tls-client.tar.gz` to another server, unzip it, and connect with a certificate

```sh
$ docker --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=key.pem -H tcp://ip:2375 ps
```