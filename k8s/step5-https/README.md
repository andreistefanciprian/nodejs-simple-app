
Create self signed certs following guide at: https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

```
# Create Root Key
openssl genrsa -out rootCA.key 4096

# Create and self sign the Root Certificate
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt

# Create the certificate key
openssl genrsa -out mydomain.com.key 2048

# Create csr
openssl req -new -sha256 -key mydomain.com.key -subj "/C=UK/ST=HS/O=MyOrg, Inc./CN=mydomain.com" -out mydomain.com.csr

# Verify the csr's content
openssl req -in mydomain.com.csr -noout -text

# Generate the certificate using the mydomain csr and key along with the CA Root key
openssl x509 -req -in mydomain.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out mydomain.com.crt -days 500 -sha256

# Verify the certificate's content
openssl x509 -in mydomain.com.crt -text -noout
```

## Create kubernetes secrets for TLS certs from files

```
kubectl delete secret nginx-ssl-certs
kubectl create secret generic certs --from-file=mydomain.com.key=certs/mydomain.com.key --from-file=mydomain.com.crt=certs/mydomain.com.crt
```

## Create kubernetes ConfigMap for storing nginx conf

```
kubectl create configmap conf --from-file=default.conf
```

## Build resources

```
kubectl apply -f .
```