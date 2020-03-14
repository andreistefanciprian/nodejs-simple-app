# nodejs app with Dockerfile and Jenkinsfile



```buildoutcfg

# buid image
docker image build -t andreistefanciprian/nodejs-sample-app:v01 .

# push image to docker registry
docker image push andreistefanciprian/nodejs-sample-app:v01

# run nodejs app on 8080 locahost port
docker container run --publish 8080:8080 --detach --name nodejs-sample-app andreistefanciprian/nodejs-sample-app:v01


# Create kubernetes deployment
kubectl run nodejs-app --image andreistefanciprian/nodejs-app:v01.11 --port 8080 --requests=cpu=100m,memory=100Mi --limits=cpu=200m,memory=200Mi

# Create kubernetes service to expose the container application to localhost
kubectl expose deployment nodejs-app --port 8080 --type NodePort --name nodejs-app

# or port forward container traffic from port 8080 to localhost port 80
kubectl port-forward nodejs-app-pod-name 80:8080

# Create horizontal pod autoscaler for nodejs-app deployment
kubectl autoscale deployment nodejs-app --cpu-percent 30 --min 2 --max 5 --name nodejs-app

# Test pod gets rebuilt automatically in case application is not responding (test 1 - delete pod; test 2 - kill app PID inside container)
kubectl delete pod nodejs-app-pod-name
kubectl exec -ti nodejs-app-pod-name ps aux
kubectl exec -ti nodejs-app-pod-name kill PID

# Test autoscaler
kubectl run curl --image curlimages/curl --restart Never --command -- sleep 3600
kubectl exec -ti curl -- /bin/sh -c "while true; do curl nodejs-app.default.svc.cluster.local:8080; done"

# Monitoring commands
kubectl get pods
kubectl get events
kubectl get hpa






```
