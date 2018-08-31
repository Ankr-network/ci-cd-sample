# ci-cd-sample-project

## Setup a sample web application using docker

1. Create a github repo and clone to local.

2. Create a simple nodejs "hello world" app, install npm and initialize project:
```
npm init
npm install express --save
```
then create 'index.js' to serve the http request as in the repo

3. Dockerize the nodejs app, create 'Dockerfile' to define the image as in the repo. To test the Dockerfile, install docker and docker-machine, then build the image, and run locally on docker- to test:
```
eval $(docker-machine env default)
docker build -t hello-world .
docker run -d -p 8080:8080 hello-world
```
then you should be able to use 'curl 192.168.99.100:8080' to get the "hello world"

4. Connect github with circleci, signup on circlici with github account and authorize circleci to follow on the project repos in the github. Note that to allow circle to follow, the github user should have the admin access to the specific project repo.

5. Setup AWS below circleci web interface: target-project -> settings -> Environment Variables
```
* AWS_ACCOUNT_ID
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
```

6. Login AWS with the account above and select Services -> Elastic Container Service -> Amazon ECR Repositories and create ecr repository, e.g. "ankr_ecr"

7. If not done yet, create an ec2 instance and install docker-machine as a deployment agent, e.g. 13.57.212.223, install awscli and configure the aws credentials. one way to configure credentials is to use the standard credential file for Amazon AWS ~/.aws/credentials file , which might look like:
```
[default]
aws_access_key_id = MY-ACCESS-KEY
aws_secret_access_key = MY-SECRET-KEY
```
or use environment variables, or specify it in the deploy commands. 

setup an aws ec2 docker machine host and enable it to login to ecr
```
docker-machine create --driver amazonec2 --amazonec2-open-port 8080 --amazonec2-region us-west-1 --amazonec2-instance-type t2.micro aws-ec2-host
docker-machine ssh aws-ec2-host sudo usermod -a -G docker $USER
docker-machine ssh aws-ec2-host eval $(aws ecr get-login --no-include-email --region us-west-1)
```

then create the 'deploy.sh' script for circle ci to call the agent to deploy new docker container, pull the images from ecr and run.
```
eval $(docker-machine env aws-ec2-host)
eval $(aws ecr get-login --no-include-email --region us-west-1)
docker pull 815280425737.dkr.ecr.us-west-1.amazonaws.com/ankr_ecr:hello_world

if [ "$(docker ps -aq -f name=hello_world_container)" ]; then
    docker stop hello_world_container
    docker rm hello_world_container
fi

docker run -d --name=hello_world_container -p 8080:8080 815280425737.dkr.ecr.us-west-1.amazonaws.com/ankr_ecr:hello_world
```

8. Create a folder named .circleci and add a file config.yml, populate the config.yml with the contents as in the repo, confirm and correct the ecr repo and deployment agent machine address, as in the following example:
```
version: 2
jobs:
  build:
    docker:
      - image: circleci/python:2.7-jessie-node-browsers
    working_directory: ~/app
    steps:
      - add_ssh_keys:
          fingerprints:
            - "b8:c9:bd:e1:1c:ba:6f:56:6a:ee:21:4d:a7:eb:c9:86"
      - checkout
      - setup_remote_docker
      - run:
          name: Install AWSCLI
          command: |
            curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
            unzip awscli-bundle.zip
            sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
      - run:
          name: "Log in to AWS ECR"
          command: eval $(aws ecr get-login --no-include-email --region us-west-1)
      - run:
          name: "Build & Push Docker Image"
          command: |
            docker build -t hello_world .
            docker tag hello_world:latest 815280425737.dkr.ecr.us-west-1.amazonaws.com/ankr_ecr:hello_world
            docker push 815280425737.dkr.ecr.us-west-1.amazonaws.com/ankr_ecr:hello_world
      - run:
          name: "Pull Image on Docker Deployment Machine and Run on a new EC2 instance"
          command: |
            ssh -o StrictHostKeyChecking=no ubuntu@54.153.10.121 "./deploy.sh"
```

9. Push this change up to GitHub, and will auto start building, and will launch your project on CircleCI eventually deploy on docker machine.


