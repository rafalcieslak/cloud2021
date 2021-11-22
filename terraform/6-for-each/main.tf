provider "google" {
  project = "cloud-ii-182720"
  region  = "europe-west3"
}

locals {
  availability_zones = {
    A = "eu-west3-a"
    B = "eu-west3-b"
    C = "eu-west3-c"
  }
}

resource "google_compute_address" "public_ip" {
  for_each = local.availability_zones

  name         = "server-ip-${lower(each.key)}"
  address_type = "EXTERNAL"
}


resource "google_compute_instance" "server" {
  for_each = local.availability_zones

  name         = "server-${each.key}"
  machine_type = "f1-micro"
  zone         = each.value   # <---

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.public_ip[each.key].address
    }
  }

  tags = ["http-server"]

  metadata = {
    sshKeys = "cielak:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVFpY12c9/oj9TUxsKc8b24txsTCtHV7+p3qJUHlxA8iD6a9WUN28JfGT3Kp9wBLOnOklKUqunUmfBTJF5fkpTlfsXQ8TFfVCahbJI81Lu2mp3lKjEsOKYFHMEVUzxt3WmKLpWMX0P0T9tcAQ92iej2UOcLvPMDNnM3TlXUKNh0g04fIvjmZqEClwC+QoXMYIG/+YZAA/7n6uO7JpHUifbSiKxMadhohtFWQF1SIWh0heG/uhmJlxBhePpii9niwPaiId5LXp/07aPlpRDuytsGbxbvucpIlQ/Xbgb0qNEuGLfssynLr9M7laoKBbEGta86HCnF9gBO1yLmEe05XN5"
  }
}
