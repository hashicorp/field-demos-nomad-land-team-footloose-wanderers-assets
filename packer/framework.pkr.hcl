////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           packer
//  File Name:      server.pkr.hcl
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           April 2021
//  Description:    This is the packer file to create the automation framework server image
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Variables
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
variable "gcp" {
    type                = map(string)
    description         = "The GCP provider information"
    default             = {
        id              = "pgryzan"
        zone            = "us-central1-c"
    }
}

variable "ssh" {
    type                = map(string)
    description         = "The SSH information"
    default             = {
        username        = "hashistack"
        password        = "Passw0rd!"
        build_username  = "packer"
    }
}

variable "ubuntu_image" {
    type                = map(string)
    description         = "Base image information"
    default             = {
        id              = "ubuntu-2004-lts"
        disk_size       = 20
    }
}

variable "redhat_image" {
    type                = map(string)
    description         = "Base image information"
    default             = {
        id              = "centos-stream-8"
        disk_size       = 30
    }
}

variable "windows_image" {
    type                = map(string)
    description         = "Base image information"
    default             = {
        id              = "windows-2019-core-for-containers"
        dev_id          = "windows-2019-for-containers"
        disk_size       = 50
        winrm_username  = "packer"
    }
}

variable "stack" {
    type                = map(string)
    description         = "HashiCorp Solution Versions"
    default             = {
        consul          = "1.9.5+ent"
        name            = "framework"
        nomad           = "1.0.4+ent"
        vault           = "1.7.1+ent"
        version         = "0.1.0"
    }
}

locals {
    version             = replace(replace(var.stack.version, ".", "-"), "+", "-")
    consul              = replace(replace(var.stack.consul, ".", "-"), "+", "-")
    nomad               = replace(replace(var.stack.nomad, ".", "-"), "+", "-")
    vault               = replace(replace(var.stack.vault, ".", "-"), "+", "-")
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Builder Definitions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
source "googlecompute" "server" {
    project_id          = var.gcp.id
    zone                = var.gcp.zone
    source_image_family = var.ubuntu_image.id
    disk_size           = var.ubuntu_image.disk_size
    ssh_username        = var.ssh.build_username
    machine_type        = "n1-standard-4"
    image_name          = "${var.stack.name}-server-${local.version}"
    image_labels        = {
        consul          = local.consul
        nomad           = local.nomad
        vault           = local.vault
    }
}

source "googlecompute" "docker" {
    project_id          = var.gcp.id
    zone                = var.gcp.zone
    source_image_family = var.ubuntu_image.id
    disk_size           = var.ubuntu_image.disk_size
    ssh_username        = var.ssh.build_username
    machine_type        = "n1-standard-4"
    image_name          = "${var.stack.name}-docker-${local.version}"
    image_labels        = {
        consul          = local.consul
        nomad           = local.nomad
        vault           = local.vault
    }
}

source "googlecompute" "podman" {
    project_id          = var.gcp.id
    zone                = var.gcp.zone
    source_image_family = var.redhat_image.id
    disk_size           = var.redhat_image.disk_size
    ssh_username        = var.ssh.build_username
    machine_type        = "n1-standard-4"
    image_name          = "${var.stack.name}-podman-${local.version}"
    image_labels        = {
        consul          = local.consul
        nomad           = local.nomad
        vault           = local.vault
    }
}

source "googlecompute" "windows" {
    project_id          = var.gcp.id
    zone                = var.gcp.zone
    disk_size           = var.windows_image.disk_size
    machine_type        = "n1-standard-8"
    communicator        = "winrm"
    winrm_username      = var.ssh.username
    winrm_password      = var.ssh.password
    winrm_insecure      = true
    winrm_use_ssl       = true
    metadata            = {
        windows-startup-script-cmd = "winrm quickconfig -quiet & net user /add ${var.ssh.username} ${var.ssh.password} & net localgroup administrators ${var.ssh.username} /add & winrm set winrm/config/service/auth @{Basic=\"true\"} & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"Set-ExecutionPolicy -ExecutionPolicy Bypass -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072\""
    }
    image_labels        = {
        consul          = local.consul
        nomad           = local.nomad
        vault           = local.vault
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Builders
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

build {
    name                = "server"

    sources             = [
        "sources.googlecompute.server"
    ]

    provisioner "file" {
        source          = "scripts/bash/"
        destination     = "/tmp"
    }

    provisioner "shell" {
        inline          = [
            "sudo chmod +x /tmp/hashistack.sh",
            "sudo /tmp/hashistack.sh -c '${var.stack.consul}' -n '${var.stack.nomad}' -v '${var.stack.vault}' -u '${var.ssh.username}' -p '${var.ssh.password}'",
            "sudo rm -r /tmp/*.sh"
        ]
    }

    provisioner "file" {
        source          = "config-server.sh"
        destination     = "/hashistack/config.sh"
    }
}

build {
    name                = "docker"

    sources             = [
        "sources.googlecompute.docker"
    ]

    provisioner "file" {
        source          = "scripts/bash/"
        destination     = "/tmp"
    }

    provisioner "shell" {
        inline          = [
            "sudo chmod +x /tmp/hashistack.sh",
            "sudo /tmp/hashistack.sh -c '${var.stack.consul}' -n '${var.stack.nomad}' -v '${var.stack.vault}' -u '${var.ssh.username}' -p '${var.ssh.password}'",
            "sudo chmod +x /tmp/docker.sh",
            "sudo /tmp/docker.sh",
            "sudo rm -r /tmp/*.sh"
        ]
    }

    provisioner "file" {
        source          = "config-docker.sh"
        destination     = "/hashistack/config.sh"
    }
}

build {
    name                = "podman"

    sources             = [
        "sources.googlecompute.podman"
    ]

    provisioner "file" {
        source          = "scripts/bash/"
        destination     = "/tmp"
    }

    provisioner "shell" {
        inline          = [
            "sudo chmod +x /tmp/hashistack.sh",
            "sudo /tmp/hashistack.sh -c '${var.stack.consul}' -n '${var.stack.nomad}' -v '${var.stack.vault}' -u '${var.ssh.username}' -p '${var.ssh.password}'",
            "sudo chmod +x /tmp/podman.sh",
            "sudo /tmp/podman.sh",
            "sudo rm -r /tmp/*.sh"
        ]
    }

    provisioner "file" {
        source          = "config-podman.sh"
        destination     = "/hashistack/config.sh"
    }
}

build {
    name                    = "windows"

    source "googlecompute.windows" {
        name                = "windows"
        source_image_family = var.windows_image.id
        image_name          = "${var.stack.name}-windows-${local.version}"
    }

    source "googlecompute.windows" {
        name                = "dev"
        source_image_family = var.windows_image.dev_id
        image_name          = "${var.stack.name}-windows-dev-${local.version}"
    }

    provisioner "file" {
        source          = "scripts/powershell/"
        destination     = "C:/Temp"
    }

    provisioner "powershell" {
        elevated_user   = var.ssh.username
        elevated_password = var.ssh.password
        inline          = [
            "c:/temp/hashistack.ps1 -c '${var.stack.consul}' -n '${var.stack.nomad}' -i 'pgryzan/hashicups-product-db:20210411'",
            "Remove-Item c:/temp/*.ps1"
        ]
    }

    provisioner "file" {
        source          = "config-windows.ps1"
        destination     = "c:/users/hashistack/config.ps1"
    }
}