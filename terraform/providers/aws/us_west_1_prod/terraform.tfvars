#--------------------------------------------------------------
# General
#--------------------------------------------------------------

name              = "prod"
region            = "us-west-1"
artifact_type     = "amazon.image"
public_key_path   = "keys/letuschop_rsa.pub"

#--------------------------------------------------------------
# Compute
#--------------------------------------------------------------

# ami built by letuschop.json but the variable is updated
# inplace by local/build.sh
letuschop_ami = "ami-eb77358b"
letuschop_node_count    = "2"
letuschop_instance_type = "t2.micro"
