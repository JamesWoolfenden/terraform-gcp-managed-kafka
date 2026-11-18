resource "google_kms_key_ring" "kafka" {
  name     = "managed-kafka-keyring"
  location = local.region
}
