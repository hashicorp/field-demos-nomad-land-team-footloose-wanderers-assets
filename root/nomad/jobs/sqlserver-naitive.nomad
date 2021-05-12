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
            driver = "raw_exec"
            config {
                command = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
                args = [
                    "-ExecutionPolicy","bypass",
                    "-File","${NOMAD_TASK_DIR}\\sqlserver_express.ps1"
                ]
            }
                       template {
                data = <<EOF
cd 'C:/Program Files/Microsoft SQL Server/MSSQL15.SQLEXPRESS/MSSQL/Binn'
.\sqlservr.exe -sSQLEXPRESS
EOF
                destination = "local\\sqlserver_express.ps1"
        }
    }
}