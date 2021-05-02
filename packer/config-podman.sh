#!/bin/bash

###############################################################################################
#
#   Repo:           packer/server
#   File Name:      config-podman.sh
#   Author:         Patrick Gryzan
#   Company:        Hashicorp
#   Date:           April 2021
#   Description:    This is the configuration file for the server. Assume all the packages have been
#                   installed.
#
###############################################################################################

set -e

#############################################################################################################################
#   Setup Environment
#############################################################################################################################
REGION="east"
DATA_CENTER="dc1"
RETRY_JOIN=""
NAME=""

BIN="/usr/local/bin"

#   Grab Arguments
while getopts r:d:j:x: option
do
case "${option}"
in
r) REGION=${OPTARG};;
d) DATA_CENTER=${OPTARG};;
j) RETRY_JOIN=${OPTARG};;
x) NAME=${OPTARG};;
esac
done

touch ~/.bashrc
export PATH=$PATH:${BIN}
echo -e "export PATH=$PATH:${BIN}" >> ~/.bashrc

#############################################################################################################################
#   Podman
#############################################################################################################################
cat <<-EOF > /etc/systemd/system/podman.service
[Unit]
Description="Podman API"
Documentation=https://github.com/containers/podman/blob/master/docs/source/markdown/podman-system-service.1.md

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/podman system service -t 0

[Install]
WantedBy=multi-user.target
EOF

#   Enable the Service
echo "starting podman api service"
sudo systemctl enable podman
sudo service podman start

#############################################################################################################################
#   Consul
#############################################################################################################################
CONSUL_CONFIG="/etc/consul.d"
CONSUL_PACKAGE="/opt/consul"

sudo mkdir --parents ${CONSUL_CONFIG} ${CONSUL_PACKAGE}

cat <<-EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=${CONSUL_CONFIG}/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=${BIN}/consul agent -config-dir=${CONSUL_CONFIG}/
ExecReload=${BIN}/consul reload
ExecStop=${BIN}/consul leave
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

cat <<-EOF > ${CONSUL_CONFIG}/consul.hcl
datacenter = "${DATA_CENTER}"
data_dir = "${CONSUL_PACKAGE}/"
log_file = "${CONSUL_PACKAGE}/"
client_addr = "0.0.0.0"
retry_interval = "5s"
bind_addr = "{{ GetInterfaceIP \"eth0\" }}"
retry_join = [ "${RETRY_JOIN}" ]
recursors = [ "8.8.8.8", "8.8.4.4" ]
connect {
    enabled = true
}
ports {
    grpc = 8502
}
EOF

sudo useradd --system --home ${CONSUL_CONFIG} --shell /bin/false consul
sudo chown --recursive consul:consul ${CONSUL_CONFIG} ${CONSUL_PACKAGE}
sudo chmod 640 ${CONSUL_CONFIG}/consul.hcl
sudo chmod -R 755 ${CONSUL_PACKAGE}

#   Enable the Service
echo "starting consul server"
sudo systemctl enable consul
sudo service consul start

#   Configure Port Forwarding
echo "configuring bind port forwarding"
sudo yum install bind bind-utils -y

cat <<-EOF > /etc/named.conf
options {
    listen-on port 53 { 127.0.0.1; };
    listen-on-v6 port 53 { ::1; };
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query     { localhost; };
    recursion yes;

    dnssec-enable no;
    dnssec-validation no;

    /* Path to ISC DLV key */
    bindkeys-file "/etc/named.iscdlv.key";

    managed-keys-directory "/var/named/dynamic";
};

include "/etc/named/consul.conf";
EOF

cat <<-EOF > /etc/named/consul.conf
zone "consul" IN {
    type forward;
    forward only;
    forwarders { 127.0.0.1 port 8600; };
};
EOF

sudo systemctl enable named
sudo systemctl restart named
sudo firewall-cmd --permanent --add-port=53/udp
sudo firewall-cmd --reload

#   Added to resolve names for centos os at command line
sudo sed -i '3 i nameserver 127.0.0.1' /etc/resolv.conf
sudo systemctl restart systemd-resolved

#############################################################################################################################
#   Nomad
#############################################################################################################################
NOMAD_CONFIG="/etc/nomad.d"
NOMAD_PACKAGE="/opt/nomad"
NOMAD_PLUGINS="${NOMAD_PACKAGE}/plugins"

cat <<-EOF > /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

# When using Nomad with Consul it is not necessary to start Consul first. These
# lines start Consul before Nomad as an optimization to avoid Nomad logging
# that Consul is unavailable at startup.
Wants=consul.service
After=consul.service

[Service]
User=root
Group=root
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=${BIN}/nomad agent -config ${NOMAD_CONFIG}/nomad.hcl
KillMode=process
KillSignal=SIGINT
LimitNOFILE=65536
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitInterval=10
TasksMax=infinity
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
EOF

cat <<-EOF > ${NOMAD_CONFIG}/nomad.hcl
name        = "${x}"
region      = "${REGION}"
datacenter  = "${DATA_CENTER}"
data_dir    = "${NOMAD_PACKAGE}"
log_file    = "${NOMAD_PACKAGE}"
bind_addr   = "0.0.0.0"

client {
    enabled = true
}

consul {
    address = "127.0.0.1:8500"
}

vault {
    enabled = true
    address = "http://active.vault.service.consul:8200"
}

plugin "nomad-driver-podman" {
    config {
        volumes {
            enabled      = true
            selinuxlabel = "z"
        }
    }
}
EOF

#   Enable the Service
echo "starting nomad server"
sudo systemctl enable nomad
sudo service nomad start

exit 0