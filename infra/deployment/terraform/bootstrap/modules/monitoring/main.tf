locals {
  notification_rate_limit_period = "300s"
}

resource "google_monitoring_notification_channel" "alerting_emails" {
  count        = length(var.alerting_emails)
  display_name = "Monitoring Alerts on ${var.alerting_emails[count.index]}"
  type         = "email"
  labels = {
    email_address = var.alerting_emails[count.index]
  }
  force_delete = true
}

resource "google_monitoring_alert_policy" "cloudbuild_success" {
  display_name = "Cloud Build success"
  combiner     = "OR"
  conditions {
    display_name = "Cloud Build success"
    condition_matched_log {
      filter = "resource.type=\"build\" textPayload=~\"^DONE\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "cloudbuild_error" {
  display_name = "Cloud Build error"
  combiner     = "OR"
  conditions {
    display_name = "Cloud Build error"
    condition_matched_log {
      filter = "resource.type=\"build\" textPayload=~\"^ERROR:\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "bucket_accessible_to_public" {
  display_name = "Google Cloud Storage Bucket accessible to public"
  documentation {
    content = "Investigate the logs and determine whether or not the accessed bucket should be accessible to the public."
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud Storage Bucket accessible to public"
    condition_matched_log {
      filter = "protoPayload.methodName=\"storage.setIamPermissions\" (protoPayload.serviceData.policyDelta.bindingDeltas.member=\"allUsers\" OR protoPayload.serviceData.policyDelta.bindingDeltas.member=\"allAuthenticatedUsers\") protoPayload.serviceData.policyDelta.bindingDeltas.action=\"ADD\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "bucket_modified" {
  display_name = "Google Cloud Storage Bucket modified"
  documentation {
    content = "Review the bucket to ensure that it is properly configured."
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud Storage Bucket modified"
    condition_matched_log {
      filter = "protoPayload.methodName=\"storage.buckets.update\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "bucket_permissions_modified" {
  display_name = "Google Cloud Storage Bucket permissions modified"
  documentation {
    content = "Review the bucket permissions and ensure they are not overly permissive."
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud Storage Bucket permissions modified"
    condition_matched_log {
      filter = "protoPayload.methodName=\"storage.setIamPermissions\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "buckets_enumerated_by_service_account" {
  display_name = "Buckets enumerated by Service Account"
  documentation {
    content = <<EOF
- If the account was compromised, secure the account and investigate how it was compromised and if the account made other unauthorized calls.
- If the owner of the service account intended to make the ListBuckets API call, consider whether this API call is needed. It could cause a security issue for the application to know the name of the bucket it needs to access. If it's not needed, modify this rule's filter to stop generating signals for this specific service account.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Buckets enumerated by Service Account"
    condition_matched_log {
      filter = "protoPayload.methodName=\"storage.buckets.list\" protoPayload.authenticationInfo.principalEmail=~\".*.gserviceaccount.com\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "compute_engine_firewall_rule_opened_to_the_world" {
  display_name = "Google Compute Engine firewall egress rule opened to the world"
  documentation {
    content = <<EOF
1. Determine if user from IP address {{@network.client.ip}} should have made the API call.
2. If the API call was not made by the user:
  - Rotate the user credentials.
  - Determine what other API calls were made by the user.
  - Investigate VPC flow logs and OS system logs to determine if unauthorized access occurred.
3. If the API call was made legitimately by the user:
  - Advise the user to modify the IP range to the company private network or bastion host.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Google Compute Engine firewall egress rule opened to the world"
    condition_matched_log {
      filter = "protoPayload.methodName=~\"v*.compute.firewalls.insert\" protoPayload.request.direction=\"EGRESS\" protoPayload.request.destinationRanges=\"0.0.0.0/0\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "compute_engine_firewall_rule_modified" {
  display_name = "Google Compute Engine firewall rule modified"
  documentation {
    content = <<EOF
1. Review the log and role and ensure the permissions are scoped properly.
2. Review the users associated with the role and ensure they should have the permissions attached to the role.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Google Compute Engine firewall rule modified"
    condition_matched_log {
      filter = "protoPayload.methodName=\"v1.compute.firewalls.delete\" OR protoPayload.methodName=\"v1.compute.firewalls.insert\" OR protoPayload.methodName=\"v1.compute.firewalls.patch\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "compute_engine_image_created" {
  display_name = "Google Compute Engine image created"
  documentation {
    content = <<EOF
1. Investigate the user and IP address ({{@network.client.ip}}) where the image creation activity originated from and determine whether they are authorised to perform this activity.
2. If the action is legitimate, consider including the user in a suppression list.
3. Otherwise, see if the user has taken other actions.
4. If the results of the triage indicate that an attacker has taken the action, begin your organization's incident response process and an investigation.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Google Compute Engine image created"
    condition_matched_log {
      filter = "protoPayload.methodName=~\"v*.compute.images.insert\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "compute_engine_network_created" {
  display_name = "Google Compute Engine network created"
  documentation {
    content = "Review the Compute Engine network."
  }
  combiner = "OR"
  conditions {
    display_name = "Google Compute Engine network created"
    condition_matched_log {
      filter = "protoPayload.methodName=~\"v*.compute.networks.insert\" OR protoPayload.methodName=\"beta.compute.networks.insert\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "compute_engine_network_route_created_or_modified" {
  display_name = "Google Compute Engine network route created or modified"
  documentation {
    content = "Verify that the GCE network route is configured properly and that the user intended to modify the firewall."
  }
  combiner = "OR"
  conditions {
    display_name = "Google Compute Engine network route created or modified"
    condition_matched_log {
      filter = "protoPayload.methodName=\"beta.compute.routes.insert\" OR protoPayload.methodName=\"beta.compute.routes.patch\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "iam_policy_modified" {
  display_name = "Google Cloud IAM policy modified"
  documentation {
    content = "Review the log and inspect the policy deltas (@data.protoPayload.serviceData.policyDelta.bindingDeltas)."
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud IAM policy modified"
    condition_matched_log {
      filter = "protoPayload.methodName=\"SetIamPolicy\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "iam_role_created" {
  display_name = "Google Cloud IAM role created"
  documentation {
    content = <<EOF
1. Investigate the user who created the IAM role {{@data.protoPayload.resourceName}} and ensure the permissions in @data.protoPayload.response.included_permissions are scoped properly.
2. Review the users associated with the role and ensure they should have the permissions attached to the role.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud IAM role created"
    condition_matched_log {
      filter = "protoPayload.methodName=\"google.iam.admin.v1.CreateRole\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "iam_role_updated" {
  display_name = "Google Cloud IAM role updated"
  documentation {
    content = <<EOF
1. Investigate the user who updated the IAM role {{@data.protoPayload.resourceName}} and ensure the permissions in @data.protoPayload.response.included_permissions are scoped properly.
2. Review the users associated with the role and ensure they should have the permissions attached to the role.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud IAM role updated"
    condition_matched_log {
      filter = "protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "logging_bucket_deleted" {
  display_name = "Google Cloud Logging Bucket deleted"
  documentation {
    content = "Determine if the Google Cloud user should be deleting the logging bucket identified in the @data.protoPayload.resourceName field."
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud Logging Bucket deleted"
    condition_matched_log {
      filter = "protoPayload.methodName=\"google.logging.v2.ConfigServiceV2.DeleteBucket\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "logging_sink_modified" {
  display_name = "Google Cloud logging sink modified"
  documentation {
    content = "Review the sink and ensure the sink is properly configured."
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud logging sink modified"
    condition_matched_log {
      filter = "protoPayload.methodName=\"google.logging.v2.ConfigServiceV2.UpdateSink\" OR protoPayload.methodName=\"google.logging.v2.ConfigServiceV2.DeleteSink\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "service_account_created" {
  display_name = "Service Account created"
  documentation {
    content = "Contact the user who created the service account and ensure that the account is needed and that the role is scoped properly."
  }
  combiner = "OR"
  conditions {
    display_name = "Service Account created"
    condition_matched_log {
      filter = "protoPayload.methodName=\"google.iam.admin.v1.CreateServiceAccount\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "service_account_key_created" {
  display_name = "Service Account Key created"
  documentation {
    content = "Contact the user who created the service account key to ensure they’re managing the key securely."
  }
  combiner = "OR"
  conditions {
    display_name = "Service Account Key created"
    condition_matched_log {
      filter = "protoPayload.methodName=\"google.iam.admin.v1.CreateServiceAccountKey\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "service_account_impersonation_activity_using_access_token_generation" {
  display_name = "Google Cloud Service Account Impersonation activity using access token generation"
  documentation {
    content = <<EOF
1. Investigate if the user from IP address:{{@network.client.ip}} intended to perform this activity.
2. If unauthorized:
  - Revoke access of compromised user and service account.
  - Investigate other activities performed by the user.
  - Investigate other activities performed by the IP {{@network.client.ip}}
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Google Cloud Service Account Impersonation activity using access token generation"
    condition_matched_log {
      filter = "protoPayload.methodName=\"GenerateAccessToken\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "unauthorized_service_account_activity" {
  display_name = "Unauthorized Service Account Activity"
  documentation {
    content = <<EOF
1. Investigate the service account that made the unauthorized calls and confirm if there is a misconfiguration in IAM permissions or if an attacker compromised the service account.
2. If unauthorized, revoke access of compromised service account and rotate credentials.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Unauthorized Service Account Activity"
    condition_matched_log {
      filter = "protoPayload.status.code=7 protoPayload.authenticationInfo.principalEmail=~\".*.gserviceaccount.com\" AND NOT protoPayload.serviceName=\"iap.googleapis.com\" AND NOT protoPayload.methodName=\"AuthorizeUser\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}

resource "google_monitoring_alert_policy" "unauthorized_user_activity" {
  display_name = "Unauthorized User Activity"
  documentation {
    content = <<EOF
1. Investigate the user that made the unauthorized calls and confirm if there is a misconfiguration in IAM permissions or if an attacker compromised the user account.
2. If unauthorized, revoke access of compromised user account and rotate credentials.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "Unauthorized User Activity"
    condition_matched_log {
      filter = "protoPayload.status.code=7 AND NOT protoPayload.authenticationInfo.principalEmail=~\".*.gserviceaccount.com\" AND NOT (protoPayload.serviceName=\"iap.googleapis.com\" AND protoPayload.methodName=\"AuthorizeUser\") AND NOT (protoPayload.methodName=\"google.devtools.sourcerepo.v1.GitProtocol.LsRemote\") AND NOT (protoPayload.methodName=\"grafeas.v1.Grafeas.ListOccurrences\")"
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = google_monitoring_notification_channel.alerting_emails.*.id
}