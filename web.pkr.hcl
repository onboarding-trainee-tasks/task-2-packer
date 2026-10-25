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

source "amazon-ebs" "web" {
  region        = var.aws_region
  instance_type = "t3.small"
  ssh_username  = "ubuntu"

  associate_public_ip_address               = true
  temporary_security_group_source_public_ip = true

  ami_name = "llm-test-web-${var.image_version}-{{timestamp}}"

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
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "llm-test-web-${var.image_version}"
    Project     = "llm"
    Environment = "test"
    Role        = "web-server"
    Version     = var.image_version
    BuiltBy     = "packer"
  }
}

build {
  sources = [
    "source.amazon-ebs.web"
  ]

  provisioner "file" {
    source      = "files/web/systemd/alertmanager.service"
    destination = "/tmp/alertmanager.service"
  }

  provisioner "file" {
    source      = "files/web/systemd/prometheus.service"
    destination = "/tmp/prometheus.service"
  }

  provisioner "file" {
    source      = "files/web/systemd/node_exporter.service"
    destination = "/tmp/node_exporter.service"
  }

  provisioner "file" {
    source      = "files/web/prometheus/prometheus.yml"
    destination = "/tmp/prometheus.yml"
  }

  provisioner "file" {
    source      = "files/web/prometheus/service-rules.yml"
    destination = "/tmp/service-rules.yml"
  }

  provisioner "file" {
    source      = "files/web/grafana/datasources.yaml"
    destination = "/tmp/datasources.yaml"
  }

  provisioner "file" {
    source      = "files/web/grafana/provider.yaml"
    destination = "/tmp/provider.yaml"
  }

  provisioner "file" {
    source      = "files/web/grafana/alert-rules.yaml"
    destination = "/tmp/alert-rules.yaml"
  }

  provisioner "file" {
    source      = "files/web/grafana/dashboards/instances-dashboard.json"
    destination = "/tmp/instances-dashboard.json"
  }

  provisioner "file" {
    source      = "files/web/grafana/dashboards/services-dashboard.json"
    destination = "/tmp/services-dashboard.json"
  }

  provisioner "file" {
    source      = "files/web/grafana/dashboards/aws-infra-dashboard.json"
    destination = "/tmp/aws-infra-dashboard.json"
  }
  provisioner "file" {
    source      = "files/web/runtime/configure-alertmanager.sh"
    destination = "/tmp/configure-alertmanager.sh"
  }

  provisioner "file" {
    source      = "files/web/runtime/start-open-webui.sh"
    destination = "/tmp/start-open-webui.sh"
  }

  provisioner "shell" {
    script = "scripts/web/install-packages.sh"
  }

  provisioner "shell" {
    script = "scripts/common/install-aws-cli.sh"
  }

  provisioner "shell" {
    script = "scripts/web/install-alertmanager.sh"
  }

  provisioner "shell" {
    script = "scripts/web/install-prometheus.sh"
  }

  provisioner "shell" {
    script = "scripts/web/install-grafana.sh"
  }

  provisioner "shell" {
    script = "scripts/common/install-node-exporter.sh"
  }

  provisioner "shell" {
    script = "scripts/web/install-docker.sh"
  }

  provisioner "shell" {
    script = "scripts/web/install-runtime-files.sh"
  }
}
