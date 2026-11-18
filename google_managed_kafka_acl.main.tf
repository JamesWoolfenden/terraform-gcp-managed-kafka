resource "google_managed_kafka_acl" "main" {
  for_each = var.acls

  acl_id   = each.key
  cluster  = google_managed_kafka_cluster.main.cluster_id
  location = var.region

  dynamic "acl_entries" {
    for_each = each.value
    content {
      principal       = acl_entries.value.principal
      operation       = acl_entries.value.operation
      permission_type = acl_entries.value.permission_type
      host            = "*"
    }
  }

  depends_on = [google_managed_kafka_topic.main]
}
