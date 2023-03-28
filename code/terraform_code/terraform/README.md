

# What Is Terraform

HashiCorp Terraform is an open source infrastructure as code (IaC) software tool that allows DevOps engineers to programmatically provision the physical resources an application requires to run.

# Terraform Commands
## terraform init
  Initialize Terraform. You only need to do this once per directory.
## terraform plan
Review the configuration and verify that the resources that Terraform is going to create or update match your expectations
## terraform apply
Apply the Terraform configuration by running the following command and entering yes at the prompt

## to run terraform code run these commands
```bash
  git clone https://gitlab.qdatalabs.com/applied-ai/canada/healthcanada/hc-docwarehouse.git
  ```
```bash
  git checkout development
```
``` bash
  cd hc-docwarehouse/code/terraform-code/terraform/root
```
``` bash
  terraform init
```
``` bash
  terraform plan
```
```bash
  terraform apply

```


