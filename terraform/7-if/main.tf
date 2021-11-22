provider "google" {
  project = "cloud-ii-182720"
  region  = "europe-west3"
}


module "production_environment" {
  source = "./my_module/"

  environment_name = "production"
  main_server_type = "n1-standard-1"

  needs_database = true
}

module "staging_environment" {
  source = "./my_module/"

  environment_name = "staging"
  main_server_type = "f1-micro"
}


output "production_server_ip" {
  value = module.production_environment.server_ip
}
output "staging_server_ip" {
  value = module.staging_environment.server_ip
}
