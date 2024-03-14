# awstraining-backend
This repository holds reference Spring Boot project that can be deployed to AWS

# Run locally
To run this application locally, please first call ```docker-compose up``` in ```/local``` directory,
in order to set up local DynamoDB instance.

Then, please configure ```application.yml```:
```yml
aws:
  region: eu-central-1
  dynamodb:
    endpoint: http://localhost:8000
    accessKey: dummyAccess
    secretKey: dummySecret
```

# Preparation to the deployment
To deploy infrastructure to your sandbox account please first fork our base repository.
To do it, go to:
* https://github.com/Alegres/awstraining-backend

and click on Fork button and then (+) Create new fork.

After forking repository to your account, please clone it to your local machine and search for all occurrences of:
* 467331071075

This is base AWS account id that we use for the base repository.
You must replace this with your own account id in all files.

Push changes to your remote repository.

Then you should create a new profile in ```C:\Users\YOURUSER\.aws\credentials``` and set credentials to your account:
```
[backend-test]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOU_SECRET_ACCESS_KEY
```

**DO NOT USER ROOT USER CREDENTIALS!** Instead, create admin user in IAM, assign him **AdministratorAccess** policy
and generate credentials for this non-root user.

Then please run bash (e.g. Git Bash), and go to ```/aws-infrastructure/terraform``` directory.
Set the following environmental variable:
```
RANDOM_STRING="dakj18akj91"
```

This random string should be some random value. It is important to come up with an unique value, as this will affect 
the name of the Terraform state bucket that will be created, thus it must be unique globally.
Please also do not make it too long.

Please again push changes to your remote repository.

# Deploying AWS infrastructure
To run Terraform you first need to install it on your local machine.
You need **terraform_1.4.6** or higher version.

Now you can run a script to set up a new AWS environment (still in ```/aws-infrastructure/terraform``` directory):
```
./setup_new_region.sh backend-test eu-central-1 emea apply -auto-approve
```

Terraform should automatically approve all changes and create all required resources one-by-one.
In case of errors, please correct them, delete from setup_new_region.sh lines that has already been executed and run 
the script again.

Then you should go to **GitHub -> Your fork repo -> Settings -> Secrets and variables**
and create two repository secrets:
* BACKEND_EMEA_TEST_AWS_KEY
* BACKEND_EMEA_TEST_AWS_SECRET

and set accordingly **AWS_KEY** and **AWS_SECRET**, same as in ```..\.aws\credentials```.

# Build & Deploy
When you are done with setting up the infrastructure, please go to your fork repository, open **Actions** tab and run
**Multibranch pipeline** on the main branch.

This branch will build Docker image, push it to ECR and deploy application to ECS Fargate.
After it has finished, you should go to your AWS account, open EC2 Load Balancers page and find
backend application load balancer.

Please then copy DNS of this load balancer and feel free to run test curls.
Example:
```
curl --location 'http://backend-lb-672995306.eu-central-1.elb.amazonaws.com/device/v1/test' \
--header 'Authorization: Basic dGVzdFVzZXI6d2VsdA=='
```

```
curl --location 'http://backend-lb-672995306.eu-central-1.elb.amazonaws.com/device/v1/test' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic dGVzdFVzZXI6d2VsdA==' \
--data '{
    "type": "testing",
    "value": -510.190
}'
```

User is **testUser** and password is **welt**.

# Destroying AWS infrastructure
Stop all running tasks.

Delete images from AWS ECR and delete secrets from AWS Secret Manager
Run a script to destroy a new AWS environment (still in ```/aws-infrastructure/terraform``` directory):
```
./setup_new_region.sh backend-test eu-central-1 emea destroy -auto-approve
```

Terraform should automatically approve all changes and delete all existing resources one-by-one.
In case of errors, please correct them, delete from setup_new_region.sh lines that has already been executed and run 
the script again.

Check IAM, Cloudwatch Logs, S3 buckets if everything was deleted
