#!/bin/bash
ROOT=$(dirname "${BASH_SOURCE[0]}")

source ${ROOT}/../env.sh

#terraform -chdir=../terraform apply -var-file=cloud-props.tfvars

terraform -chdir=${ROOT} apply \
  -var="project_id=${PROJECT}" \
  -var="project_region=${REGION}" \
  -var="project_zone=${ZONE}" \
  -var="db_access_sa_name=${DB_ACCESS_SA}" \
  -var="gke-cluster-name=${GKE_CLUSTER_NAME}" \
  -var="source-repository-name=${REPO_NAME}" \
  -var="app-name=${APP_NAME}" \
  -var="cloud-build-name=${APP_NAME}-ci-cd" \
  -var="cloud-sql-instance-name=${DB_INSTANCE}" \
  -var="deployer-image-name=${DEPLOYER_IMAGE_NAME}"
