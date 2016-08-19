# letuschop

## prerequisites
Install [docker-toolbox](https://www.docker.com/products/docker-toolbox) and ensure you're able to run docker.  
`AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` need to be in your enviroment.

## run

`make` to see all options  
`make build` to complete challenge

## what `make build` does

* ensures terraform remote config bucket is created
* builds:
  * vpc
  * public subnet
    * bastian host
    * application elb
  * private subnet
    * letuschop autoscale group

* When `make build` completes the new elb will be in stdout.
* Browse to the elb dns and you'll see "Automation for the People" printed on the homepage.

## fun stuff

Browse to the elb on port 8080, click "KEY/VALUE", create a key called "homepage_text" and enter any text you want. Return to the elb on port 80 and you'll see the text you entered.

## technologies used

* docker
* docker-machine
* docker-compose
* packer
* terraform
* consul

### errors

Sometimes AWS will rate limit the number of API requests and Terrform will get the error `You are not authorized to perform this operation.` If this happens re-run the Terrform portion by running `make terraform`
