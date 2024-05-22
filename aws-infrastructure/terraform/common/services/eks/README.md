## Requirements

* AWS account with Administrator access
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-cli) installed (~> v1.7.0)
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.htmlhttps://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2 installed
* [kubectl](https://kubernetes.io/docs/tasks/tools/) (1.28, 1.29) installed

## Generate and configure aws cli credentials

First generate AWS cli credentials on your AWS account and then configure the credentials on your system

> aws configure --profile training

## Provision infrastructure

First update the `terraform.tfvars` file to put your desired configurations

Download and install provider and modules
> terraform init

Validate infrastructure configurations
> terraform validate

Plan VPC and EKS cluster
> terraform plan -out planfile -target module.vpc -target module.eks -target null_resource.next

Create VPC and EKS cluster
>terraform apply planfile

Plan EKS cluster nodes
> terraform plan -out planfile

Create EKS cluster nodes
> terraform apply planfile

## Destroying infrastructure

> terraform destroy
