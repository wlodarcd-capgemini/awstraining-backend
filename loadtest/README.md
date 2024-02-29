## Backend load tests

# Structure

    .
    ├── ...
    ├── src          
    │   ├──test      
    │       ├──resources    # Resources used to configure gatling load tests
    │       │    ├──scripts # script perform the test
    │       └── scala      # Contains encrypted ansible vaults and path variables
    ├── Dockerfile          # docker file to create docker image
    └──  pom.xml             # maven configuration with gatling plugin
    
   
# Start load tests locally

**Prerequisites**

1. Configure load test in `buildprofiles/NONE-CI-config.properties`
    
**Start load test**

1. Go to `loadtest` directory
2. Run: `mvn test -P NONE-CI`  
    
# Start load tests on aws

**Prerequisites**

1. Check if the load test infrastructure is created - if not, run terraform scripts
    
**Build and push image to ECR**

    
**Start load test**

1. Force new service deployment in backend-loadtest cluster

 
   