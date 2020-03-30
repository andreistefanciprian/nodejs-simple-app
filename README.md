
# PART 1 - Build and Run application with Docker image and container

### Build application image 
```buildoutcfg
# build image described in Dockerfile
docker image build --build-arg API_VER=v2 -t nodejs-app:blue .

# verify image is available locally
docker image ls

# observe all docker layers that make up the image
docker image history nodejs-app:blue

```

### Run and check your application container
```buildoutcfg
# run nodejs app on 8080 locahost port from local image
docker container run --publish 8080:8080 --detach --name nodejs-app nodejs-app:blue

# get a prompt inside the container and do some checks
docker exec -ti nodejs-app sh

# get PID of running processes inside container
docker container top nodejs-app

# check these processes are running on localhost
ps u PID

# monitor resource usage
docker container stats --no-stream

# check application is running on port 80080
sudo netstat -tapnl | grep 8080

# access application
curl localhost:8080

# check application logs on container
docker container logs nodejs
```

### Share Docker image
```buildoutcfg
# tag image for DockerHub registry
docker image tag nodejs-app:blue andreistefanciprian/nodejs-app:blue

# push image to DockerHub registry
docker image push andreistefanciprian/nodejs-sample-app:v01 andreistefanciprian/nodejs-app:blue

# delete container and container image
docker container rm -f nodejs-app
docker image rm nodejs-app:blue andreistefanciprian/nodejs-app:blue

# run nodejs app on 8080 locahost port from DockerHub image
docker container run --publish 8080:8080 --detach --name nodejs-app andreistefanciprian/nodejs-app:blue

# you can repeat test checks in previous section to verify your container runs as expected
```

### Docker Compose

TBD

### Run Tests

TBD



