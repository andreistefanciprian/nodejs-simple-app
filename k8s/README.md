# PART 2 - Scale your application with Kubernetes

### Build application with Kubernetes and verify it's running (scenario 1)
```buildoutcfg
# build resources
kubectl apply -f k8s/step1-build-app/.

# check kubernetes built objects
kubectl get all -n default

# connect to container inside kubernetes pod and do some checks
kubectl exec -ti POD-NAME sh

# build kubernetes pod running curl and verify appplication is reacheable
kubectl run curl --image=radial/busyboxplus:curl -i --tty --restart Never
[ root@curl:/ ]$ nslookup nodejs-app
[ root@curl:/ ]$ curl nodejs-app:8080
[ root@curl:/ ]$ while true; do curl nodejs-app.default.svc.cluster.local:8080; sleep 2; done
[ root@curl:/ ]$ curl 10-244-1-201.default.Pod.cluster.local:8080

# check logs per deployment/pod/container
kubectl logs deployment/nodejs-app --timestamps
kubectl logs POD-NAME -c nodejs-app --timestamps

# describe kubernetes objects with kubectl describe commands
kubectl describe deployment nodejs-app
```

### Verify Kubernetes replaces failed containers/pods automatically (scenario 2)
```buildoutcfg
# build resources
kubectl apply -f k8s/step2-liveness-probe/.

## TEST 1: test pod gets rebuilt automatically in case application container is not responding 
# we'll simulate this by killing PID running inside app container
# get PID for application process running inside container
kubectl exec -ti POD-NAME ps aux

# kill application process running inside pod
kubectl exec -ti POD-NAME kill PID

# check kubernetes events
kubectl get events

# notice the pods is still there but the container RESTARTS counter has increased with 1
kubectl get pod POD-NAME

## TEST2: test pod gets rescheduled when k8s node stops working or pod is failing for some reason.
# manually delete pod
kubectl delete pod POD-NAME

# check k8s events. Notice new pod being created, replacing the delete pod
kubectl get events

# check pods
kubectl get pods
```

### Check k8s automatically scales your containers based on resource usage (scenario 3)
```buildoutcfg

# build resources
kubectl apply -f k8s/step3-autoscaler/.

# Test autoscaler
kubectl run curl2 --image=radial/busyboxplus:curl -i --tty --restart Never -- /bin/sh -c "while true; do curl nodejs-app.default.svc.cluster.local:8080; done"

# monitor autoscaler resource usage going up because of too many curl requests
# once CPU target is reached new replicas will be spawned
kubectl get hpa -w
```

### Canary deployments (scenario 4)
```buildoutcfg

# build resources
kubectl apply -f k8s/step4-canary-deployment/deployment-prod.yaml
kubectl apply -f k8s/step4-canary-deployment/service.yaml
# build canary deployment
kubectl apply -f k8s/step4-canary-deployment/deployment-canary.yaml

# curl application while doing the canary deployment
while true; do curl localhost:30001; sleep 0.5; done

# incrementally increase the number of replicas on the canary deployment
# while at the same time the number of replicas on the initial deployment is decreased
kubectl get deployments
kubectl scale --replicas 3 deployment nodejs-app-canary
kubectl scale --replicas 0 deployment nodejs-app-prod
# now all curl requests should return the Canary deployment page

```

### Other topics
* Services (ClusterIP, NodePort, LoadBalancer, ExternalName)
* Ingress (manage access to external services)
* Blue/Green deployments
* App lifecycle with kubectl rollouts
* Persistent Volumes
* Volumes (hostPath, emptyDir, ConfigMap, persistentVolumeClaim, Secrets)
* Security with Kubernetes (RBACs, NetworkPolicies, Secure images with SA and Kuberntes Secrets stored credentials )
* Statefull Sets
* Jobs/Cronjobs
* DaemonSets
* Node/Pod affinity and anti-affinity
* Taints and Tolerations
* Multi container Pods
* Package management with Helm
* Istio (service mesh)



### Cleanup
```buildoutcfg
# wipe out all user created resources
kubectl delete all --all --namespace default
```

### CLI commands to build resources instead of using YAML files
```buildoutcfg
# Create kubernetes deployment
kubectl run nodejs-app --image andreistefanciprian/nodejs-app:blue --port 8080 --requests=cpu=100m,memory=100Mi --limits=cpu=200m,memory=200Mi

# Create kubernetes service to expose the container application on localhost port in the range 30000-32767
kubectl expose deployment nodejs-app --port 8080 --type NodePort --name nodejs-app

# or port forward container traffic from port 8080 to localhost port 8080
kubectl port-forward nodejs-app-pod-name 8080:8080

# Create horizontal pod autoscaler for nodejs-app deployment
kubectl autoscale deployment nodejs-app --cpu-percent 30 --min 2 --max 5 --name nodejs-app

```