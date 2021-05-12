cat <<-EOF > /root/nomad/jobs/payment-db.nomad
job "payment-db" {
  multiregion {
    strategy {
      max_parallel = 1
      on_failure   = "fail_all"
    }
    region "west" {
      count       = 1
      datacenters = ["cloud"]
    }
    region "east" {
      count       = 1
      datacenters = ["on-prem"]
    }
  }
  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "2m"
    progress_deadline = "3m"
    auto_revert       = true
    auto_promote      = true
    canary            = 1
  }
  group "cache" {
    count = 0
    task "redis" {
      driver = "docker"
      config {
        image = "redis:6.0"
        port_map {
          db = 6379
        }
      }
      resources {
        cpu    = 256
        memory = 128
        network {
          mbits = 10
          port "db" {}
        }
      }
    }
  }
}
EOF