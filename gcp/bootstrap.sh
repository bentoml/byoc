#!/bin/bash

# SET $PROJECT
if [ -z $PROJECT ]; then
  echo "Set your project ('export PROJECT=<project id>')!"
  exit 1
fi

gcloud iam service-accounts create bentocloud-admin --display-name="BentoCloud Administrator" --project $PROJECT

gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/artifactregistry.admin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/iam.serviceAccountAdmin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/iam.serviceAccountKeyAdmin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/storage.admin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/storage.hmacKeyAdmin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/compute.admin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/container.admin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/redis.admin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/iam.securityReviewer
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/resourcemanager.projectIamAdmin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:bentocloud-admin@$PROJECT.iam.gserviceaccount.com \
       --role roles/logging.configWriter
gcloud iam service-accounts keys create "bentocloud-admin-${PROJECT}.json" --iam-account="bentocloud-admin@${PROJECT}.iam.gserviceaccount.com"
