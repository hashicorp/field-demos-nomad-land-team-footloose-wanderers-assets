job "test-product-api" {
    datacenters = ["demo"]
    type     = "service"

    constraint {
        attribute = "${attr.kernel.name}"
        value = "linux"
    }

    group "product-api" {
        count = 1

        network {
            port "http_port" {
                static = 9090
            }
        }

        restart {
            attempts = 10
            interval = "5m"
            delay    = "25s"
            mode     = "delay"
        }

        task "product-api" {
            driver = "docker"

            # Creation of the template file defining how the API will access the database
                template {
                    destination   = "/secrets/db-creds"
                    data = <<EOF
    {
        "db_connection": "host=postgres.service.consul port=5432 user=root password=password dbname=products sslmode=disable",
        "bind_address": ":9090",
        "metrics_address": ":9103"
    }
        EOF
            }

                # Task relevant environment variables necessary
                env {
                    CONFIG_FILE = "/secrets/db-creds"
                }

                # Product-api Docker image location and configuration
                config {
                    image = "hashicorpdemoapp/product-api:v0.0.15"
                    dns_servers = ["172.17.0.1"]
                    ports = ["http_port"]
                }

                # Host machine resources required
                resources {
                    cpu    = 100
                    memory = 300
                }

            # Service definition to be sent to Consul with corresponding health check
                service {
                    name = "product-api-server"
                    port = "http_port"
                    tags = ["product-api"]
                    check {
                    type     = "http"
                    path     = "/health"
                    interval = "10s"
                    timeout  = "2s"
                }
            }
        } # end product-api task
    } # end product-api group
}