# Kubernetes w GCP

## Commands from lecture

* Fetch cluster credentials from GCP and prepare kubectl context configuration:
```
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
```

* Crete K8s resource based on YAML file
```
kubectl create -f example.yml
```

* Get information about K8s resources
```
kubectl get/describe/... pod/node/service/deployment/..
```

* Set port forwarding between local machine and cluster:
```
kubectl port-forward <POD_NAME/DEPLOYMENT_NAME/...> PORT:PORT
```

* Other useful commands:
```
kubectl exec <POD> [-c CONTAINER] [OTHER_OPTIONS] -- <COMMAND>
kubectl logs <POD> [CONTAINER]
```
