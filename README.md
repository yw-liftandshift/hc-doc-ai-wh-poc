# Health Canada - DocAI Warehouse POC

The DocAI Warehouse POC provides a document management solution to store, index, and search documents at scale. For that, it does the following:

1. Allows users to upload pdf documents to a [Google Cloud Storage bucket](https://cloud.google.com/storage/docs/buckets), which are basic containers to hold data in Google Cloud. Read more about Cloud Storage [here](https://cloud.google.com/storage/docs/introduction).
1. When the pdf is uploaded, it triggers a [Cloud Function](https://cloud.google.com/functions) to process the document’s content. Cloud Functions is a serverless execution environment that allows developers to write simple, single-purpose functions that are attached to events emitted from your cloud infrastructure and services, billed in a pay-as-you-go model. Read more about Cloud Functions [here](https://cloud.google.com/functions/docs/concepts/overview).
1. The Cloud Function uses [Google Document AI](https://cloud.google.com/document-ai) to process the document in the following manner:
    * It uses a [Custom Document Extractor](https://cloud.google.com/document-ai/docs/workbench/build-custom-processor) trained to extract labeled entities from the first page of the document. In the case of this POC, 6 labeled entities are extracted:
        * Barcode number
        * Classification code
        * Classification level
        * File number
        * Org code
        * Volume
    * It uses [Optional Character Recognition (OCR)](https://cloud.google.com/document-ai/docs/overview#dai-processors) to extract text from the remaining pages.
    * It then stores the processed document in [Document AI Warehouse](https://cloud.google.com/document-ai-warehouse).
1. Using the [Document AI Warehouse UI](https://cloud.google.com/document-warehouse/docs/administer-warehouse), users can then perform tasks such as searching, filtering, and downloading the stored documents.

## Deployment

See [deployment manual](./docs/deployment.md)