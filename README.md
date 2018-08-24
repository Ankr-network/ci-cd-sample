# ci-cd-sample-project

Sample project for CI/CD
---

## Setup a sample project and dockerize

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

4. Connect github with circleci.


