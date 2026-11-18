output "id" {
  value       = google_managed_kafka_cluster.main.id
  description = "ID of the Kafka cluster"
}

output "name" {
  value       = google_managed_kafka_cluster.main.name
  description = "Full resource name of the Kafka cluster"
}

output "topic_ids" {
  value       = { for k, v in google_managed_kafka_topic.main : k => v.id }
  description = "IDs of the topics, keyed by topic ID"
}
