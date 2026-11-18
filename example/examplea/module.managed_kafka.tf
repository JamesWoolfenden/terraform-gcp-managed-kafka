# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "managed_kafka" {
  source       = "../../"
  cluster_id   = "example-kafka"
  region       = local.region
  kms_key_name = google_kms_crypto_key.kafka.id
  subnets      = [google_compute_subnetwork.kafka.id]

  topics = {
    "orders" = {
      partition_count = 6
      configs = {
        "cleanup.policy" = "delete"
        "retention.ms"   = "604800000"
      }
    }
  }

  acls = {
    "topic/orders" = [
      {
        principal = "User:${google_service_account.producer.email}"
        operation = "WRITE"
      },
      {
        principal = "User:${google_service_account.producer.email}"
        operation = "DESCRIBE"
      },
    ]
  }

  labels = {
    team = "streaming"
  }
}
