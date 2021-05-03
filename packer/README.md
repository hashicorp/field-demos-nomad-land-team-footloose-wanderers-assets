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