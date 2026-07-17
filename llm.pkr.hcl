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

source "amazon-ebs" "llm" {
  region        = var.aws_region
  instance_type = "t3.small"

  ssh_username = "ubuntu"
  
  associate_public_ip_address = true

  temporary_security_group_source_public_ip = true

  ami_name = "llm-test-llm-${var.image_version}-{{timestamp}}"

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
    volume_size           = 12
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "llm-test-llm-${var.image_version}"
    Project     = "llm"
    Environment = "test"
    Role        = "llm"
    Version     = var.image_version
    BuiltBy     = "packer"
  }
}

build {
  sources = [
    "source.amazon-ebs.llm"
  ]

  provisioner "file" {
    source      = "files/llm/ollama-override.conf"
    destination = "/tmp/ollama-override.conf"
  }

  provisioner "file" {
    source      = "files/llm/node_exporter.service"
    destination = "/tmp/node_exporter.service"
  }

  provisioner "shell" {
    script = "scripts/llm/install-packages.sh"
  }

  provisioner "shell" {
    script = "scripts/llm/install-ollama.sh"
  }

  provisioner "shell" {
    script = "scripts/llm/install-files.sh"
  }

  provisioner "shell" {
    script = "scripts/common/install-node-exporter.sh"
  }
}