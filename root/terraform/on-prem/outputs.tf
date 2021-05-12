////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           terraform/config
//  File Name:      outputs.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           May 2021
//  Description:    This is the output variables file for the terraform project
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

output "outputs" {
    value                   = {
        connection          = vault_database_secret_backend_connection.mssql.id
        role                = vault_database_secret_backend_role.role.id
    }
}