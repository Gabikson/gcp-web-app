#!/bin/bash

export PROJECT=$GOOGLE_CLOUD_PROJECT
export REGION=europe-west2
export ZONE=europe-west2-b
export TF_STATE_BUCKET_NAME=$PROJECT-tf-state
export REPO_NAME=cloud-x-demo
export DB_ACCESS_SA=db-access-sa
export DB_INSTANCE=cloud-x-demo-instance3
export DB_NAME=cloud-x-demo
export DB_USER=postgres
export DB_PASSWORD=postgres
export GKE_CLUSTER_NAME=cloud-x-demo-cluster
export APP_NAME=cloud-x-demo
export DEPLOYER_IMAGE_NAME=xkube
