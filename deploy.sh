#!/bin/bash

make build-docker
export GCLOUD_APP=$1
export GCLOUD_PROJECT=$2
docker tag $1 gcr.io/$2/$1
gcloud docker -- push gcr.io/$2/$1
envsubst < kubernetes/deployment.yml | kubectl apply -f -
envsubst < kubernetes/service.yml | kubectl apply -f -
