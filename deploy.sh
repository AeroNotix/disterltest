#!/bin/bash

make build-docker
docker tag $1 gcr.io/$2/$1
gcloud docker -- push gcr.io/$2/$1
kubectl apply -f kubernetes/deployment.yml
kubectl apply -f kubernetes/service.yml
