#!/bin/bash
source env.sh

envsubst < k8s/db-migration-pod.yaml | kubectl apply -f -