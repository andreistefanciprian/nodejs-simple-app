
### Create self signed certs following guide at: https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

Certs should be stored in certs dir

### Create kubernetes secrets for TLS certs from files

```
kubectl create secret generic certs --from-file=mydomain.com.key=certs/mydomain.com.key --from-file=mydomain.com.crt=certs/mydomain.com.crt
```

### Optional step - Create kubernetes ConfigMap for storing nginx conf

```
kubectl create configmap conf --from-file=default.conf
```

### Build resources

```
kubectl apply -f .
```

### Verify resources were created

```
curl -k https://localhost:30443/
kubectl get deployments, secrets, configmaps, services, pods, replicasets

```

### Clean up resources

```
kubectl delete secret nginx-ssl-certs
kubectl delete -f .
```