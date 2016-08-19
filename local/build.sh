#!/bin/bash

# This script wraps the packer and terraform commands
#
# Usage:
#   # to build a packer image
#   $ build.sh -d ami

set -e

OPTIND=1 # Reset in case getopts has been used previously in the shell.
DEPLOY=""

while getopts "d:" OPT; do
    case "$OPT" in
    d) DEPLOY=$OPTARG ;;
    esac
done

export WORKDIR=$(pwd)/../

DEPLOY_COMMAND=""
case "$DEPLOY" in

    "ami")
        echo "########## PACKER ##########"
        cd $WORKDIR/packer
        packer build -machine-readable letuschop.json | tee build.log
        AMI=$(egrep -m1 -oe 'ami-.{8}' build.log)
        sed -i -e 's/letuschop_ami.*/letuschop_ami = "'$AMI'"/g' \
          $WORKDIR/terraform/providers/aws/us_west_1_prod/terraform.tfvars ;;

    "global-setup")
        echo "########## GLOBAL SETUP ##########"
        cd $WORKDIR/terraform/providers/aws/global
        terraform remote config \
          -backend=s3 \
          -backend-config="bucket=letuschop-terraform" \
          -backend-config="key=global/terraform.tfstate" \
          -backend-config="region=us-west-1"
        terraform get ;;

    "global-plan")
        echo "########## GLOBAL PLAN ##########"
        cd $WORKDIR/terraform/providers/aws/global
        terraform plan -out terraform.tfplan ;;

    "global-apply")
        echo "########## GLOBAL APPLY ##########"
        cd $WORKDIR/terraform/providers/aws/global
        terraform apply terraform.tfplan
        rm terraform.tfplan ;;

    "global-destroy")
        echo "########## GLOBAL PLAN DESTROY ##########"
        cd $WORKDIR/terraform/providers/aws/global
        terraform destroy -force ;;

    "west-setup")
        echo "########## US-WEST-1 SETUP ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1
        terraform remote config \
          -backend=s3 \
          -backend-config="bucket=letuschop-terraform" \
          -backend-config="key=us-west-1/terraform.tfstate" \
          -backend-config="region=us-west-1"
        terraform get ;;

    "west-plan")
        echo "########## US-WEST-1 PLAN ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1
        terraform plan -out terraform.tfplan ;;

    "west-apply")
        echo "########## US-WEST-1 APPLY ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1
        terraform apply terraform.tfplan
        rm terraform.tfplan ;;

    "west-plan")
        echo "########## US-WEST-1 PLAN DESTROY ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1
        terraform plan -out terraform.tfplan ;;

    "west-destroy")
        echo "########## WEST PLAN DESTROY ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1
        terraform destroy -force ;;

    "prod-setup")
        echo "########## US-WEST-1 PROD ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1_prod
        terraform remote config \
          -backend=s3 \
          -backend-config="bucket=letuschop-terraform" \
          -backend-config="key=us-west-1-prod/terraform.tfstate" \
          -backend-config="region=us-west-1"
        terraform get ;;

    "prod-plan")
        echo "########## US-WEST-1 PROD ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1_prod
        terraform plan -out terraform.tfplan ;;

    "prod-apply")
        echo "########## US-WEST-1 PROD ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1_prod
        terraform apply terraform.tfplan
        rm terraform.tfplan ;;

    "prod-plan-destroy")
        echo "########## PROD PLAN DESTROY ##########"
        cd $WORKDIR/terraform/providers/aws/us_west_1_prod
        terraform destroy -force ;;
    *)
esac
