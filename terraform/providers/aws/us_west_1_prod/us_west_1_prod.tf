variable "name"              { }
variable "artifact_type"     { }
variable "region"            { }
variable "public_key_path"   { }
variable "letuschop_ami"           { }
variable "letuschop_node_count"    { }
variable "letuschop_instance_type" { }

data "terraform_remote_state" "us_west_1" {
    backend = "s3"
    config {
        bucket = "letuschop-terraform"
        key = "us-west-1/terraform.tfstate"
        region = "us-west-1"
    }
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  lifecycle { create_before_destroy = true }
  key_name   = "${var.name}"
  public_key = "${file(var.public_key_path)}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name               = "${var.name}"
  region             = "${var.region}"
  vpc_id             = "${data.terraform_remote_state.us_west_1.vpc_id}"
  vpc_cidr           = "${data.terraform_remote_state.us_west_1.vpc_cidr}"
  key_name           = "${aws_key_pair.site_key.key_name}"
  azs                = "${data.terraform_remote_state.us_west_1.azs}"
  private_subnet_ids = "${data.terraform_remote_state.us_west_1.private_subnet_ids}"
  public_subnet_ids  = "${data.terraform_remote_state.us_west_1.public_subnet_ids}"

  letuschop_ami           = "${var.letuschop_ami}"
  letuschop_node_count    = "${var.letuschop_node_count}"
  letuschop_instance_type = "${var.letuschop_instance_type}"

}

output "configuration" {
  value = <<CONFIGURATION

Visit the website:
  ELB DNS: ${module.compute.letuschop_elb_dns}

CONFIGURATION
}
