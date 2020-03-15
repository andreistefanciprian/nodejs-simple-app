# This is a script to quickly build and push this container for test/debug purposes

# variables
CONTAINER_NAME=nodejs-app
TAG="v01.11"
REPO_CONTAINER_NAME_TAG="andreistefanciprian/${CONTAINER_NAME}:${TAG}"

echo -e "\nRemove container if exists..."
container_id=$(docker ps -aqf "name=^${CONTAINER_NAME}$")
[ -z $container_id ] || docker container rm -f $container_id

# build image
echo -e "\nBuild image..."
docker image build -t $CONTAINER_NAME:$TAG .

# run container
echo -e "\nRun container..."
docker run -d -p 8080:8080 --name $CONTAINER_NAME $CONTAINER_NAME:$TAG

# list containers
echo -e "\nList containers..."
docker container ls

# specify push as positional param if you want to push this image to dockerhub
[ "$1" == "push" ] && ( docker image tag $CONTAINER_NAME:$TAG $REPO_CONTAINER_NAME_TAG && docker image push $REPO_CONTAINER_NAME_TAG)