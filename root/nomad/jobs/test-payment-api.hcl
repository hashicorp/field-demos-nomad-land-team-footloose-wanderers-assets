job "test-payment-api" {
    datacenters = ["demo"]
    type     = "service"

    constraint {
        attribute = "${attr.driver.docker.version}"
        value = "20.10.6"
    }

    group "payments-api" {
    count = 1

    network {
      port "http_port" {
        static = 8080
      }
      dns {
        servers = ["172.17.0.1"]
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

  # Define update strategy for the Payments API
    // update {
    //   canary  = 1
    // }

    # Service definition to be sent to Consul with corresponding health check
    service {
      name = "payments-api-server"
      port = "http_port"
      tags = ["payments-api"]
      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "payments-api" {
      driver = "java"

//       vault {
//         policies = [ "transform" ]
//       }

//       # Creation of the template file defining how the API will access the database
//       template {
//         destination   = "local/application.properties"
//         data = <<EOF
// app.storage=db
// app.encryption.enabled=true
// app.encryption.path=transform
// app.encryption.key=payments
// EOF
//       }

//       # Creation of the template file defining how to connect to vault
//       template {
//         destination   = "local/bootstrap.yml"
//         data = <<EOF
// spring:
//   cloud:
//     vault:
//       enabled: true
//       fail-fast: true
//       authentication: TOKEN
//       token: {{ env "VAULT_TOKEN" }}
//       host: server-a-1
//       port: 8200
//       scheme: http
//       kv:
//         enabled: false
//       generic:
//         enabled: false
// EOF
//       }

//       template {
//         destination   = "local/application.yaml"
//         data = <<EOF
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
//       }

//       # Task relevant environment variables necessary
//       env {
//         SPRING_CONFIG_LOCATION = "file:/local/"
//         SPRING_CLOUD_BOOTSTRAP_LOCATION = "file:/local/"
//       }

      # Product-api Docker image location and configuration
      config {
        jar_path    = "local/spring-boot-payments-0.0.11.jar"
        jvm_options = ["-Xmx1024m", "-Xms256m"]
      }

      artifact {
         source = "https://github.com/hashicorp-demoapp/payments/releases/download/v0.0.11/spring-boot-payments-0.0.11.jar"
      }

      # Host machine resources required
      resources {
        cpu    = 300
        memory = 512
      }

    } # end payments-api task
  } # end payments-api group
}