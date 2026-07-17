
## Bastion AMI

Create a local variables file:

```bash
cp bastion.pkrvars.hcl.example bastion.pkrvars.hcl
```

Build only this template file:

```bash
packer init bastion.pkr.hcl
packer validate -var-file=bastion.pkrvars.hcl bastion.pkr.hcl
packer build -var-file=bastion.pkrvars.hcl bastion.pkr.hcl
```

## Web AMI

Create a local variables file:

```bash
cp web.pkrvars.hcl.example web.pkrvars.hcl
```

Build only this template file:

```bash
packer init web.pkr.hcl
packer validate -var-file=web.pkrvars.hcl web.pkr.hcl
packer build -var-file=web.pkrvars.hcl web.pkr.hcl
```

Do not run `packer build .` because the repository contains separate templates for different AMIs.
