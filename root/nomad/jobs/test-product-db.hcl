job "test-product-db" {
    datacenters = ["demo"]
    type     = "service"

    constraint {
        attribute = "${attr.kernel.name}"
        value = "linux"
    }

    group "postgres" {
        count = 1

        network {
            port "db" {
                static = 5432
            }
        }

        # Host volume on which to store Postgres Data.  Nomad will confirm the client offers the same volume for placement.
        volume "pgdata" {
            type      = "host"
            read_only = false
            source    = "pgdata"
        }

        restart {
            attempts = 10
            interval = "5m"
            delay = "25s"
            mode = "delay"
        }

        #Actual Postgres task using the Docker Driver
        task "postgres" {
            driver = "docker"

            volume_mount {
                volume      = "pgdata"
                destination = "/var/lib/postgresql/data"
                read_only   = false
            }

            # Postgres Docker image location and configuration
            config {
                image = "hashicorpdemoapp/product-api-db:v0.0.15"
                dns_servers = ["172.17.0.1"]
                network_mode = "host"
                ports = ["db"]
            }

            # Task relevant environment variables necessary
            env {
                POSTGRES_USER="root"
                POSTGRES_PASSWORD="password"
                POSTGRES_DB="products"
            }

            logs {
                max_files     = 5
                max_file_size = 15
            }

            # Host machine resources required
            resources {
                cpu = 300
                memory = 512
            }

            # Service definition to be sent to Consul
            service {
                name = "postgres"
                port = "db"
                tags = ["postgres"]

                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "10s"
                    timeout  = "2s"
                }
            }
        } # end postgres task
    } # end postgres group
}