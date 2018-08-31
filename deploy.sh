#docker-machine create --driver amazonec2 --amazonec2-open-port 8080 --amazonec2-region us-west-1 --amazonec2-instance-type t2.micro aws-ec2-host9
eval $(docker-machine env aws-ec2-host)
eval $(aws ecr get-login --no-include-email --region us-west-1)
docker pull 815280425737.dkr.ecr.us-west-1.amazonaws.com/ankr_ecr:hello_world

if [ "$(docker ps -aq -f name=hello_world_container)" ]; then
    docker stop hello_world_container
    docker rm hello_world_container
fi

docker run -d --name=hello_world_container -p 8080:8080 815280425737.dkr.ecr.us-west-1.amazonaws.com/ankr_ecr:hello_world
