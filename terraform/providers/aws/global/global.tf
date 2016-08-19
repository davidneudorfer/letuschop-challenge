variable "name"              { }
variable "region"            { }
variable "iam_admins"        { }

provider "aws" {
  region = "${var.region}"
}

module "iam_admin" {
  source = "../../../modules/aws/util/iam"

  name       = "${var.name}-admin"
  users      = "${var.iam_admins}"
  policy     = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Effect"  : "Deny",
      "Action"  : "*",
      "Resource": "*"
    }
  ]
}
EOF
}

/*output "users"       { value = "${module.iam_admin.users)}" }
output "access_ids"  { value = "${module.iam_admin.access_ids)}" }
output "secret_keys" { value = "${module.iam_admin.secret_keys)}" }*/
