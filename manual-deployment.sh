#!/bin/bash
source env.sh

envsubst < k8s/Deployment.yaml | kubectl apply -f -