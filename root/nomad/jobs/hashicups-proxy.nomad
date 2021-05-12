job "hashicups-proxy" {
    datacenters = ["cloud"]
    group "hashicups-proxy" {
        count = 1
        task "hashicups-proxy" {
            driver = "docker"
            constraint {
                attribute = "${attr.os.name}"
                value = "ubuntu"
            }
            config {
                image = "pgryzan/hashicups-app:20200925"
                volumes = ["local/default.conf:/etc/nginx/conf.d/default.conf"]
                dns_servers = ["127.0.0.1"]
            }
            template {
                data = <<EOT
server {
    listen       80;
    server_name  localhost;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host \$host;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

{{ with service "product-api" }}
{{ with index . 0 }}
    location /api/product {
        proxy_pass http://{{ .Address }}:9090/api;
    }
{{ end }}
{{ end }}

{{ with service "payment-api" }}
{{ with index . 0 }}
    location /api/payment {
        proxy_pass http://{{ .Address }}:8080;
    }
{{ end }}
{{ end }}

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOT
                destination = "local/default.conf"
            }
            resources {
                network {
                    mbits = 10
                    port "http" {
                        static = 80
                    }
                }
            }
            service {
                name = "hashicups-proxy"
                port = "http"
                check {
                    type = "http"
                    port = "http"
                    path = "/"
                    interval = "10s"
                    timeout = "4s"
                }
            }
        }
    }
}