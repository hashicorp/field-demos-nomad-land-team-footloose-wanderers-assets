job "install-sqlserver" {
    datacenters = ["demo"]
    type        = "batch"
    constraint {
        attribute = "${attr.kernel.name}"
        value = "windows"
    }
    group "installation" {
        count = 1
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
Write-Host "Install Powershell Sql Server Commands"
Install-Module -Name SqlServer

Write-Host "Install Sql Server Express"
(New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/7/c/1/7c14e92e-bdcb-4f89-b7cf-93543e7112d1/SQLEXPR_x64_ENU.exe", "c:/temp/sqlserver.exe")
cd 'c:/temp'
.\sqlserver.exe /q /x:'c:\temp\sqlserver'
cd 'c:\temp\sqlserver'
.\setup.exe /Q /ACTION=install /FEATURES=SQL,Tools /IACCEPTSQLSERVERLICENSETERMS /INSTANCENAME="SQLExpress"
sc.exe stop 'SQLWriter'
sc.exe delete 'SQLWriter'
sc.exe stop 'SQLBrowser'
sc.exe delete 'SQLBrowser'
sc.exe stop 'MSSQL$SQLEXPRESS'
sc.exe delete 'MSSQL$SQLEXPRESS'
sc.exe stop 'SQLAgent$SQLEXPRESS'
sc.exe delete 'SQLAgent$SQLEXPRESS'
sc.exe stop 'SQLTELEMETRY$SQLEXPRESS'
sc.exe delete 'SQLTELEMETRY$SQLEXPRESS'
Restart-Computer -Force
EOF
                destination = "local\\sqlserver_express.ps1"
                change_mode   = "signal"
                change_signal = "SIGINT"
            }
        }
    }
}