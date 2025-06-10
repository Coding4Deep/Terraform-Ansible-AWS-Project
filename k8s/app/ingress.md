
## Install nginx-ingress controller :
To get started, you will need to install the nginx-ingress controller in your Kubernetes cluster by running the following command:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/aws/deploy.yaml
```

This will deploy the nginx-ingress controller as a Deployment in your cluster.


## Create Ingress resource
Now that you have created the Services, you can create an Ingress resource to route traffic to them based on different paths. To create the Ingress resource, run the following command:

```
kubectl apply -f ingress.yaml
```

This will create an Ingress resource with rules to route traffic to the sample Services based on different paths.

## Install certificate manager
If you want to use HTTPS with your Ingress, you will need to install a certificate manager. Run the following command to install the Jetstack cert-manager:

```
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml
```

This will install the cert-manager as a Deployment in your cluster.

## Create Clusterissuer
After you have installed the cert-manager, you can create a Clusterissuer to issue SSL certificates for your Ingress. Run the following commands to create the staging and production Clusterissuers:

```
kubectl apply -f prod_issuer.yaml
```
