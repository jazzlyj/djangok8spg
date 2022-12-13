# Django

## Create project
```
django-admin startproject djangok8spgpg

cd djangok8spg
```


## Change database connection settings before building the docker image
* edit settings.py:
  * add "import os" at the top file with the other imports
  * replace the "DATABASES" config block with this block

```
DATABASES = {
   'default': {
      'ENGINE': 'django.db.backends.postgresql',
      'NAME': os.getenv('DATABASE_NAME'),
      'USER': os.getenv('DATABASE_USER'),
      'PASSWORD': os.getenv('DATABASE_PASSWORD'),
      'HOST': os.getenv('DATABASE_HOST'),
      'PORT': '5432',
   }
}
```


## Create dockerfile
* create dockerfile with this content
```
```

* exposes that port 8000 will be used to accept incoming container connections, and runs gunicorn with 3 workers and listening on port 8000.

## Build image:
```
docker build -t djangok8spg .
```

```
docker images
```



# Deploying Postgres via ConfigMap with a PersistentVolume

Stateful set deploy
To ensure data persistence, use a persistent volume (PV) and persistent volume claims (PVC).

## Apply ConfigMap

- Create a ConfigMap

```bash
cat <<EOF > postgres-config.yaml


EOF

```

- Apply config map

```bash
kubectl apply -f postgres-config.yaml
```

## Create and Apply Persistent Storage Volume and Persistent Volume Claim

### Persistent volume (PV)

A durable volume that will remain even if the pod is deleted and stores data.

### persistent volume claim (PVC)

How users request and consume PV resources with parameters such as size of your storage disk, access modes, and storage class.

- Create manifest

```bash
cat <<EOF > postgres-pvc-pv-pg.yaml

kind: PersistentVolume
apiVersion: v1
metadata:
  name: postgres-pv-volume  # Sets PV's name
  labels:
    type: local  # Sets PV's type to local
    app: django-pg-pvc
spec:
  storageClassName: manual
  capacity:
    storage: 5Gi # Sets PV Volume
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/data"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: postgres-pv-claim  # Sets name of PVC
  labels:
    app: django-pg-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany  # Sets read and write access
  resources:
    requests:
      storage: 5Gi  # Sets volume size
EOF
```

- Apply manifest

```bash
kubectl apply -f postgres-pvc-pv-pg.yaml
```

## Postgress deployment

- Create manifest

```bash
cat <<EOF > postgres-pvc-pg-deployment.yaml


EOF
```

- Apply manifest

```bash
kubectl apply -f postgres-pvc-pg-deployment.yaml
```

## Postgress Service

- Create manifest

```bash
cat <<EOF > postgres-pvc-pg-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: db
  labels:
    name: postgres-service
    app: django-pg-pvc
spec:
  type: NodePort  
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    name: postgres-pod
    app: django-pg-pvc

EOF
```

- Apply manifest

```bash
kubectl apply -f postgres-pvc-pg-service.yaml
```

## Creating the Database Schema

```
python3 manage.py createsuperuser
```
 after creating the superuser, hit CTRL+D to quit the container and kill it.



# Minikube
K8s cluster on a single host

## Install and deploy
https://minikube.sigs.k8s.io/docs/start/

### Install
```powershell
choco install minikube
```

### Start
```powershell
minikube start
```

## Deploy Docker Registry

### Enable Add On
```powershell
minikube addons enable registry
```
https://minikube.sigs.k8s.io/docs/drivers/docker

* confirm
```powershell
kubectl get service --namespace kube-system
```

###
```powershell
kubectl port-forward --namespace kube-system service/registry 5000:80
```

### Run docker registry
```powershell
docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:host.docker.internal:5000"
```

## Docker Tag
```bash
docker tag host.domain.com localhost:5000/ host.domain.com
docker tag djangok8spg localhost:5000/djangok8spg
```

## Docker Push Image to Registry
```bash
docker push localhost:5000/host.domain.com
docker push localhost:5000/djangok8spg
```

### Test to see if registry is running
```bash
curl --location http://localhost:5000/v2
curl http://localhost:5000/v2/_catalog
```

* After the image is pushed, refer to it by localhost:5000/{name} in kubectl specs
With image available to Kubernetes on local Docker registry

# Deploy Django
```



```

* Deploy
```
kubectl apply -f django-pvc-pg-deployment.yaml
```

* Verify
```
kubectl get deploy django-pg-pvc

# NAME         READY   UP-TO-DATE   AVAILABLE   AGE
# django-app   3/3     3            3           12s
```

* use the selector: app and the get the pods associated with that value
```bash
kubectl get pods -l app=django-pg-pvc
```


### K8s Services
* Deploy the service "django-pvc-pg-service.yaml"
```bash
kubectl apply -f django-pvc-pg-service.yaml
```

* use the selector: "app" and the get all things associated with that value
```bash
kubectl get all -l app=django-pg-pvc
```

* setup port forwarding 
```bash
kubectl port-forward service/django-service 8000:8000
```




### K8s Ingress
A reverse proxy that enables external access into other Kubernetes resources.

* Install ingress controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/do/deploy.yaml
```

* Confirm the pods have started:
```
kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --watch
```

* Confirm that the Load Balancer was successfully created
```
kubectl get svc --namespace=ingress-nginx
```

* Unless deploying to DNS use /etc/hosts
```bash
vim /etc/hosts
# add an entry for our domain name
127.0.0.1 localhost

```

* Deploy ingress
```bash
kubectl apply -f ingress.yaml
```

https://github.com/kubernetes/ingress-nginx









# Once built - Run these on subsequent starts

```
# port forwarding for docker registry to work 
kubectl port-forward --namespace kube-system service/registry 5000:80
# port forwarding for django deployment/service/ http://localhost:8000/ to work 
kubectl port-forward service/django-service 8000:8000
# to start the minikube dashboard in browser
minikube dashboard
```

command history
```
kubectl get service --namespace kube-system
curl http://localhost:5000/v2/_catalog
kubectl get deploy django-app
kubectl get pods -l app=django
kubectl get all -l app=django

```

















## K8s clean up
```bash
kubectl delete all --all
```

# Helm
Package manager for K8s. Packages all manifests "the app" needs into a single item called a chart

## Consists of 3 key parts: 
a) Metadata 

b) Values 

c) Templates

### Metadata
Chart.yaml

* Validate the chart is good
```bash
helm show all ./chart
```

### Values

### Templates

### Install Helm
```powershell
choco install kubernetes-helm
```

## Helm Upgrade
Instead of using install and uninstall use upgrade.

It versions all of your installs on top of each other. 
It knows when stuff has changed, to install the changes. If you've modified things, to modify in place

```bash
helm upgrade --atomic --install $HELM_CHART_NAME $CHART_LOCATION

#Eg
helm upgrade --atomic --install host-website ./chart
```
--atomic
* Deploy all resources as a single unit and if it doesnt work it rolls it back.



# Delete 
```bash

kubectl delete -n default configmap postgres-config
kubectl delete -n default deployment postgres-deploy
kubectl delete -n default service db
```