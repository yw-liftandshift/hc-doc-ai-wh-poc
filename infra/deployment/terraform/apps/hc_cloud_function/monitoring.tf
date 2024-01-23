locals {
  notification_rate_limit_period = "300s"
}

resource "google_monitoring_alert_policy" "errors" {
  display_name = "${google_cloudfunctions_function.hc.name} Cloud Function errors"
  documentation {
    content = <<EOF
1. Go to Cloud Functions -> ${google_cloudfunctions_function.hc.name} -> Logs and check the logs for errors.
EOF
  }
  combiner = "OR"
  conditions {
    display_name = "${google_cloudfunctions_function.hc.name} Cloud Function errors"
    condition_matched_log {
      filter = "resource.labels.function_name=${google_cloudfunctions_function.hc.name} AND severity=\"ERROR\""
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = local.notification_rate_limit_period
    }
  }
  notification_channels = var.monitoring_notification_channel_ids
}