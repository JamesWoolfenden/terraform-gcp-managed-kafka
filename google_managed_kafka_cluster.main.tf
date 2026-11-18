resource "google_managed_kafka_cluster" "main" {
  cluster_id = var.cluster_id
  location   = var.region
  labels     = var.labels

  capacity_config {
    vcpu_count   = var.vcpu_count
    memory_bytes = var.memory_bytes
  }

  gcp_config {
    kms_key = var.kms_key_name

    access_config {
      dynamic "network_configs" {
        for_each = var.subnets
        content {
          subnet = network_configs.value
        }
      }
    }
  }

  rebalance_config {
    mode = var.rebalance_mode
  }

  depends_on = [google_kms_crypto_key_iam_member.managed_kafka]
}
