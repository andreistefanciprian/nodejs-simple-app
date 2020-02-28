# nodejs app with Dockerfile and Jenkinsfile



```buildoutcfg

# buid image
docker image build -t andreistefanciprian/nodejs-sample-app:v01 .

# push image to docker registry
docker image push andreistefanciprian/nodejs-sample-app:v01

# run nodejs app on 8080 locahost port
docker container run --publish 8080:8080 --detach --name nodejs-sample-app andreistefanciprian/nodejs-sample-app:v01


```
