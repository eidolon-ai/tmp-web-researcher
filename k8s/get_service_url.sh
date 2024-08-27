#!/bin/bash

# Check if a service name was provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a service name."
    echo "Usage: $0 <service-name>"
    exit 1
fi

SERVICE_NAME="$1"

# Get the Kubernetes context
CONTEXT=$(kubectl config current-context)

# Get the NodePort of the service
NODE_PORT=$(kubectl get svc "$SERVICE_NAME" -o=jsonpath='{.spec.ports[0].nodePort}')

# Check if NodePort is empty
if [ -z "$NODE_PORT" ]; then
    echo "Error: Couldn't find NodePort for '$SERVICE_NAME'. Make sure the service exists and is of type NodePort."
    exit 1
fi

# Determine the IP based on the context
if [[ $CONTEXT == "minikube" ]]; then
    IP=$(minikube ip)
elif [[ $CONTEXT == "docker-desktop" || $CONTEXT == "kind-"* ]]; then
    IP="localhost"
else
    # For other setups, try to get the internal IP of the first node
    IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
fi

# Print the URL
echo "http://$IP:$NODE_PORT"
