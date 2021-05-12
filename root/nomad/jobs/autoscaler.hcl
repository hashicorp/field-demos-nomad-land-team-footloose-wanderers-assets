job "autoscaler" {
    datacenters = ["demo"]
    type = "service"
    constraint {
        attribute = "${attr.driver.docker.os_type}"
        value = "linux"
    }
    group "autoscaler" {
        count = 1
        network {
            port "http" {
                to = 8080
            }
        }

        task "autoscaler" {
            driver = "docker"

            config {
                image   = "hashicorp/nomad-autoscaler-enterprise"
                command = "bin/nomad-autoscaler"
                args = [
                    "agent",
                    "-config",
                    "${NOMAD_TASK_DIR}/autoscaler.hcl",
                    "-http-bind-address",
                    "0.0.0.0",
                    "-http-bind-port",
                    "${NOMAD_PORT_http}"
                ]
                ports = ["http"]
            }

            template {
                destination = "${NOMAD_TASK_DIR}/autoscaler.hcl"
                data = <<EOH
nomad {
    address = "{{ with service "nomad-client" }}{{ with index . 0 }}http://{{.Address}}:{{.Port}}{{ end }}{{ end }}"
    namespace = "*"
}

apm "prometheus" {
    driver = "prometheus"
    config = {
        address = "{{ with service "prometheus" }}{{ with index . 0 }}http://{{.Address}}:{{.Port}}{{ end }}{{ end }}"
    }
}

dynamic_application_sizing {
    evaluate_after = "5m"
}
EOH
            }

            service {
                name = "nomad-autoscaler"
                port = "http"
                check {
                    type     = "http"
                    path     = "/v1/health"
                    interval = "5s"
                    timeout  = "2s"
                }
            }
        }
    }
}