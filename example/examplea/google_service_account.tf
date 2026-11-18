resource "google_service_account" "producer" {
  account_id   = "kafka-producer"
  display_name = "Producer client for the example Kafka cluster"
}
