packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.8"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "image_version" {
  type = string
}

source "amazon-ebs" "bastion" {
  region        = var.aws_region
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"

  associate_public_ip_address = true
  temporary_security_group_source_public_ip = true

  ami_name = "llm-test-bastion-${var.image_version}-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }

    owners      = ["099720109477"]
    most_recent = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "llm-test-bastion-${var.image_version}"
    Project     = "llm"
    Environment = "test"
    Role        = "bastion"
    Version     = var.image_version
    BuiltBy     = "packer"
  }
}

build {
  sources = [
    "source.amazon-ebs.bastion"
  ]

  provisioner "file" {
    source      = "files/bastion/node_exporter.service"
    destination = "/tmp/node_exporter.service"
  }

  provisioner "file" {
    source      = "files/bastion/db_init.sql"
    destination = "/tmp/db_init.sql"
  }

  provisioner "file" {
    source      = "files/bastion/init-database.sh"
    destination = "/tmp/init-database.sh"
  }

  provisioner "shell" {
    script = "scripts/bastion/install-packages.sh"
  }

  provisioner "shell" {
    script = "scripts/common/install-aws-cli.sh"
  }

  provisioner "shell" {
    script = "scripts/common/install-node-exporter.sh"
  }

  provisioner "shell" {
    script = "scripts/bastion/install-files.sh"
  }
}
