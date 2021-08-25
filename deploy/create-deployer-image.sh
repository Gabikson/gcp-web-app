#!/bin/bash
ROOT=$(dirname "${BASH_SOURCE[0]}")

source ${ROOT}/../env.sh

gcloud builds submit ${ROOT} --tag gcr.io/${PROJECT}/${DEPLOYER_IMAGE_NAME}
