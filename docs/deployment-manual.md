# DocAI Warehouse POC - Deployment Manual

## Pre-Requisites

1. Install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
1. Install [terraform](https://developer.hashicorp.com/terraform/downloads).
1. Install the [gcloud CLI](https://cloud.google.com/sdk/docs/install).
1. Join the [DW-UI-preview Group](https://groups.google.com/g/dw-ui-preview) to be able to access the Document AI Warehouse UI in your project.
1. Have a [Google Cloud Organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
1. Have a [Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
1. [Create a Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) to host the POC, linking it to a Billing Account.
1. If someone else other than the project's creator will deploy the system, then his/her user needs to be granted the `Owner` role in the project: the `Owner` role is [required to provision the Document AI Warehouse](https://cloud.google.com/document-warehouse/docs/quickstart#provision-cloud-console). Go to IAM & Admin -> IAM -> Click "Grant Access" for that.
1. If your organization has constraints on resource location, go to IAM & Admin -> Organization Policies -> Filter for `Google Cloud Platform - Resource Location Restriction` -> Click `Manage Policy`, and allow resources to be created in the regions you would like to deploy Document AI: at the moment, only the `us` and `eu` regions are supported.
![Allow US Location 1](./images/org-policy-allow-us-1.png "Allow US Location 1")
![Allow US Location 2](./images/org-policy-allow-us-2.png "Allow US Location 2")
![Allow US Location 3](./images/org-policy-allow-us-3.png "Allow US Location 3")


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
![Initial terraform.tfvars](./images/initial-terraform-tfvars.png "Initial terraform.tfvars")
1. Comment out the entire contents of the `backend.tf` file.
![Comment out backend.tf](./images/comment-out-backend-tf.png "Comment out backend.tf")
1. Run `terraform init`.
1. Run `terraform apply -target=module.project`.
1. Uncomment the contents of the `backend.tf` and set the `bucket` attribute to the value of the `tfstate_bucket` output.
![Uncomment backend.tf](./images/uncomment-backend-tf.png "Uncomment backend.tf")
1. Run `terraform init` and type `yes` to store the [terraform state](https://developer.hashicorp.com/terraform/language/state) in the [Google Cloud Storage bucket](https://developer.hashicorp.com/terraform/language/settings/backends/gcs).
1. Follow the `doc_ai_warehouse_provisioning_link` on your web browser to manually create a DocAI Warehouse instance. [Reference documentation](https://cloud.google.com/document-warehouse/docs/quickstart#provision-cloud-console). Update the `dw_ui_service_account_email` and the `dw_ui_service_account_private_key` variables in the `terraform.tfvars` file.
![Document AI Warehouse Provisioning 1](./images/document-ai-warehouse-provisioning-1.png "Document AI Warehouse Provisioning 1")
![Document AI Warehouse Provisioning 2](./images/document-ai-warehouse-provisioning-2.png "Document AI Warehouse Provisioning 2")
![Document AI Warehouse Provisioning 3](./images/document-ai-warehouse-provisioning-3.png "Document AI Warehouse Provisioning 3")
![Document AI Warehouse Provisioning 4](./images/document-ai-warehouse-provisioning-4.png "Document AI Warehouse Provisioning 4")
![Document AI Warehouse Provisioning 5](./images/document-ai-warehouse-provisioning-5.png "Document AI Warehouse Provisioning 5")
![Document AI Warehouse Provisioning 6](./images/document-ai-warehouse-provisioning-6.png "Document AI Warehouse Provisioning 6")
1. Go to the Document AI Warehouse UI -> Admin -> Access and add your email as well as the `dw_ui_service_account_email` as a `Document Admin`s. If you have any other users or groups you would like to add you can also do it here.
![Add Document Admins](./images/add-document-admins.png "Add Document Admins")
1. Go to Document AI Warehouse UI -> Admin -> Schema, and create a [document schema](https://cloud.google.com/document-warehouse/docs/manage-document-schemas) using the [schema_creation.json](./data/schema_creation.json) file as the `json` input. Update the `schema_id` in the `terraform.tfvars` file.
![Create Schema 1](./images/create-schema-1.png "Create Schema 1")
![Create Schema 2](./images/create-schema-2.png "Create Schema 2")
![Create Schema 3](./images/create-schema-3.png "Create Schema 3")
![Create Schema 4](./images/create-schema-4.png "Create Schema 4")
1. [Create a Cloud Source Repository](https://cloud.google.com/source-repositories/docs/creating-an-empty-repository#gcloud) in the project your just created. Then push this repository to the newly created CSR repository. Update the `sourcerepo_name` variable in the `terraform.tfvars` file.
![Create CSR 1](./images/create-csr-1.png "Create CSR 1")
![Create CSR 2](./images/create-csr-2.png "Create CSR 2")
![Create CSR 3](./images/create-csr-3.png "Create CSR 3")
![Create CSR 4](./images/create-csr-4.png "Create CSR 4")
![Create CSR 5](./images/create-csr-5.png "Create CSR 5")
![Create CSR 6](./images/create-csr-6.png "Create CSR 6")
![Create CSR 6](./images/create-csr-7.png "Create CSR 7")
1. Go to Cloud Storage -> Settings and check that the `Cloud Storage Service Account` was created.
![Check GCS SA](./images/check-gcs-sa.png "Create GCS SA")
1. Run `terraform apply`.

## CDE Processor Training

1. Go to Cloud Build -> Triggers and run the `cde-processor-training` trigger.
1. Go to Document AI -> My processors -> Click `HC CDE processor` -> Click the `Manage Versions` tab, and wait for the processor training to finish successfully. This can take more than 30 minutes.
1. After the processor training has finished, click the three dots on the processor version row and [deploy the processor](https://cloud.google.com/document-ai/docs/manage-processor-versions#deploy).
1. [Set the deployed processor as default](https://cloud.google.com/document-ai/docs/manage-processor-versions#change-default).
![CDE Processor Training 1](./images/cde-processor-training-1.png "CDE Processor Training 1")
![CDE Processor Training 2](./images/cde-processor-training-2.png "CDE Processor Training 2")
![CDE Processor Training 3](./images/cde-processor-training-3.png "CDE Processor Training 3")
![CDE Processor Training 4](./images/cde-processor-training-4.png "CDE Processor Training 4")
![CDE Processor Training 5](./images/cde-processor-training-5.png "CDE Processor Training 5")
![CDE Processor Training 6](./images/cde-processor-training-6.png "CDE Processor Training 6")
![CDE Processor Training 7](./images/cde-processor-training-7.png "CDE Processor Training 7")
![CDE Processor Training 8](./images/cde-processor-training-8.png "CDE Processor Training 8")
![CDE Processor Training 9](./images/cde-processor-training-9.png "CDE Processor Training 9")
![CDE Processor Training 10](./images/cde-processor-training-10.png "CDE Processor Training 10")

## Test the Cloud Function

1. Go to Cloud Storage -> Click the `<my-project-id>-input-pdf` bucket -> Click `Upload Files` and upload the file you wish to process.
1. Go to DocAI Warehouse -> Click `All documents`: the processed document should be there.
1. In case of errors, go to Cloud Functions -> Click the `hc` Cloud Function -> Click the `Logs` tab to troubleshoot.
![Test Cloud Function 1](./images/test-cloud-function-1.png "Test Cloud Function 1")
![Test Cloud Function 2](./images/test-cloud-function-2.png "Test Cloud Function 2")
![Test Cloud Function 3](./images/test-cloud-function-3.png "Test Cloud Function 3")
![Test Cloud Function 4](./images/test-cloud-function-4.png "Test Cloud Function 4")