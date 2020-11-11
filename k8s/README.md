## PART 2 - Scale your application with Kubernetes

### Check k8s cluster

```
# check CP components on the Master Node
kubectl get pods --namespace kube-system
 
# check status of main CP components
kubectl get componentstatus
 
# check status of Kubernetes nodes
kubectl get nodes
 
# print information about the control plane and add-ons
kubectl cluster-info

# print information about the available Kubernetes APIs.
kubectl api-resources
kubectl api-versions
```

### Deploy your app in a Pod

```
# run application in a K8s pod
kubectl run nodejs-app --image nodejs-app:blue --restart Never --image-pull-policy=IfNotPresent --port 8080
 
# verify pod is running successfully
kubectl get pods
 
# get pod details
kubectl describe pod nodejs-app
 
# port forward application traffic to localhost port
kubectl port-forward nodejs-app 8088:8080 &
 
# verify application is reachable
curl -s localhost:8088
 
# check application container logs
kubectl logs nodejs-app
# get inside container and check file system
kubectl exec -ti nodejs-app ash
 
# kill kubectl port-forward process
for i in `ps | grep kubectl | awk '{print $1}'`; do kill $i; done
 
# delete k8s pod
kubectl delete pod nodejs-app
```

### Declare your Kubernetes objects with yaml

```
# generate yaml file from the same command we used to build the previous pod
kubectl run nodejs-app --image nodejs-app:blue --restart Never --port 8080 --image-pull-policy=IfNotPresent --dry-run -o yaml > pod.yaml
 
# create the pod from yaml files
kubectl create -f pod.yaml
 
# get details about Kubernets Pod in yaml format
kubectl get pod nodejs-app -o yaml --export
 
# get details about YAML fields
kubectl explain Pod.spec.containers.ports
kubectl explain Pod.spec.containers.imagePullPolicy
kubectl explain Pod.metadata.name

# delete pod
kubectl delete pod nodejs-app
```

### ReplicaSets

```
# create ReplicaSet k8s object
kubectl create -f k8s/1-deployment/replicaset.yaml
 
# verify resources were built
kubectl get replicaset
kubectl get pods
 
# let's delete one of the pods
kubectl delete pod POD_NAME
# observe how a new pod was created to meet the desired state defined in the yaml file (replicas: 5)
kubectl get pods --watch
 
# let's build another pod with the same label as the label selector in the ReplicaSet and observe what's going to happen
kubectl create -f k8s/1-deployment/stray-pod.yaml
```

### App updates with ReplicaSets?

```
# update the image used by ReplicaSet containers by opening the replica set YAML in the editor, then update the image value; use image green tag instead of blue
kubectl edit rs nodejs-app
 
# verify ReplicaSet image was updated
kubectl describe rs nodejs-app
 
# observe how the ReplicaSet is not automatically rebuilding pods with the new image-pull-policy
# this will happen only if we manually start deleting pods
kubectl get pods
 
# get the image used by pods
kubectl describe pods | grep Image:
kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
 
# delete one of the pods
kubectl delete pods POD_NAME
 
# observe how a new pod is created to meet desired state of 5 replicas, but this time using the new specified image
kubectl get pods --watch
kubectl get pods
kubectl describe pods | grep Image:

# delete ReplicaSet pods
kubectl delete rs nodejs-app
```

### Deployments

```
# check how deployment yaml file for our hello world app looks like
kubectl run nodejs-app --image nodejs-app:blue --port 8080 --replicas 5 --image-pull-policy=IfNotPresent --dry-run -o yaml

# create deployment
kubectl create -f k8s/1-deployment/deployment.yaml --record
 
# check created resources
kubectl get deployments
kubectl get replicasets
kubectl get pods
kubectl describe deployment nodejs-app

# get the name of first pod in deployment
POD=$(kubectl get pods -l run=nodejs-app -o jsonpath="{.items[0].metadata.name}")
 
# delete pod
kubectl delete pod $POD
```

### Deployment Rolling Updates

```
# update container image
kubectl set image deployment nodejs-app nodejs-app=nodejs-app:green --record
 
# verify deployment gets updated with new container image
kubectl get pods --watch
kubectl describe pods | grep Image:
kubectl get replicasets
 
# check deployment status
kubectl rollout status deployment nodejs-app
 
# check deployment history
kubectl rollout history deployment nodejs-app
 
# rollback deployment
kubectl rollout undo deployment nodejs-app
kubectl rollout history deployment nodejs-app
 
# rollback deployment to specific revision number
kubectl rollout undo deployment nodejs-app --to-revision 2

# get deployment settings in yaml format
kubectl get deployment nodejs-app -o yaml
```

### How to access the pods

```
# get ip address of pods
kubectl get pods -o wide

# launch curl pod and curl application pods
kubectl run curl --image=curl --image-pull-policy=IfNotPresent --restart Never -it --rm
root@curl:/# curl 10.1.0.184:8080
root@curl:/# curl 10.1.0.181:8080

# delete one of the pods
kubectl delete pod nodejs-app-7b9f4f9789-5nszz
 
# verify the new pod has a different IP Address
kubectl get pods -o wide

# create k8s service
kubectl expose deployment nodejs-app --port 8080 --target-port 8080 --type ClusterIP --name nodejs-app
 
# verify service was created
kubectl get service
kubectl get endpoints
 
# verify our pods are reacheable through this service
kubectl run curl --image=curl --image-pull-policy=IfNotPresent --restart Never -it --rm
root@curl:/# nslookup nodejs-app
Server:         10.96.0.10
Address:        10.96.0.10#53
 
Name:   nodejs-app.default.svc.cluster.local
Address: 10.107.20.165
root@curl:/# while true; do curl -s nodejs-app.default.svc.cluster.local:8080; sleep 0.5; done
root@curl:/# curl -s 10-1-0-184.default.Pod.cluster.local:8080
 
# cleanup resources
kubectl delete deployment nodejs-app
kubectl delete service nodejs-app
```

### Build ClusterIP Service

```
# create deployment
kubectl create -f k8s/2-services/deployment.yaml
 
# build ClusterIP load balancer -- accessible only from within cluster
kubectl create -f k8s/2-services/cluster-ip-service.yaml
  
# check service was built and points to your container
kubectl get services
kubectl get endpoints
  
# verify our application is reachable through this service
kubectl run curl --image=curl --image-pull-policy=IfNotPresent --restart Never -it --rm
root@curl:/# nslookup nodejs-app-cip
root@curl:/# while true; do curl -s nodejs-app-cip:8080; sleep 0.5; done
root@curl:/# while true; do curl -s nodejs-app-cip.default.svc.cluster.local:8080; sleep 0.5; done
root@curl:/# curl -s 10-1-0-184.default.Pod.cluster.local:8080
```

### Build NodePort Service

```
# build NodePort service
kubectl create -f k8s/2-services/node-port-service.yaml
  
# check service was built and points to your container
kubectl get services
kubectl get endpoints
  
# verify our application is reachable through this service
while true; do curl -s localhost:30080; sleep 0.5; done
```

### Build LoadBalancer Service

```
# build LoadBalancer service
kubectl create -f k8s/2-services/load-balancer.yaml
  
# check service was built and points to your container
kubectl get services
kubectl get endpoints
  
# We won't get a public IP Address when building this type of service on Docker Desktop
# If we had built this service in the cloud, we would have got a public IP Address.
# Instead, Docker Desktop allocates localhost and container port number as Public IP
while true; do curl -s localhost:8080; done
```

### How does services know how to track pods?

```
# check service and pod labels
kubectl get pods --show-labels
kubectl describe service nodejs-app-cip
 
# get the name of the first pod in deployment nodejs-app
POD=$(kubectl get pods -l app=nodejs-app -o jsonpath="{.items[0].metadata.name}")
 
# remove label for this pod
kubectl label pod $POD app-
 
# verify services aren't tracking this pod anymore
kubectl get endpoints
 
# verify pod is excluded when curl-ing app
while true; do curl -s localhost:8080; done
 
# Notice, that the pod that had label app removed, is not managed by ReplicaSet or Deployment anymore!
kubectl get pods --show-labels -o wide
 
# this can be verified by removing pod. A new pod shouldn't be recreated
kubectl delete pod $POD
```

### Scale your app

```
# build resources
kubectl create -f k8s/3-scale-app/resources.yaml
 
# check resources were built
kubectl get deployments,replicasets,services,endpoints
 
# scale deployment while curl-ing app
while true; do curl -s localhost:30000; done                                                                                                                             
kubectl scale deployment nodejs-app --replicas 3
  
# check deployment was scaled successfully
kubectl get deployments,replicasets,services,endpoints
 
# destroy resources
kubectl delete -f k8s/3-scale-app/resources.yaml
```

### Kubernetes probes - livenessProbe

```
## Test container inside pod gets restarted automatically in case probe fails
# build resources
kubectl create -f k8s/4-probes/liveness_probe.yaml
 
# get pod name
POD=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
 
# remove index.html page
kubectl exec -ti $POD bash                                                                                                             
root:/# rm /var/www/index.html               
 
# notice container inside pod has been restarted (RESTARTS counter has increased with 1)
kubectl get pods -w
kubectl describe pod $POD
 
# clean up scenario
kubectl delete -f k8s/4-probes/liveness_probe.yaml
```

### Kubernetes probes - readinessProbe

```
## Test pod doesn't server traffic until becomes Ready (passes readinessProbe)
# build resources
kubectl create -f k8s/4-probes/readiness_probe.yaml              
 
# while resources get created watch over service endpoint list
# notice pod's IP Address get published as service endpoint only after readinessProbe passes
kubectl get endpoints --watch
 
# clean up scenario
kubectl delete -f k8s/4-probes/readiness_probe.yaml
```

### Kubernetes probes - startupProbe
```
# build resources
kubectl create -f k8s/4-probes/startup_probe.yaml             
 
# notice that although it takes time for the container to start, the other probes do not perform checks, hence container is not restarted prematurely
kubectl get endpoints --watch
kubectl get pods --watch
 
# clean up scenario
kubectl delete -f k8s/4-probes/startup_probe.yaml
```

### Autoscale your app

```
# build resources
kubectl create -f k8s/5-autoscaler/resources.yaml
 
# Test autoscaler
kubectl run curl --image=curl:latest --image-pull-policy=IfNotPresent --restart Never -it --rm
root@curl:/# while true; do curl nodejs-app.default.svc.cluster.local:8080; done
 
# monitor autoscaler resource usage going up because of too many curl requests
# once CPU target is reached new replicas will be spawned
kubectl get hpa -w
 
# clean up scenario
kubectl delete -f k8s/5-autoscaler/resources.yaml
```

### Update your app with Canary deployments

```
# build production deployment
kubectl apply -f k8s/6-canary-deployment/deployment-prod.yaml
kubectl apply -f k8s/6-canary-deployment/service.yaml
 
# build canary deployment
kubectl apply -f k8s/6-canary-deployment/deployment-canary.yaml
 
# curl application while doing the canary deployment
while true; do curl -s localhost:30000; sleep 0.5; done
 
# incrementally increase the number of replicas on the canary deployment
# while at the same time the number of replicas on the initial deployment is decreased
kubectl get deployments
kubectl scale --replicas 3 deployment nodejs-app-canary
kubectl scale --replicas 0 deployment nodejs-app-prod
 
# now all curl requests should return the Canary deployment page
 
# clean up
kubectl delete all --all -n default
```

### Kubernetes volumes

```
# Verify data gets persisted across container restarts

# build resources
kubectl create -f k8s/11-volumes/emptydir_volume.yaml

# create file inside Kubernetes volume
kubectl exec -ti POD_NAME -- bash -c "touch /app/data/file.txt; ls -l /app/data/"

# trigger container restart by causing livenessProbe to fail 
kubectl exec -ti POD_NAME -- bash -c "rm /var/www/index.html“

# check container got restarted
kubectl get pods --watch

# after container gest restarted check file was persisted
kubectl exec -ti POD_NAME -- bash -c "ls -l /app/data/"

# destroy resources
kubectl delete -f k8s/11-volumes/emptydir_volume.yaml

```

### ConfigMaps and Secrets

```
# create kubernetes secret to store SSL certs
kubectl create secret generic certs \
--from-file=mydomain.com.key=k8s/7-decouple-secrets-and-configs/certs/mydomain.com.key \
--from-file=mydomain.com.crt=k8s/7-decouple-secrets-and-configs/certs/mydomain.com.crt
 
# build resources
kubectl create -f k8s/7-decouple-secrets-and-configs/
 
# verify resources were created
while true; do curl -sk https://localhost:30443/; sleep 0.5; done
kubectl get deployments, secrets, configmaps, services, pods, replicasets
 
# clean up scenario
kubectl delete all --all -n default
```

### Define a command and arguments for your k8s container

```
#  build resources
kubectl apply -f k8s/8-command-and-arguments/
 
# verify resources were built
kubectl get all
 
# get pods logs
kubectl logs deployment/nodejs-app
 
# verify app is not reachable on nodejs port
for i in {1..10}; do echo "Test $i:"; curl -s localhost:30000/; done
 
# remove resources
kubectl delete -f k8s/8-command-and-arguments/
```

### Pass environment variables to your k8s container

```
#  create k8s deployment with env vars
kubectl create -f k8s/9-env-variables/
 
# verify resources were built
kubectl get all
 
# get env vars from pods logs
kubectl logs deployment/nodejs-app
 
# verify app is not reachable on nodejs port
for i in {1..10}; do echo "Test $i:"; curl -s localhost:30001/; done
 
# remove resources
kubectl delete -f k8s/9-env-variables/
```

### Pass environment variables from a file via envFrom field

```
# store env vars in configmap and secrets
kubectl create configmap db-properties --from-env-file=k8s/10-env-vars-from-file/config-vars.txt
kubectl create secret generic db-secrets --from-env-file=k8s/10-env-vars-from-file/secret-vars.txt
 
# build resources
kubectl apply -f k8s/10-env-vars-from-file/
 
# describe secrets and configmap
kubectl describe secrets db-secrets
kubectl describe configmap db-properties
 
# get the name of first pod in deployment
POD=$(kubectl get pods -l app=nodejs-app -o jsonpath="{.items[0].metadata.name}")
 
# get the value of env vars defined through secrets and configmap env files
kubectl exec -ti $POD -- printenv DB_USER DB_PASSWORD DB_HOST DB_HOSTNAME
 
# remove resources
kubectl delete -f k8s/10-env-vars-from-file/
kubectl delete configmap db-properties
kubectl delete secrets db-secrets
```

### Persist data beyond the life of your containers/pods

```
# build resources
kubectl apply -f k8s/12-persistent-volume/
 
# display built resources
kubectl get pv,pvc,pods
 
# create file on pv path
kubectl exec -ti my-pod ash
/ # echo "This is going to be persisted after all resources are deleted" > /mnt/storage/hello.txt
 
# remove resources
kubectl delete -f k8s/12-persistent-volume/
 
# rebuild resources and check data is persisted
kubectl apply -f k8s/12-persistent-volume/
kubectl exec -ti my-pod ash
/ # cat /mnt/storage/hello.txt
```

### Cleanup

```
# wipe out all user created resources
kubectl delete all --all --namespace default
```

### CLI commands to build resources instead of using YAML files

```
# Create kubernetes deployment
kubectl run nodejs-app --image andreistefanciprian/nodejs-app:blue --port 8080 --requests=cpu=100m,memory=100Mi --limits=cpu=200m,memory=200Mi

# Create kubernetes service to expose the container application on localhost port in the range 30000-32767
kubectl expose deployment nodejs-app --port 8080 --type NodePort --name nodejs-app

# or port forward container traffic from port 8080 to localhost port 8080
kubectl port-forward nodejs-app-pod-name 8080:8080

# Create horizontal pod autoscaler for nodejs-app deployment
kubectl autoscale deployment nodejs-app --cpu-percent 30 --min 2 --max 5 --name nodejs-app
```