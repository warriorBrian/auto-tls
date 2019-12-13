#!/bin/sh

# -------------------------------------------------------------
# Docker TLS certificate sign script
# -------------------------------------------------------------

# -------------------------------------------------------------
# Configure certificate information
# Author Brian

# configure IP *(Required):
ip=""

# configure password *(Required):
password=""

# configure filename *(Required):
filename=""

# default
days=1000

# -------------------------------------------------------------

# delete all .pem file
rm -rf ./*.pem

# generate CA key
echo -e "\033[34m generate CA key \033[0m"

openssl genrsa -aes256 -passout "pass:$password" -out "ca-key-$filename.pem" 4096

# generate CA certificate
echo -e "\033[34m generate CA certificate \033[0m"

openssl req -new -x509 -days $days -key "ca-key-$filename.pem" -sha256 -passin "pass:$password" -subj "/CN=$ip" -out "ca-$filename.pem"

# generate Server key
echo -e "\033[34m generate server key \033[0m"

openssl genrsa -out "server-key-$filename.pem" 4096

# generate Server certificate
echo -e "\033[34m generate server certificate \033[0m"

openssl req -new -sha256 -key "server-key-$filename.pem" -subj "/CN=$ip" -out server.csr

echo "subjectAltName = IP:$ip,IP:127.0.0.1" >> extfile.cnf
echo "extendedKeyUsage = serverAuth" >> extfile.cnf

openssl x509 -req -days $days -sha256 -in server.csr -passin "pass:$password" -CA "ca-$filename.pem" -CAkey "ca-key-$filename.pem" -CAcreateserial -out "server-cert-$filename.pem" -extfile extfile.cnf

rm -rf extfile.cnf

# generate Client certificate
echo -e "\033[34m generate client certificate \033[0m"

openssl genrsa -out "key-$filename.pem" 4096
openssl req -subj "/CN=client" -new -key "key-$filename.pem" -out client.csr
echo extendedKeyUsage = clientAuth >> extfile.cnf
openssl x509 -req -days $days -sha256 -in client.csr -passin "pass:$password" -CA "ca-$filename.pem" -CAkey "ca-key-$filename.pem" -CAcreateserial -out "cert-$filename.pem" -extfile extfile.cnf

# delete csr file
echo -e "\033[34m delete unnecessary files \033[0m"

rm -rf server.csr client.csr extfile.cnf "ca-$filename.srl"

# write readme file

cat << EOF > README-SERVER.txt

1. Configure the docker daemon.json file

$ cd /etc/docker/

$ vi daemon.json

  {
	"tlsverify": true,
	"tlscacert": "/etc/cert path", 			// ca-xxx.pem
	"tlscert": "/etc/cert path",   			// server-cert-xxx.pem
	"tlskey": "/etc/cert path",		        // server-key-xxx.pem
	"hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]
  }  

$ systemctl daemon-reload

$ systemctl restart docker

----------------------------------

2. Modify docker.service

	tlscacert: ca-xxx.pem 
	tlscert:   server-cert-xxx.pem
	tlskey:    server-key-xxx.pem

$ vi /usr/lib/systemd/system/docker.service

Add modification code:

  ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/etc/<cert path> --tlscert=/etc/<cert path> --tlskey=/etc/<cert path> -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock

$ systemctl daemon-reload

$ systemctl restart docker

EOF

cat << EOF > README-CLIENT.txt

Connection method

Upload the certificate to the specified server

docker --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=key.pem -H tcp://ip:2375 ps

EOF

# package file
echo -e "\033[34m Package upload file: client \033[0m"
tar zcvf tls-client.tar.gz "ca-$filename.pem" "cert-$filename.pem" "key-$filename.pem" "README-CLIENT.txt"

echo -e "\033[34m Package upload file: server \033[0m"
tar zcvf tls-server.tar.gz "ca-$filename.pem" "server-cert-$filename.pem" "server-key-$filename.pem" "README-SERVER.txt"

# sleep 2 second
sleep 2

# delete all suffix pem file
echo -e "\033[34m delete all suffix pem file and txt file \033[0m"
rm -rf ./*.pem ./*.txt

echo -e "\e[1;32m All operation is done! \e[0m"
