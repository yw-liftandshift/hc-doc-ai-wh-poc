# Health Canada DocAI Warehouse POC - Deployment Manual

## Pre-Requisites

1. Install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
1. Install [terraform](https://developer.hashicorp.com/terraform/downloads).
1. Install the [gcloud CLI](https://cloud.google.com/sdk/docs/install).
1. Join the [docai-warehouse-cloud-console Group](https://groups.google.com/g/docai-warehouse-cloud-console-ui) to be able to access the Document AI Warehouse UI in your project.
   ![docai-warehouse-cloud-console Group](./images/docai-warehouse-onestack-ui.png "docai-warehouse-cloud-console Group")
1. Have a [Google Cloud Organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
1. Have a [Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
1. [Create a Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) to host the POC, linking it to a Billing Account.
1. If someone else other than the project's creator will deploy the system, then his/her user needs to be granted the `Owner` role in the project: the `Owner` role is [required to provision the Document AI Warehouse](https://cloud.google.com/document-warehouse/docs/quickstart#provision-cloud-console). Go to IAM & Admin -> IAM -> Click "Grant Access" for that.
1. If your organization has constraints on resource location, go to IAM & Admin -> Organization Policies -> Filter for `Google Cloud Platform - Resource Location Restriction` -> Click `Manage Policy`, and allow resources to be created in the regions you would like to deploy Document AI: at the moment, only the `us` and `eu` regions are supported.
   ![Allow US Location 1](./images/org-policy-allow-us-1.png "Allow US Location 1")
   ![Allow US Location 2](./images/org-policy-allow-us-2.png "Allow US Location 2")
   ![Allow US Location 3](./images/org-policy-allow-us-3.png "Allow US Location 3")
1. Create two [Google Cloud groups](https://cloud.google.com/iam/docs/groups-in-cloud-console):

- Admins
- Users

## Bootstrap

1. Open a terminal.
1. Run `gcloud auth login`.
1. Run `gcloud application-default login`.
1. `cd` into the [bootstrap folder](../infra/deployment/terraform/bootstrap).
1. Run `cp terraform.tfvars.template terraform.tfvars` to create a [terraform.tfvars file](infra/deployment/terraform/bootstrap).
1. Set the variables in the `terraform.tfvars` file according to your own values. Leave the following variables empty for now:
   _ `dw_ui_service_account_email`
   _ `dw_ui_service_account_private_key`
   _ `schema_id`
   _ `sourcerepo_name`
   ![Initial terraform.tfvars](./images/initial-terraform-tfvars.png "Initial terraform.tfvars")
1. Comment out the entire contents of the `backend.tf` file.
   ![Comment out backend.tf](./images/comment-out-backend-tf.png "Comment out backend.tf")
1. Run `terraform init`.
1. Run `terraform apply -target=module.project`.
1. Uncomment the contents of the `backend.tf` and set the `bucket` attribute to the value of the `tfstate_bucket` output.
   ![Uncomment backend.tf](./images/uncomment-backend-tf.png "Uncomment backend.tf")
1. Run `terraform init` and type `yes` to store the [terraform state](https://developer.hashicorp.com/terraform/language/state) in the [Google Cloud Storage bucket](https://developer.hashicorp.com/terraform/language/settings/backends/gcs).
1. Follow the `doc_ai_warehouse_provisioning_link` on your web browser to manually create a DocAI Warehouse instance. [Reference documentation](https://cloud.google.com/document-warehouse/docs/quickstart#provision-cloud-console).
   ![Document AI Warehouse Provisioning 1](./images/document-ai-warehouse-provisioning-1.png "Document AI Warehouse Provisioning 1")
   <!-- ![Document AI Warehouse Provisioning 2](./images/document-ai-warehouse-provisioning-2.png "Document AI Warehouse Provisioning 2") -->
   ![Document AI Warehouse Provisioning 3](./images/document-ai-warehouse-provisioning-3.png "Document AI Warehouse Provisioning 3")
   ![Document AI Warehouse Provisioning 4](./images/document-ai-warehouse-provisioning-4.png "Document AI Warehouse Provisioning 4")
   <!-- ![Document AI Warehouse Provisioning 5](./images/document-ai-warehouse-provisioning-5.png "Document AI Warehouse Provisioning 5") -->
1. Create serivce account which will be used with DocAI Warehouse
   ![SA Creation](./images/sa-create.png "SA Creation")
1. Create private key and download it as JSON
   ![Creating private key](./images/get-key.png "Creating private key") 
1.  Update the `dw_ui_service_account_email` and the `dw_ui_service_account_private_key` variables in the `terraform.tfvars` file.
   ![Document AI Warehouse Provisioning 6](./images/document-ai-warehouse-provisioning-6.png "Document AI Warehouse Provisioning 6")
1. Go to the Document AI Warehouse UI -> Admin -> Access and add your email as well as the `dw_ui_service_account_email` as a `Document Admin`s. If you have any other users or groups you would like to add you can also do it here.
   ![Add Document Admins](./images/add-document-admins.png "Add Document Admins")
1. Go to Document AI Warehouse UI -> Admin -> Schema, and create a [document schema](https://cloud.google.com/document-warehouse/docs/manage-document-schemas) with following fields: 
      `barcode_number`	
      `classification_code`		
      `classification_level`		
      `date`		
      `file_number`		
      `file_title`		
      `org_code`		
      `volume`
   ![Create Schema 1](./images/schema.png "Create Schema 1")
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
1. [Create Document AI processors](https://cloud.google.com/document-ai/docs/processors-list)
   ![Create custom Processor](./images/create-custom-processor.png "Create custom processor")
   ![Create custom Processor](./images/create-custom-processor1.png "Create custom processor")
   ![Create custom Processor](./images/create-custom-processor2.png "Create custom processor")
   You will need Custom Classifier, 2 Custom Extractors (general and lrs) and OCR Processor, which can be created from processor gallery
   ![Create OCR Processor](./images/create-custom-processor3.png "Create OCR processor")
1. After creating all processors you should get their ID's and paste them into corresponding tfvars.
1. Run `gcloud beta services identity create --service "secretmanager.googleapis.com" --project "project-id"`
1. Run `terraform apply`.

## Processor importing
1. To import processor you need to go to `Manage versions` tab, press `Import` button and select the project, processor and version you want to import.
![Processor importing](./images/import-processor.png "Processor importing")
![Processor importing1](./images/import-processor1.png "Processor importing1")

## Test the Cloud Function

1. Go to Cloud Storage -> Click the `<my-project-id>-input-pdf` bucket -> Click `Upload Files` and upload the file you wish to process.
1. Go to DocAI Warehouse -> Click `All documents`: the processed document should be there.
1. In case of errors, go to Cloud Functions -> Click the `hc` Cloud Function -> Click the `Logs` tab to troubleshoot.
   ![Test Cloud Function 1](./images/test-cloud-function-1.png "Test Cloud Function 1")
   ![Test Cloud Function 2](./images/test-cloud-function-2.png "Test Cloud Function 2")
   ![Test Cloud Function 3](./images/test-cloud-function-3.png "Test Cloud Function 3")
   ![Test Cloud Function 4](./images/test-cloud-function-4.png "Test Cloud Function 4")
