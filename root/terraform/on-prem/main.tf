////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           terraform/config
//  File Name:      main.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           May 2021
//  Description:    This is the main execution file environment configuration
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Providers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
provider "vault" {
    address                     = var.vault.address
    token                       = var.vault.token
}

provider "nomad" {
    address                     = var.nomad.address
    region                      = var.nomad.region
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Step 1 - Deploy the Database
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "nomad_job" "product_db" {
    jobspec = file("${path.module}/../../../jobs/product-db.hcl")

    provisioner "local-exec" {
        command = "sleep 10"
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Step 2 - Configure Vault to Rotate Dynamic Passwords
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "vault_mount" "db" {
    path                        = var.vault.mount
    type                        = "database"
    depends_on                  = [ nomad_job.product_db ]
}

resource "vault_database_secret_backend_connection" "mssql" {
    backend                     = vault_mount.db.path
    name                        = var.mssql.name
    allowed_roles               = [ var.vault.role ]

    mssql {
        connection_url          = "sqlserver://${var.mssql.username}:${var.mssql.password}@${var.mssql.address}:1433"
        max_open_connections    = 5
        max_connection_lifetime = 10
    }

    depends_on                  = [ vault_mount.db ]
}

resource "vault_database_secret_backend_role" "role" {
    backend                     = vault_mount.db.path
    name                        = var.vault.role
    db_name                     = vault_database_secret_backend_connection.mssql.name
    creation_statements         = ["CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; CREATE USER [{{name}}] FOR LOGIN [{{name}}]; GRANT SELECT,UPDATE,INSERT,DELETE TO [{{name}}];"]
    default_ttl                 = 2
    max_ttl                     = 5

    depends_on                  = [ vault_database_secret_backend_connection.mssql ]
}

resource "vault_policy" "policy" {
    name                        = var.vault.role
    policy                      = <<EOT
path "${var.vault.mount}/creds/${var.vault.role}" {
    capabilities = ["read"]
}
EOT
    depends_on                  = [ vault_database_secret_backend_role.role ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Step 3 - Deploy the Legacy Application
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "nomad_job" "legacy-app" {
    jobspec                     = file("${path.module}/../../../jobs/legacy-app.hcl")
    depends_on                  = [ vault_policy.policy ]
}