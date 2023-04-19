# Deployment

## Pre-Requisites

1. Have a [Google Cloud Organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
1. Have a [Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
1. Have the following [roles](https://cloud.google.com/iam/docs/roles-overview) in your Organization:
    * [Organization Administrator](https://cloud.google.com/iam/docs/understanding-roles#resourcemanager.organizationAdmin)
    * [Organization Policy Administrator](https://cloud.google.com/resource-manager/docs/access-control-org#orgpolicy.policyAdmin)
    * [Project Creator](https://cloud.google.com/iam/docs/understanding-roles#resourcemanager.projectCreator)
1. Have the following roles on your Billing Account:
    * [Billing Account User](https://cloud.google.com/billing/docs/how-to/billing-access#overview-of-cloud-billing-roles-in-cloud-iam)
1. Install the [gcloud CLI](https://cloud.google.com/sdk/docs/install).
1. Install [terraform](https://developer.hashicorp.com/terraform/downloads).

## Bootstrap

1. Open a terminal.
1. Run `gcloud auth login`.
1. Run `gcloud application-default login`.
1. `cd` into the [bootstrap folder](../infra/deployment/terraform/bootstrap).
1. Run `cp terraform.tfvars.template terraform.tfvars` to create a [terraform.tfvars file](infra/deployment/terraform/bootstrap).
1. Set the variables in the `terraform.tfvars` file according to your own values. Leave the following variables empty for now:
    * `dw_ui_service_account_email`
    * `dw_ui_service_account_private_key`
    * `schema_id` 
    * `sourcerepo_name`
1. Comment out the entire contents of the `backend.tf` file.
1. Run `terraform init`.
1. Run `terraform apply -target=module.project`.
1. Uncomment the contents of the `backend.tf` and set the `bucket` attribute to the value of the `tfstate_bucket` output.
1. Run `terraform init` and type `yes` to store the [terraform state](https://developer.hashicorp.com/terraform/language/state) in the [Google Cloud Storage bucket](https://developer.hashicorp.com/terraform/language/settings/backends/gcs). 
1. Follow the `doc_ai_warehouse_provisioning_link` on your web browser to manually create a DocAI Warehouse instance. [Reference documentation](https://cloud.google.com/document-warehouse/docs/quickstart#provision-cloud-console).
1. Create a [document schema](https://cloud.google.com/document-warehouse/docs/manage-document-schemas) using the [schema_creation.json](./data/schema_creation.json) file as the `json` input. Take note of the generated `schema_id`.
1. [Create a Cloud Source Repository](https://cloud.google.com/source-repositories/docs/creating-an-empty-repository#gcloud) in the project your just created. Then push this repository to the newly created CSR repository.
1. Fill out the remaining empty variables in the `terraform.tfvars` file.
1. Go to Cloud Storage -> Settings and check that the `Cloud Storage Service Account` was created.
1. Run `terraform apply`.

## CDE Processor Training

1. Go to Cloud Build -> Triggers and run the `cde-processor-training` trigger.