job "alertmanager" {
    datacenters = ["demo"]
    type = "service"
    constraint {
        attribute = "${attr.driver.docker.os_type}"
        value = "linux"
    }
    group "alerting" {
        count = 1

        network {
            port "alertmanager_ui" {
                to = 9093
            }
        }

        restart {
            attempts = 2
            interval = "30m"
            delay = "15s"
            mode = "fail"
        }
        ephemeral_disk {
            size = 300
        }

        task "alertmanager" {
            driver = "docker"
            config {
                image = "prom/alertmanager"
                ports = ["alertmanager_ui"]
            }

            service {
                name = "alertmanager"
                port = "alertmanager_ui"
                check {
                    name     = "alertmanager_ui port alive"
                    type     = "http"
                    path     = "/-/healthy"
                    interval = "10s"
                    timeout  = "2s"
                }
            }
        }
    }
}