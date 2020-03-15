# This is a script to quickly build this container fot test/debug purposes

# variables
CONTAINER_NAME=nodejs-app
TAG="v01.20"

# remove container if exists
if [ `docker ps --all --quiet --filter=name=$CONTAINER_NAME` ]; then docker container rm -f $CONTAINER_NAME && echo "Deleted container $CONTAINER_NAME"; else echo "Container $CONTAINER_NAME not present/running" ; fi

# build image
docker image build -t nodejs-app:${TAG} .

# run container
docker run -d -p 8080:8080 --name $CONTAINER_NAME nodejs-app:${TAG}

# list container
docker container ls