job "payment-api" {
    datacenters = ["demo"]
    type        = "service"
    constraint {
        attribute = "${attr.driver.podman.rootless}"
        value = "false"
    }
    group "payment-api" {
        count = 1
      	network {
      		port "api" {
              	static = 8080
            }
    	}
        task "payment-api" {
            driver = "java"

            // vault {
            //     policies = [ "transform" ]
            // }

            # Creation of the template file defining how the API will access the database
//             template {
//                 destination   = "local/application.properties"
//                 data = <<EOF
// app.storage=db
// app.encryption.enabled=true
// app.encryption.path=transform
// app.encryption.key=payments
// EOF
//             }

//             # Creation of the template file defining how to connect to vault
//             template {
//                 destination   = "local/bootstrap.yml"
//                 data = <<EOF
// spring:
//   cloud:
//     vault:
//       enabled: true
//       fail-fast: true
//       authentication: TOKEN
//       token: {{ env "VAULT_TOKEN" }}
//       host: active.vault.service.consul
//       port: 8200
//       scheme: http
//       kv:
//         enabled: false
//       generic:
//         enabled: false
// EOF
//             }

//             template {
//                 destination   = "local/application.yaml"
//                 data = <<EOF
// spring:
//   application:
//     name: payments-api
//   datasource:
//     url: jdbc:h2:mem:testdb
//     driverClassName: org.h2.Driver
//     username: sa
//     password: password
//   jpa:
//     database-platform: org.hibernate.dialect.H2Dialect
//     show-sql: true
//   h2:
//     console:
//       enabled: true
//       settings:
//         web-allow-others: true
// management:
//   endpoint:
//     health:
//       show-details: always
// EOF
//             }

//             # Task relevant environment variables necessary
//             env {
//                 SPRING_CONFIG_LOCATION = "file:/local/"
//                 SPRING_CLOUD_BOOTSTRAP_LOCATION = "file:/local/"
//             }

            artifact {
                source = "https://github.com/hashicorp-demoapp/payments/releases/download/v0.0.11/spring-boot-payments-0.0.11.jar"
            }

            config {
                jar_path    = "${NOMAD_TASK_DIR}/spring-boot-payments-0.0.11.jar"
                jvm_options = ["-Xmx512m", "-Xms256m"]
            }

            resources {
                cpu    = 256
                memory = 512
            }

            service {
                name = "payment-api"
                tags = ["podman","java"]
                port = "api"
                check_restart {
                    grace = "600s"
                }
            }
        }
    }
}