#--------------------------------------------------------------
# This module creates all resources necessary for letuschop
#--------------------------------------------------------------

variable "name"               { default = "letuschop" }
variable "region"             { }
variable "vpc_id"             { }
variable "vpc_cidr"           { }
variable "key_name"           { }
variable "azs"                { }
variable "public_subnet_ids"  { }
variable "private_subnet_ids" { }
variable "ami"                { }
variable "nodes"              { }
variable "instance_type"      { }

//
// ELB Security Group
//

resource "aws_security_group" "letuschop_elb" {
  lifecycle { create_before_destroy = true }
  vpc_id      = "${var.vpc_id}"
  tags      {
    Name = "${var.name}-elb"
    description = "Security group for letuschop ELB"
  }
}

resource "aws_security_group_rule" "elb_letuschop_public_ingress_allow_80_world" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb_letuschop_public_ingress_allow_8080_world" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb_letuschop_public_egress_allow_80_letuschop_ec2" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_elb.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  source_security_group_id = "${aws_security_group.letuschop_ec2.id}"
}

resource "aws_security_group_rule" "elb_letuschop_public_egress_allow_8080_letuschop_ec2" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_elb.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 8080
  to_port           = 8080
  source_security_group_id   = "${aws_security_group.letuschop_ec2.id}"
}

//
// EC2 Security Group
//

resource "aws_security_group" "letuschop_ec2" {
  lifecycle { create_before_destroy = true }
  vpc_id      = "${var.vpc_id}"
  tags      {
    Name = "${var.name}-ec2"
    description = "Security group for letuschop EC2"
  }
}

resource "aws_security_group_rule" "letuschop_ec2_ingress_allow_80_letuschop_elb" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_ec2.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  source_security_group_id   = "${aws_security_group.letuschop_elb.id}"
}

resource "aws_security_group_rule" "letuschop_ec2_ingress_allow_8080_letuschop_elb" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_ec2.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8080
  to_port           = 8080
  source_security_group_id   = "${aws_security_group.letuschop_elb.id}"
}

resource "aws_security_group_rule" "letuschop_ec2_ingress_allow_22_letuschop_vpc" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_ec2.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${split(",", var.vpc_cidr)}"]
}

resource "aws_security_group_rule" "letuschop_ec2_egress_allow_world" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_ec2.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "letuschop_ec2_egress_allow_letuschop_consul" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_ec2.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 8300
  to_port           = 8302
  source_security_group_id   = "${aws_security_group.letuschop_ec2.id}"
}

resource "aws_security_group_rule" "letuschop_ec2_ingress_allow_letuschop_consul" {
  lifecycle { create_before_destroy = true }
  security_group_id = "${aws_security_group.letuschop_ec2.id}"
  type              = "ingress"
  protocol          = "-1"
  from_port         = 8300
  to_port           = 8302
  source_security_group_id   = "${aws_security_group.letuschop_ec2.id}"
}

//
// Load Balancer
//

resource "aws_elb" "letuschop_elb" {
  lifecycle { create_before_destroy = true }
  connection_draining         = true
  connection_draining_timeout = 400

  subnets         = ["${split(",", var.public_subnet_ids)}"]
  security_groups = ["${aws_security_group.letuschop_elb.id}"]

  internal = false

  tags {
    Name = "letuschop"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "tcp"
    instance_port     = 80
    instance_protocol = "tcp"
  }

  listener {
    lb_port            = 8080
    lb_protocol        = "tcp"
    instance_port      = 8080
    instance_protocol  = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
    target              = "HTTP:80/health"
  }
}

//
// Template
//

resource "template_file" "user_data" {
  lifecycle { create_before_destroy = true }
  template = "${file("${path.module}/cloud-init.sh.tpl")}"

  vars {
    node_name               = "${var.name}"
    region                  = "${var.region}"
    consul_bootstrap_expect = "${var.nodes}"
  }
}

//
// Launch Configuration
//

resource "aws_launch_configuration" "letuschop" {
  lifecycle { create_before_destroy = true }
  name_prefix          = "${var.name}"
  image_id             = "${var.ami}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.letuschop_ec2.id}"]
  user_data            = "${template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.letuschop.id}"

# The packer build
# 12 is the minimum size
  root_block_device {
    volume_size = "12"
    delete_on_termination = true
  }
}

//
// AutoScale Group
//

resource "aws_autoscaling_group" "letuschop" {
  lifecycle { create_before_destroy = true }
  name                  = "${aws_launch_configuration.letuschop.name}"
  launch_configuration  = "${aws_launch_configuration.letuschop.name}"
  desired_capacity      = "${var.nodes}"
  min_size              = "${var.nodes}"
  max_size              = "${var.nodes}"
  wait_for_elb_capacity = "${var.nodes}"
  wait_for_capacity_timeout = "5m"
  availability_zones    = ["${split(",", var.azs)}"]
  vpc_zone_identifier   = ["${split(",", var.private_subnet_ids)}"]
  load_balancers        = ["${aws_elb.letuschop_elb.id}"]

  tag {
    key   = "Name"
    value = "letuschop"
    propagate_at_launch = true
  }

}

//
// Policies
//

resource "aws_iam_policy" "letuschop" {
    name = "letuschop_${var.key_name}"
    path = "/"
    description = "allows letuschop instances to lookup other letuschop instances"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:Describe*",
            "Resource": "*"
        }
    ]
}
EOF
}

//
// Roles
//

resource "aws_iam_role" "letuschop" {
    name = "letuschop_${var.key_name}"
    assume_role_policy = <<EOF
{
"Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

//
// Attach policy to roles
//

resource "aws_iam_policy_attachment" "letuschop" {
  name = "letuschop_${var.key_name}"
  roles = [
    "${aws_iam_role.letuschop.name}"
  ]
  policy_arn = "${aws_iam_policy.letuschop.arn}"
}

//
// Create an istance profile from a role
//

resource "aws_iam_instance_profile" "letuschop" {
 name = "letuschop_${var.key_name}"
 roles = ["${aws_iam_role.letuschop.name}"]
}

//
// Outputs
//

output "elb_dns"             { value = "${aws_elb.letuschop_elb.dns_name}" }
