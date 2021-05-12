job "legacy-app" {
    datacenters = ["demo"]
    type = "service"
    constraint {
        attribute = "${attr.kernel.name}"
        value = "windows"
    }
    group "legacy-app" {
        count = 1
      	network {
      		port "http" {
              	static = 9090
            }
    	}
        task "legacy-app" {
            driver = "win_iis"

            artifact {
                source = "https://github.com/hashicorp/field-demos-nomad-land-team-footloose-wanderers-assets/raw/main/legacy-app.zip"
                options {
                    checksum = "sha256:b4d7c8dfc352bbcfa482adedbde86cf1e14183f57df4c2a4acd53743814f21bc"
                }
            }

            artifact {
                source = "https://raw.githubusercontent.com/hashicorp/field-demos-nomad-land-team-footloose-wanderers-assets/main/legacy-app.web.config.tpl"
                destination = "${NOMAD_TASK_DIR}"
            }

            config {
                path = "${NOMAD_TASK_DIR}"
                bindings {
                    type = "http"
                    port = "http"
                }
            }

            template {
                source = "${NOMAD_TASK_DIR}/legacy-app.web.config.tpl"
                destination = "${NOMAD_TASK_DIR}/Web.config"
            }

            service {
                name = "legacy-app"
                tags = ["windows", "iis"]
                port = "http"
                check_restart {
                    grace = "60s"
                }
            }
        }
    }
}