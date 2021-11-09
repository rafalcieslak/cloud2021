data "amazon-ami" "debian" {
  filters = {
    name                = "*debian-10-amd64*"
    virtualization-type = "hvm"
  }

  most_recent = true
  owners      = ["136693071363"]
  region      = "eu-west-1"
}

source "amazon-ebs" "demo" {
  ami_description = "demo-server"
  ami_name        = "demo-server"
  instance_type   = "t2.micro"
  region          = "eu-west-1"
  source_ami      = data.amazon-ami.debian.id
  ssh_username    = "admin"
}

build {
  sources = ["source.amazon-ebs.demo"]

  provisioner "ansible" {
    playbook_file = "../../ansible/nginx4.yml"
  }

}
