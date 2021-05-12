client {
    host_volume "pgdata" {
        path      = "/var/lib/postgresql/data"
        read_only = false
    }
}