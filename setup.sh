#!/bin/bash

source env.sh

echo "Enabling GCP APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com

echo "Creating terraform state bucket 'gs://${TF_STATE_BUCKET_NAME}'..."
gsutil mb -b on -l $REGION gs://${TF_STATE_BUCKET_NAME} >/dev/null

bash terraform/apply-terraform.sh

gcloud container clusters get-credentials $GKE_CLUSTER_NAME --region="${REGION}" --project="${PROJECT}"

echo "Creating GKE secrets"
kubectl create secret generic db-creds-secret \
  --from-literal=username=$DB_USER \
  --from-literal=password=$DB_PASSWORD \
  --from-literal=dbname=$DB_NAME
gcloud iam service-accounts keys create db_sa_credentials_key.json --iam-account="${DB_ACCESS_SA}@${PROJECT}.iam.gserviceaccount.com"
kubectl create secret generic "${DB_ACCESS_SA}-secret" --from-file=credentials.json=db_sa_credentials_key.json

bash deploy/create-deployer-image.sh

echo "Pushing source code to 'Cloud Source'"
gcloud init
git remote add google https://source.developers.google.com/p/${PROJECT}/r/${REPO_NAME}
git push --all google
