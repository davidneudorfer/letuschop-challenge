#--------------------------------------------------------------
# General
#--------------------------------------------------------------

name              = "west"
region            = "us-west-1"
sub_domain        = "us-west-1.aws"
artifact_type     = "amazon.image"
public_key_path   = "keys/letuschop_rsa.pub"

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

vpc_cidr        = "10.139.0.0/16"
azs             = "us-west-1a,us-west-1b" # AZs are region specific
private_subnets = "10.139.1.0/24,10.139.2.0/24" # Creating one private subnet per AZ
public_subnets  = "10.139.11.0/24,10.139.12.0/24" # Creating one public subnet per AZ

# Bastion
bastion_instance_type = "t2.micro"
