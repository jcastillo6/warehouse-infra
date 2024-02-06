# Warehouse Infrastructure

It is divide in two parts:
- AKS provisioning
- Jenkins deployment

## AKS
For the AKS provisioning you should create a service principal and add pass the id and password as terraform variables

`az ad sp create-for-rbac --name terraform --role contributor --scope "/subscriptions/{subscription-id}"`

from the response take the id and password and create a file named terraformVariables.tfvars and with this to properties

appId = "{id}"  
password = "{password}"

then create the plan  

`tf plan --var-file=terraformVariables.tfvars --out=main.tfplan`

then run the plan

`tf apply main.tfplan`

## Jenkins
For jenkins deployment into the kubernetes cluster you need to have the credential to connect to it

`az aks get-credentials --resource-group {resource-group-name} --name {cluster-name} --overwrite-existing`

after the deployment you need to do a manual step, you need to recreate the service **ingress-nginx-controller**
- first delete the service from ingress-nginx-controller
- then go to jenkins folder and create the service using the file ingress-ctr.yaml

wait for a few minutes, and you should be able to access to jenkins from the browser using the ingress endpoint

[!IMPORTANT]  
At the time of writing this I haven't been able to solve the issue with the ingress controller, the recreation step should not be necessary





