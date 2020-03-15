
# PART 1 - Build and Run application with Docker image and container

### Build application image 
```buildoutcfg

# buid image described in Dockerfile
$ docker image build -t nodejs-app:v01.11 .

# verify image is available locally
$ docker image ls
```

### Run and check your application container
```buildoutcfg
# run nodejs app on 8080 locahost port from local image
$ docker container run --publish 8080:8080 --detach --name nodejs-app nodejs-app:v01.11

# get a prompt inside the container and verify application file system
$ docker exec -ti nodejs-app sh
$ pwd
/usr/src/app
$ ls
app.js
$ whoami
nodejsapp
$ id
uid=999(nodejsapp) gid=999(nodejsapp) groups=999(nodejsapp),27(sudo)
$ echo $APP_VER
v01.11
$ node -v
v7.10.1
$ exit

# get PID of running processes inside container
$ docker container top nodejs-app

# check these process are running on localhost
$ ps u PIC

# monitor resource usage
$ docker container stats --no-stream

# check application is running on port 80080
$ sudo netstat -tapnl | grep 8080

# access application
$ curl localhost:8080

# check application logs on container
$ docker container logs nodejs
```

### Share Docker image

```buildoutcfg
# tag image for DockerHub registry
$ docker image tag nodejs-app:v01.11 andreistefanciprian/nodejs-app:v01.11

# push image to DockerHub registry
$ docker image push andreistefanciprian/nodejs-sample-app:v01 andreistefanciprian/nodejs-app:v01.11

# delete container and container image
$ docker container rm -f nodejs-app
$ docker image rm nodejs-app:v01.11 andreistefanciprian/nodejs-app:v01.11

# run nodejs app on 8080 locahost port from DockerHub image
$ docker container run --publish 8080:8080 --detach --name nodejs-app andreistefanciprian/nodejs-app:v01.11

# you can repeat test checks in previous section to verify your container runs as expected
```

# PART 2 - Scale your application with Kubernetes

### Build application
```buildoutcfg
# Create kubernetes deployment
$ kubectl run nodejs-app --image andreistefanciprian/nodejs-app:v01.11 --port 8080 --requests=cpu=100m,memory=100Mi --limits=cpu=200m,memory=200Mi

# Create kubernetes service to expose the container application on localhost port in the range 30000-32767
$ kubectl expose deployment nodejs-app --port 8080 --type NodePort --name nodejs-app

# or port forward container traffic from port 8080 to localhost port 8080
$ kubectl port-forward nodejs-app-pod-name 8080:8080
```

### Verify application is running
```buildoutcfg
# check kubernetes built objects
$ kubectl get all -n default
NAME                              READY   STATUS    RESTARTS   AGE
pod/nodejs-app-58b6f4769c-jkz8w   1/1     Running   4          101m
pod/nodejs-app-58b6f4769c-v9xhc   1/1     Running   1          115m

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP          5h24m
service/nodejs-app   NodePort    10.98.234.66   <none>        8080:30001/TCP   115m

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nodejs-app   2/2     2            2           115m

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/nodejs-app-58b6f4769c   2         2         2       115m

# build kubernetes pod running curl and verify appplication is reacheable
$ kubectl run curl --image=radial/busyboxplus:curl -i --tty --restart Never
[ root@curl:/ ]$ curl nodejs-app:8080
You've hit v1 running on: nodejs-app-58b6f4769c-v9xhc
[ root@curl:/ ]$ while true; do curl nodejs-app.default.svc.cluster.local:8080; sleep 2; done
You've hit v1 running on: nodejs-app-58b6f4769c-jkz8w
You've hit v1 running on: nodejs-app-58b6f4769c-v9xhc
You've hit v1 running on: nodejs-app-58b6f4769c-jkz8w
^C
[ root@curl:/ ]$ curl 10-244-1-201.default.Pod.cluster.local:8080
You've hit v1 running on: nodejs-app-58b6f4769c-jkz8w
[ root@curl:/ ]$ nslookup nodejs-app
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nodejs-app
Address 1: 10.98.234.66 nodejs-app.default.svc.cluster.local
[ root@curl:/ ]$ exit

# check logs per deployment/pod/container
$ kubectl logs deployment/nodejs-app --timestamps
$ kubectl logs nodejs-app-58b6f4769c-v9xhc -c nodejs-app --timestamps

# describe kubernetes objects with kubectl describe commands
$ kubectl describe deployment nodejs-app
```

### Verify Kubernetes replaces failed containers/pods automatically
```buildoutcfg
## TEST 1: test pod gets rebuilt automatically in case application container is not responding 
# we'll simulate this by killing PID running inside app container
# get PID for application process running inside container
$ kubectl exec -ti nodejs-app-58b6f4769c-jkz8w ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4336   684 ?        Ss   20:28   0:00 /bin/sh -c node app.js
root         6  0.0  0.7 881868 29384 ?        Sl   20:28   0:01 node app.js
root        22  0.0  0.0  17500  2052 pts/0    Rs+  22:01   0:00 ps aux

# kill application process running inside pod
$ kubectl exec -ti nodejs-app-58b6f4769c-jkz8w kill 6

# check kubernetes events
$ kubectl get events
LAST SEEN   TYPE     REASON              OBJECT                            MESSAGE
41s         Normal   Pulling             pod/nodejs-app-58b6f4769c-jkz8w   Pulling image "andreistefanciprian/nodejs-app:v01.11"
40s         Normal   Pulled              pod/nodejs-app-58b6f4769c-jkz8w   Successfully pulled image "andreistefanciprian/nodejs-app:v01.11"
40s         Normal   Created             pod/nodejs-app-58b6f4769c-jkz8w   Created container nodejs-app
39s         Normal   Started             pod/nodejs-app-58b6f4769c-jkz8w   Started container nodejs-app

# notice the pods is still there but the container RESTARTS counter has increased with 1
$ kubectl get pod nodejs-app-58b6f4769c-jkz8w
NAME                          READY   STATUS    RESTARTS   AGE
nodejs-app-58b6f4769c-jkz8w   1/1     Running   5          116m

## TEST2: test pod gets rescheduled when k8s node stops working or pod is failing for some reason.
# manually delete pod
$ kubectl delete pod nodejs-app-58b6f4769c-jkz8w
pod "nodejs-app-58b6f4769c-jkz8w" deleted

# check k8s events
$ kubectl get events
0s          Normal   Killing             pod/nodejs-app-58b6f4769c-jkz8w   Stopping container nodejs-app
0s          Normal   SuccessfulCreate    replicaset/nodejs-app-58b6f4769c   Created pod: nodejs-app-58b6f4769c-h86n9
0s          Normal   Scheduled           pod/nodejs-app-58b6f4769c-h86n9    Successfully assigned default/nodejs-app-58b6f4769c-h86n9 to automationdevops19gmailcom143c.mylabserver.com
0s          Normal   Pulling             pod/nodejs-app-58b6f4769c-h86n9    Pulling image "andreistefanciprian/nodejs-app:v01.11"
1s          Normal   Pulled              pod/nodejs-app-58b6f4769c-h86n9    Successfully pulled image "andreistefanciprian/nodejs-app:v01.11"
0s          Normal   Created             pod/nodejs-app-58b6f4769c-h86n9    Created container nodejs-app
0s          Normal   Started             pod/nodejs-app-58b6f4769c-h86n9    Started container nodejs-app

# check pods
$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
nodejs-app-58b6f4769c-h86n9   1/1     Running   0          44s
nodejs-app-58b6f4769c-v9xhc   1/1     Running   1          137m
```

### Check k8s automatically scales your containers based on resource usage
```buildoutcfg

# Create horizontal pod autoscaler for nodejs-app deployment
$ kubectl autoscale deployment nodejs-app --cpu-percent 30 --min 2 --max 5 --name nodejs-app

# Test autoscaler
$ kubectl run curl2 --image=radial/busyboxplus:curl -i --tty --restart Never -- /bin/sh -c "while true; do curl nodejs-app.default.svc.cluster.local:8080; done"
You've hit v1 running on: nodejs-app-58b6f4769c-h86n9
You've hit v1 running on: nodejs-app-58b6f4769c-v9xhc
....

$ kubectl get hpa -w
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
nodejs-app   Deployment/nodejs-app   1%/30%    2         5         2          142m
nodejs-app   Deployment/nodejs-app   21%/30%   2         5         2          145m
nodejs-app   Deployment/nodejs-app   37%/30%   2         5         2          146m
nodejs-app   Deployment/nodejs-app   37%/30%   2         5         3          146m
nodejs-app   Deployment/nodejs-app   33%/30%   2         5         4          147m
```


### Cleanup
```buildoutcfg
# wipe out all user created resource 
$ kubectl delete all --all --namespace default
```
