resource "google_workflows_workflow" "process_documents" {
  name            = "process-documents"
  region          = "northamerica-northeast1"
  description     = "Process Documents Workflow"
  service_account = var.process_documents_workflow_sa_email
  source_contents = <<-EOF
main:
  params: [event]
  steps:
    - decode_pubsub_message:
        assign:
          - base64: $${base64.decode(event.data.message.data)}
          - decoded_json_message: $${json.decode(text.decode(base64))}
          - batch_id: $${decoded_json_message.batch_id}
    - log_decoded_json_message:
        call: sys.log
        args:
          text: $${decoded_json_message}
    - extract_pdf_first_page:
        call: http.post
        args:
          url: ${var.extract_pdf_first_page_cloud_function_url}
          body:
            google_cloud_storage:
              input:
                bucket: ${var.google_cloud_storage_documents_bucket}
                folder: $${batch_id}
              output:
                bucket: ${google_storage_bucket.process_documents_workflow.name}
                folder: $${batch_id + "/extract-first-page"}
          auth:
              type: OIDC
              audience: ${var.extract_pdf_first_page_cloud_function_url}
    - batch_classifier:
        call: googleapis.documentai.v1.projects.locations.processors.batchProcess
        args:
          name: ${var.documents_classifier_processor_id}
          location: ${var.documents_classifier_processor_location}
          body:
            inputDocuments:
              gcsPrefix: 
                gcsUriPrefix: $${"${google_storage_bucket.process_documents_workflow.url}" + "/" + batch_id + "/extract-first-page"}
            documentOutputConfig:
              gcsOutputConfig:
                gcsUri: $${"${google_storage_bucket.process_documents_workflow.url}" + "/" + batch_id + "/batch-classifier"}
                fieldMask: entities
            skipHumanReview: true
        result: batch_classifier_resp
    - log_batch_classifier_resp:
        call: sys.log
        args:
          text: $${batch_classifier_resp}
    - classify_documents:
        call: http.post
        args:
          url: ${var.classify_documents_cloud_function_url}
          body: $${batch_classifier_resp}
          auth:
              type: OIDC
              audience: ${var.classify_documents_cloud_function_url}
        result: classify_documents_resp
    - log_classify_documents_resp:
        call: sys.log
        args:
          text: $${classify_documents_resp}
    - assign_cde_processors_shared_vars:
        assign:
          - lrs_processor_resp: ""
          - general_processor_resp: ""
    - cde_processors:
        parallel:
          shared: [lrs_processor_resp, general_processor_resp]
          branches:
            - lrs_processor:
                steps:
                  - lrs_processor_call:
                      call: googleapis.documentai.v1.projects.locations.processors.batchProcess
                      args:
                        name: ${var.lrs_documents_cde_processor_id}
                        location: ${var.lrs_documents_cde_processor_location}
                        body:
                          inputDocuments:
                            gcsDocuments:
                              documents: $${classify_documents_resp.body.lrs}
                          documentOutputConfig:
                            gcsOutputConfig:
                              gcsUri: $${"${google_storage_bucket.process_documents_workflow.url}" + "/" + batch_id + "/lrs-processor"}
                              fieldMask: entities
                          skipHumanReview: true
                      result: lrs_processor_resp
            - general_processor:
                steps:
                  - general_processor_call:
                      call: googleapis.documentai.v1.projects.locations.processors.batchProcess
                      args:
                        name: ${var.general_documents_cde_processor_id}
                        location: ${var.general_documents_cde_processor_location}
                        body:
                          inputDocuments:
                            gcsDocuments:
                              documents: $${classify_documents_resp.body.general}
                          documentOutputConfig:
                            gcsOutputConfig:
                              gcsUri: $${"${google_storage_bucket.process_documents_workflow.url}" + "/" + batch_id + "/general-processor"}
                              fieldMask: entities
                          skipHumanReview: true
                      result: general_processor_resp
    - returnOutput:
        return: $${lrs_processor_resp}
EOF

  depends_on = [
    google_storage_bucket_iam_member.process_documents_workflow_process_documents_workflow_sa,
    google_storage_bucket_iam_member.process_documents_workflow_extract_pdf_first_page_cloud_function_sa,
    google_storage_bucket_iam_member.documents_bucket_extract_pdf_first_page_cloud_function_sa,
    google_storage_bucket_iam_member.process_documents_workflow_classify_documents_cloud_function_sa,
  ]
}

resource "google_eventarc_trigger" "process_documents_workflow" {
  name            = "process-documents-workflow-trigger"
  location        = "northamerica-northeast1"
  service_account = var.process_documents_workflow_sa_email
  transport {
    pubsub {
      topic = var.process_documents_workflow_pubsub_topic_id
    }
  }
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    workflow = google_workflows_workflow.process_documents.id
  }
}