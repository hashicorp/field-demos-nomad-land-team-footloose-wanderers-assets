job "podman-example" {
    datacenters = ["demo"]
    type        = "service"
    group "example" {
        count = 1
        network {
            port "db" {
                static = 6379
                to = 6379
            }
        }
        service {
            name = "redis"
            tags = ["linux", "redis"]
            port = "db"
            check_restart {
                grace = "600s"
            }
        }
        task "install-redis" {
            driver = "podman"
            config {
                image = "docker://redis:3.2"
                ports = ["db"]
            }
            resources {
                cpu = 1000 # Mhz
                memory = 512 # MB
            }
        }
    }
}