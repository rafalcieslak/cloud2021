variable "environment_name" {
  description = "Environment name to use for naming resources."
}

variable "main_server_type" {
  description = "Server type to use for the main application server."
  default     = "g1-micro"
}

variable "needs_database" {
  description = "Whether to prepare an SQL database for the server."
  default     = false
}


resource "google_compute_address" "public_ip" {
  name         = "${var.environment_name}-server-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "main_server" {
  name         = "${var.environment_name}-server"
  machine_type = var.main_server_type
  zone         = "europe-west3-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.public_ip.address
    }
  }
}

resource "google_storage_bucket" "data-bucket" {
  name     = "example-application-data-bucket-${var.environment_name}"
  location = "EUROPE-WEST3"
}

resource "google_storage_bucket_acl" "data-bucket-acl" {
  bucket         = google_storage_bucket.data-bucket.name
  predefined_acl = "projectprivate"
}

/* DATABASE */


resource "google_sql_database_instance" "main_db" {
  count = var.needs_database ? 1 : 0

  name             = "main-db-instance"
  database_version = "POSTGRES_13"
  region           = "europe-west3"

  settings {
    tier            = "db-f1-micro"
    disk_autoresize = "true"
  }
}

resource "google_sql_database" "users" {
  count = var.needs_database ? 1 : 0

  instance  = google_sql_database_instance.main_db[0].name
  name      = "users-database"
}

resource "google_sql_user" "database_user" {
  count = var.needs_database ? 1 : 0

  instance  = google_sql_database_instance.main_db[0].name
  name      = "databaseuser"
  password  = "example-password-todo-change-this-later"
  host      = google_compute_instance.main_server.name
}


/* Many other resources! */

output "server_ip" {
  value = google_compute_address.public_ip.address
}

output "bucket_name" {
  value = google_storage_bucket.data-bucket.name
}
