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
    - classify_documents:
        call: googleapis.documentai.v1.projects.locations.processors.batchProcess
        args:
          name: ${var.documents_classifier_processor_id}
          location: ${var.documents_classifier_processor_location}
          body:
            inputDocuments:
              gcsPrefix: 
                gcsUriPrefix: $${"${data.google_storage_bucket.documents.url}" + "/" + batch_id}
            documentOutputConfig:
              gcsOutputConfig:
                gcsUri: $${"${google_storage_bucket.process_documents_workflow.url}" + "/" + batch_id + "/classify-documents"}
            skipHumanReview: true
        result: classify_documents_resp
    - returnOutput:
        return: $${classify_documents_resp}
EOF

depends_on = [
  google_storage_bucket_iam_member.documents_bucket_process_documents_workflow_sa,
  google_storage_bucket_iam_member.process_documents_workflow_process_documents_workflow_sa
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