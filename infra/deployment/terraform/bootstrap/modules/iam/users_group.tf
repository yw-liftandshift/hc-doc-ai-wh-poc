resource "google_project_iam_custom_role" "dw_user" {
  project     = data.google_project.project.project_id
  role_id     = "${random_id.random.hex}.documentAIWarehouseUser"
  title       = "Document AI Warehouse User"
  description = "Contains the necessary permissions to use the Document AI Warehouse UI and trigger document processing."
  permissions = [
    "contentwarehouse.documentSchemas.create",
    "contentwarehouse.documentSchemas.delete",
    "contentwarehouse.documentSchemas.get",
    "contentwarehouse.documentSchemas.list",
    "contentwarehouse.documentSchemas.update",
    "contentwarehouse.documents.create",
    "contentwarehouse.documents.delete",
    "contentwarehouse.documents.get",
    "contentwarehouse.documents.getIamPolicy",
    "contentwarehouse.documents.setIamPolicy",
    "contentwarehouse.documents.update",
    "contentwarehouse.locations.initialize",
    "contentwarehouse.operations.get",
    "contentwarehouse.rawDocuments.download",
    "contentwarehouse.rawDocuments.upload",
    "contentwarehouse.ruleSets.create",
    "contentwarehouse.ruleSets.delete",
    "contentwarehouse.ruleSets.get",
    "contentwarehouse.ruleSets.list",
    "contentwarehouse.ruleSets.update",
    "contentwarehouse.synonymSets.create",
    "contentwarehouse.synonymSets.delete",
    "contentwarehouse.synonymSets.get",
    "contentwarehouse.synonymSets.list",
    "contentwarehouse.synonymSets.update",
    "firebase.projects.get",
    "orgpolicy.policy.get",
    "recommender.iamPolicyInsights.get",
    "recommender.iamPolicyInsights.list",
    "recommender.iamPolicyInsights.update",
    "recommender.iamPolicyRecommendations.get",
    "recommender.iamPolicyRecommendations.list",
    "recommender.iamPolicyRecommendations.update",
    "resourcemanager.projects.get",
    "storage.buckets.create",
    "storage.buckets.createTagBinding",
    "storage.buckets.delete",
    "storage.buckets.deleteTagBinding",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.getObjectInsights",
    "storage.buckets.list",
    "storage.buckets.listEffectiveTags",
    "storage.buckets.listTagBindings",
    "storage.buckets.setIamPolicy",
    "storage.buckets.update",
    "storage.multipartUploads.abort",
    "storage.multipartUploads.create",
    "storage.multipartUploads.list",
    "storage.multipartUploads.listParts",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.getIamPolicy",
    "storage.objects.list",
    "storage.objects.setIamPolicy",
    "storage.objects.update",
  ]
}

resource "google_project_iam_member" "dw_user_users_group" {
  project = data.google_project.project.project_id
  role    = google_project_iam_custom_role.dw_user.name
  member  = "group:${var.users_group_email}"
}