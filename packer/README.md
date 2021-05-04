# terraform

This where all of the demo configuration files live for each platform.

10.64.0.254

unbuntu - resolvectl status | grep -1 'DNS Server'
   DNSSEC supported: no
  Current DNS Server: 10.64.0.254
         DNS Servers: 10.64.0.254
          DNS Domain: 3mwhono3avi4.svc.cluster.local
--
    DNSSEC supported: no
  Current DNS Server: 169.254.169.254
         DNS Servers: 169.254.169.254
          DNS Domain: 3mwhono3avi4.svc.cluster.local

windows - ipconfig /all

nomad job run product-db.nomad
nomad job run legacy-app.nomad

packer build -force -var-file="variables.pkrvars.hcl" .

sudo vi variables.pkrvars.hcl

instruqt-hashicorp

export SSHPASS=Passw0rd!
IFS=' ' read -r -a array <<< "$(gcloud compute instances list | grep on-prem-windows)"
export WINDOWS_IP="${array[3]}"
sshpass -e ssh -o StrictHostKeyChecking=no hashistack@$WINDOWS_IP

cat consul/consul_client.hcl

10.132.0.61

dig @localhost -p 53 active.vault.service.consul. +short

dig 10.132.1.7 -p 53 active.vault.service.consul. +short

ip acat 

stop-service -name "consul"
get-service -name "consul"
((Get-Content -path consul_client.hcl -Raw) -replace 'bind_addr = \"{{ GetInterfaceIP \\\"Ethernet\\\" }}\"', 'bind_addr = "0.0.0.0"') | Set-Content -Path consul_client.hcl
Add-Content -Path ./consul_client.hcl -Value 'advertise_addr_ipv4 = "{{ GetInterfaceIP \"Ethernet\" }}"'
start-service -name "consul"

curl --data @redis.json http://127.0.0.1:8500/v1/catalog/register

Test-NetConnection -ComputerName 10.132.0.61 -Port 8600

iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
systemctl restart systemd-resolved

c:/windows/system32/consul.exe agent -config-dir=c:/users/hashistack/consul/

Get-NetTCPConnection

Get-NetAdapterBinding
Disable-NetAdapterBinding –InterfaceAlias “Ethernet” –ComponentID ms_tcpip6

((Get-Content -path consul_client.hcl -Raw) -replace 'bind_addr = \"{{ GetInterfaceIP \\\"Ethernet\\\" }}\"', 'bind_addr = "0.0.0.0"') | Set-Content -Path consul_client.hcl

((Get-Content -path consul_client.hcl -Raw) -replace 'client_addr = "0.0.0.0"', "") | Set-Content -Path consul_client.hcl
client_addr = "0.0.0.0"

10.132.0.189
((Get-Content -path consul.conf -Raw) -replace '127.0.0.1', '10.132.0.189') | Set-Content -Path consul.conf
((Get-Content -path consul.conf -Raw) -replace '8600', '53') | Set-Content -Path consul.conf

+=l<bBNFlKKA<[k

nslookup consul.service.consul

Get-DnsClientServerAddress
Set-DnsClientServerAddress -InterfaceIndex 8 -ServerAddresses ("127.0.0.1", "10.64.0.254")

sudo /hashistack/config.sh -r 'west' -d 'cloud' -j '10.132.0.95' -x 'cloud-docker' -q '"10.64.0.254", "169.254.169.254", "8.8.8.8", "8.8.4.4"'