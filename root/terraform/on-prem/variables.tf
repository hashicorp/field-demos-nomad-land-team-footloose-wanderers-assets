////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           terraform/config
//  File Name:      variables.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           May 2021
//  Description:    This is the input variables file for the terraform project
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Vault Information
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "vault" {
    type            = map
    description     = "Vault provider information"
    default         = {
        address     = "http://34.122.186.109:8200"
        token       = "s.AYHWIymIcRueO4H2AELOlspi"
        mount       = "database"
        role        = "products-app"
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Nomad Information
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "nomad" {
    type            = map
    description     = "Nomad provider information"
    default         = {
        address     = "http://34.122.186.109:4646"
        region      = "us-east"
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  MS SQL Server Information
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "mssql" {
    type            = map
    description     = "SQL Server database information"
    default         = {
        name        = "mssql"
        username    = "sa"
        password    = "Passw0rd!"
        address     = "product-db.service.consul"
        database    = "products"
    }
}
