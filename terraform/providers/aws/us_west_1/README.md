# configure terraform remote
terraform remote config \
    -backend=s3 \
    -backend-config="bucket=letuschop-terraform" \
    -backend-config="key=us-west-1/terraform.tfstate" \
    -backend-config="region=us-west-1"
