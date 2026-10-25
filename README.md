# Onboarding task 2 - Packer images

This repository builds the three Ubuntu AMIs used by the task 2 Terraform
infrastructure. Build these images before running `task-2-infra`.

## Implementation Features

- **Bastion AMI** - PostgreSQL client, AWS CLI, Node Exporter and the pgvector
  database initialization script
- **LLM AMI** - Ollama with the `tinyllama` model and Node Exporter
- **Web AMI** - Open WebUI container image, Docker, Prometheus, Alertmanager,
  Grafana, Node Exporter, dashboards and alert rules

Packer starts temporary EC2 instances from Ubuntu 24.04 in `eu-central-1`, runs
the provisioning scripts, creates encrypted EBS-backed AMIs and then removes the
temporary build resources.

## Requirements outside this repository

- Packer installed locally
- AWS credentials configured (same approach as in Task 1)

No Terraform state bucket, SSH key or application secrets are needed to build
the AMIs. Packer creates a temporary SSH key and security group for each build.

## How to build

Each image has its own template. The variable files in this repository set the
region and image version. Change `image_version` when creating a new release.

```bash
git clone https://github.com/onboarding-trainee-tasks/task-2-packer.git
cd task-2-packer

packer init bastion.pkr.hcl
packer init llm.pkr.hcl
packer init web.pkr.hcl

packer fmt -check .
packer validate -var-file=bastion.pkrvars.hcl bastion.pkr.hcl
packer validate -var-file=llm.pkrvars.hcl llm.pkr.hcl
packer validate -var-file=web.pkrvars.hcl web.pkr.hcl

packer build -var-file=bastion.pkrvars.hcl bastion.pkr.hcl
packer build -var-file=llm.pkrvars.hcl llm.pkr.hcl
packer build -var-file=web.pkrvars.hcl web.pkr.hcl
```

Do not run `packer build .`: the directory contains three separate builds and
some variables have the same names.

## GitHub Actions CI/CD

The Packer workflow supports:

- **Pull requests to `main`:** Formatting checks and syntax-only validation of all three AMI templates.
- **Manual build:** Selects one AMI (`bastion`, `llm` or `web`) and its version, performs full validation and builds the image in AWS.

The build uses GitHub OIDC authentication and the `T2-build` GitHub Environment. No static AWS access keys are required in GitHub.

The resulting AMI ID is available in the workflow logs. To use a new image, manually update the corresponding AMI variable in `task-2-infra`.


## After the build

Copy the three AMI IDs printed by Packer into the matching variables in
`task-2-infra/variables.tf`:

```hcl
packer_bastion_ami    = "ami-..."
packer_llm_ami        = "ami-..."
packer_web_server_ami = "ami-..."
```

Deregister old AMIs and delete their snapshots manually in AMI catalog when they are no longer required.
