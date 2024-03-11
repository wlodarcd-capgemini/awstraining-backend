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
