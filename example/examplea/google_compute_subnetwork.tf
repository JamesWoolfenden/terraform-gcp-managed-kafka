# holden:ignore:HLD_GCP_026: Just enough to drive the example
resource "google_compute_subnetwork" "kafka" {
  name                     = "managed-kafka-clients"
  ip_cidr_range            = "10.93.0.0/24"
  region                   = local.region
  network                  = google_compute_network.private.id
  private_ip_google_access = true
}
