#--------------------------------------------------------------
# This module creates all compute resources
#--------------------------------------------------------------

variable "name"               { }
variable "region"               { }
variable "vpc_id"             { }
variable "vpc_cidr"           { }
variable "key_name"           { }
variable "azs"                { }
variable "private_subnet_ids" { }
variable "public_subnet_ids"  { }

variable "letuschop_ami"           { }
variable "letuschop_node_count"    { }
variable "letuschop_instance_type" { }

module "letuschop" {
  source = "./letuschop"

  name               = "${var.name}-letuschop"
  region             = "${var.region}"
  vpc_id             = "${var.vpc_id}"
  vpc_cidr           = "${var.vpc_cidr}"
  key_name           = "${var.key_name}"
  azs                = "${var.azs}"
  private_subnet_ids = "${var.private_subnet_ids}"
  public_subnet_ids  = "${var.public_subnet_ids}"
  ami                = "${var.letuschop_ami}"
  nodes              = "${var.letuschop_node_count}"
  instance_type      = "${var.letuschop_instance_type}"
}

output "letuschop_elb_dns"  { value = "${module.letuschop.elb_dns}" }
