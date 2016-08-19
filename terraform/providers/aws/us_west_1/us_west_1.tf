variable "name"              { }
variable "artifact_type"     { }
variable "region"            { }
variable "sub_domain"        { }
variable "public_key_path"   { }
variable "vpc_cidr"        { }
variable "azs"             { }
variable "private_subnets" { }
variable "public_subnets"  { }
variable "bastion_instance_type" { }

provider "aws" {
  region = "${var.region}"
}

resource "terraform_remote_state" "global" {
    backend = "s3"
    config {
        bucket = "letuschop-terraform"
        key = "global/terraform.tfstate"
        region = "us-west-1"
    }
}

resource "aws_key_pair" "site_key" {
  lifecycle { create_before_destroy = true }
  key_name   = "${var.name}"
  public_key = "${file(var.public_key_path)}"
}

module "network" {
  source = "../../../modules/aws/network"

  name            = "${var.name}"
  vpc_cidr        = "${var.vpc_cidr}"
  azs             = "${var.azs}"
  region          = "${var.region}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"
  key_name        = "${aws_key_pair.site_key.key_name}"

  bastion_instance_type = "${var.bastion_instance_type}"
}

output "vpc_id"             { value = "${module.network.vpc_id}" }
output "vpc_cidr"           { value = "${module.network.vpc_cidr}" }
output "azs"                { value = "${module.network.azs}" }
output "private_subnet_ids" { value = "${module.network.private_subnet_ids}" }
output "public_subnet_ids"  { value = "${module.network.public_subnet_ids}" }
