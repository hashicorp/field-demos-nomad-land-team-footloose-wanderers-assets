job "sqlserver" {
    datacenters = ["demo"]
    type        = "service"
    constraint {
        attribute = "${attr.kernel.name}"
        value = "windows"
    }
    group "sqlserver" {
        count = 1
        network {
            port "http" {
                static = 1433
                to = 1433
            }
        }
        service {
            name = "sqlserver"
            tags = ["windows", "sqlserver"]
            port = "http"
            check_restart {
                grace = "600s"
            }
        }
        task "sqlserver" {
            driver = "docker"
            config {
                image = "pgryzan/sqlserver-express:20200923"
                ports = ["http"]
                force_pull = false
            }
            resources {
                cpu = 2000 # Mhz
                memory = 2048 # MB
            }
        }
    }
}