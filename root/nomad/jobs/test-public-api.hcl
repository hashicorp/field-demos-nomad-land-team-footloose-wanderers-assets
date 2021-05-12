job "test-public-api" {
    datacenters = ["demo"]
    type     = "service"

    constraint {
        attribute = "${attr.kernel.name}"
        value = "linux"
    }
group "public-api" {
    count = 1

    network {
      port "pub_api" {
        static = 9080
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    # Define update strategy for the Payments API
    update {
      canary  = 1
    }

    task "public-api" {
      driver = "docker"

      # Task relevant environment variables necessary
      env {
        BIND_ADDRESS = ":9080"
        PRODUCT_API_URI = "http://product-api.service.consul:9090"
        PAYMENT_API_URI = "http://payments-api.service.consul:8080"
      }

      # Public-api Docker image location and configuration
      config {
        image = "hashicorpdemoapp/public-api:v0.0.4"
        dns_servers = ["172.17.0.1"]
        ports = ["pub_api"]
      }

      # Host machine resources required
      resources {
        cpu    = 100
        memory = 256
      }

      # Service definition to be sent to Consul with corresponding health check
      service {
        name = "public-api-server"
        port = "pub_api"
        tags = ["public-api"]
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}