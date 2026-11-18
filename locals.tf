locals {
  # The Managed Service for Apache Kafka Service Agent — the identity that
  # encrypts broker storage with the CMEK key.
  managed_kafka_service_agent = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-managedkafka.iam.gserviceaccount.com"
}
