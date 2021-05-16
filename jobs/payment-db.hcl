job "payment-db" {
    region = "west"
    datacenters = ["cloud"]
    type        = "service"
    group "payment-db" {
        count = 1
      	network {
      		port "db" {
              	static = 6379
            }
    	}
        service {
            name = "payment-db"
            tags = ["podman", "redis"]
            port = "db"
            check_restart {
                grace = "600s"
            }
        }
        task "redis" {
            driver = "podman"
            config {
                image = "redis:latest"
                ports = ["db"]
            }
            resources {
                cpu    = 256
                memory = 128
            }
        }
    }
}