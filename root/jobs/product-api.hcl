job "product-api" {
    datacenters = ["demo"]
    type = "service"
    constraint {
        attribute = "${attr.kernel.name}"
        value = "windows"
    }
    group "product-api" {
        count = 1
      	network {
      		port "http" {
              	static = 9090
            }
    	}
        task "product-api" {
            driver = "win_iis"

            artifact {
                source = "https://github.com/hashicorp/field-demos-nomad-land-team-footloose-wanderers-assets/raw/main/resources/product-api.zip"
                options {
                    checksum = "sha256:f78ec00d0f3dd24916cb9d7f16fb5ca438f1ca672d2367821b8a07f814bfc36a"
                }
            }

            config {
                path = "${NOMAD_TASK_DIR}"
                bindings {
                    type = "http"
                    port = "http"
                }
            }

            service {
                name = "product-api"
                tags = ["windows", "iis"]
                port = "http"
                check_restart {
                    grace = "60s"
                }
            }
        }
    }
}