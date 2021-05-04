////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           packer
//  File Name:      variables.pkrvars.hcl
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           April 2021
//  Description:    This is the packer variables file containing possible sensitive information
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//  Change the id to instruqt-hashicorp for production build
gcp             = {
    id              = "pgryzan"
    zone            = "us-central1-c"
}

//  Don't change any of this stuff. 
//  The user name and password are for consistent instruqt setup access
//  The build_username allows winrm access through the firewall on port 5986
ssh             = {
    username        = "hashistack"
    password        = "Passw0rd!"
    build_username  = "packer"
}