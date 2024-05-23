## Requirements

* AWS account with Administrator access
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-cli) installed (~> v1.7.0)
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.htmlhttps://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2 installed
* [kubectl](https://kubernetes.io/docs/tasks/tools/) (1.28, 1.29) installed

## Generate and configure aws cli credentials

First generate AWS cli credentials on your AWS account and then configure the credentials on your system

```
aws configure --profile training
```

This is the same profile that you have to provide as input when running Terraform.

## Provision infrastructure
### Remote state bucket
First, go to ```common/remote-state-bucket``` directory and run:

```
terraform init
```
This will initialize the bucket creation project.

Then, run:

```
terraform apply
```

and provide name of the bucket that will be later used as a remote state (backend)
for EKS resources.

### EKS and Helm
Got to ```common/cluster``` directory.

Initialize the project to pull all the modules used

```
terraform init
```

Validate that the project is correctly setup.

```
terraform validate
```

Run the plan command to see all the resources that will be created

```
terraform plan
```

When you ready, run the apply command to create the resources.

```
terraform apply
```

Take a look at the outputs to get your cluster endpoint and other details.
Verify in your AWS account if the cluster has been created.
