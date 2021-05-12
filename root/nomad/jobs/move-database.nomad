Install-Module -Name SqlServer

$connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f 'product-db.service.demo.consul','products','sa','Passw0rd!'

$Database = Get-SqlDatabase -ConnectionString $connectionString

$scriptOptions = New-Object -TypeName Microsoft.SqlServer.Management.Smo.ScriptingOptions

$scriptOptions.NoCollation = $True
$scriptOptions.Indexes = $True
$scriptOptions.Triggers = $True
$scriptOptions.DriAll = $True
$scriptOptions.ScriptData = $True

$Database.Tables.EnumScript($scriptOptions) | Out-File -FilePath ".\products.sql"

# Invoke-Sqlcmd -ConnectionString $connectionString -InputFile ".\products.sql"