
# Terraform 

## What Is Terraform
HashiCorp Terraform is an open-source infrastructure as code (IaC) software tool that allows DevOps engineers to programmatically provision the physical resources an application requires to run

## How to Install Terraform
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

## Terraform Commands
### terraform init
  Initialize Terraform. You only need to do this once per directory.
### terraform plan
Review the configuration and verify that the resources that Terraform is going to create or update match your expectations
### terraform apply
Apply the Terraform configuration by running the following command and entering yes at the prompt

## Manual steps to follow before running the terraform code

* Create a project in the Google Cloud Platform
* Create a service account inside the project for terraform and give these roles to it 
  * Cloud Functions Admin
  * Document AI      Administrator
  * Project IAM Admin
  * Role Administrator
  * Service Account Admin
  * Service Management Administrator
  * Storage Admin
  * Editor

* Create a cloud storage bucket that will store the terraform state file

* enable these  APIs
  * cloudresourcemanager.googleapis.com
  * serviceusage.googleapis.com

* Inside the root folder there is a backend.tf file go to this file and insert the bucket name which was created manually to store terraform state file

* in the root folder there is a file terraform.tfvars  insert the value for all the variables inside the file 

* give service account token creator role to the user 


## to run terraform code run these commands
```
  git clone https://gitlab.qdatalabs.com/applied-ai/canada/healthcanada/hc-docwarehouse.git
  ```
```
  git checkout development
```
``` 
  cd hc-docwarehouse/code/terraform-code/terraform/root
```
``` 
  terraform init
```
``` 
  terraform plan
```
```
  terraform apply

```

### create a service account for terraform 

  https://cloud.google.com/iam/docs/service-accounts-create#iam-service-accounts-create-console

### create a cloud storage bucket for terraform state file

  https://cloud.google.com/storage/docs/creating-buckets

### Enable API in the google cloud project

   https://cloud.google.com/endpoints/docs/openapi/enable-api