resource "google_compute_address" "public_ip" {
  name         = "server-ip"
  address_type = "EXTERNAL"
}

output "server_ip_address" {
  value = google_compute_address.public_ip.address
}
