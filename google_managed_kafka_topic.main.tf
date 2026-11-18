resource "google_managed_kafka_topic" "main" {
  for_each = var.topics

  topic_id           = each.key
  cluster            = google_managed_kafka_cluster.main.cluster_id
  location           = var.region
  partition_count    = each.value.partition_count
  replication_factor = each.value.replication_factor
  configs            = each.value.configs
}
