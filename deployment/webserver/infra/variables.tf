variable "region" { default = "eu-west-1" }
variable "component" {}
variable "deployment_identifier" {}
variable "estate" {}
variable "service" {}

variable "bastion_ssh_public_key_path" {}
variable "webserver_ssh_public_key_path" {}
variable "availability_zones" { default = "eu-west-1a,eu-west-1b,eu-west-1c" }

variable "base_dns_domain" {}
variable "allowed_cidr" {}
