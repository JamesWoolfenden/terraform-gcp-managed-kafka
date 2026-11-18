resource "google_kms_crypto_key" "kafka" {
  name                       = "managed-kafka-key"
  key_ring                   = google_kms_key_ring.kafka.id
  rotation_period            = "7776000s"
  destroy_scheduled_duration = "2592000s"

  lifecycle {
    prevent_destroy = true
  }
}
