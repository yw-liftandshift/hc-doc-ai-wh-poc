resource "google_workflows_workflow" "process_documents" {
  name            = "process-documents"
  region          = "northamerica-northeast1"
  description     = "Process Documents Workflow"
  service_account = var.process_documents_workflow_sa_email
  source_contents = <<-EOF
main:
  params: [event]
  steps:
    - init:
        assign:
          - base64: $${base64.decode(event.data.message.data)}
          - decoded_json_message: $${json.decode(text.decode(base64))}
          - batch_id: $${decoded_json_message.batch_id}
          - ocr_result: ""
          - lrs_result: ""
          - general_result: ""
    - log_decoded_json_message:
        call: sys.log
        args:
          text: $${decoded_json_message}
    - process_documents:
        parallel:
          shared: [ocr_result, lrs_result, general_result]
          branches:
            - ocr:
                steps:
                  - batch_ocr:
                      call: googleapis.documentai.v1.projects.locations.processors.batchProcess
                      args:
                        name: ${var.ocr_processor_id}
                        location: ${var.ocr_processor_location}
                        body:
                          inputDocuments:
                            gcsPrefix:
                              gcsUriPrefix: $${"${data.google_storage_bucket.documents.url}" + "/" + batch_id}
                          documentOutputConfig:
                            gcsOutputConfig:
                              gcsUri: $${"${google_storage_bucket.process_documents_workflow.url}" + "/" + batch_id + "/ocr"}
                              fieldMask: text
                          skipHumanReview: true
                      result: ocr_processor_resp
                  - postprocess_ocr:
                      call: http.post
                      args:
                        url: ${var.postprocess_ocr_cloud_function_url}
                        body: $${ocr_processor_resp}
                        auth:
                          type: OIDC
                          audience: ${var.postprocess_ocr_cloud_function_url}
                      result: ocr_result
            - extract_properties:
                steps:
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
                  - cde_processors:
                      parallel:
                        shared: [lrs_result, general_result]
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
                                - postprocess_lrs:
                                    call: http.post
                                    args:
                                      url: ${var.postprocess_lrs_cloud_function_url}
                                      body: $${lrs_processor_resp}
                                      auth:
                                        type: OIDC
                                        audience: ${var.postprocess_lrs_cloud_function_url}
                                    result: lrs_result
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
                                    result: general_result
    - merge_results:
        assign:
          - merged_results: $${map.merge_nested(ocr_result.body, lrs_result.body)}
    - load_process_documents_result:
        call: http.post
        args:
          url: ${var.load_process_documents_result_cloud_function_url}
          body: $${merged_results}
          auth:
            type: OIDC
            audience: ${var.load_process_documents_result_cloud_function_url}
    - returnOutput:
        return: $${merged_results}

EOF

  depends_on = [
    google_storage_bucket_iam_member.process_documents_workflow_process_documents_workflow_sa,
    google_storage_bucket_iam_member.process_documents_workflow_extract_pdf_first_page_cloud_function_sa,
    google_storage_bucket_iam_member.documents_bucket_extract_pdf_first_page_cloud_function_sa,
    google_storage_bucket_iam_member.process_documents_workflow_classify_documents_cloud_function_sa,
    google_storage_bucket_iam_member.process_documents_workflow_postprocess_lrs_cloud_function_sa,
    google_storage_bucket_iam_member.process_documents_workflow_postprocess_ocr_cloud_function_sa,
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