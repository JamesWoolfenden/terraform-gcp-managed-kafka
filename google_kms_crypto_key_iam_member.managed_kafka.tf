resource "google_kms_crypto_key_iam_member" "managed_kafka" {
  crypto_key_id = var.kms_key_name
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = local.managed_kafka_service_agent
}
