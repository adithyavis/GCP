#!/bin/bash
printf "Creating VPC with automatic subnets"
gcloud compute --project=pe-training networks create adithyavpc1 --subnet-mode=auto
printf "Creating Firewall rules and attaching it to VPC"
gcloud compute --project=pe-training firewall-rules create sshfromquantiphi --direction=INGRESS --priority=1000 --network=adithyavpc1 --action=ALLOW --rules=tcp:22 --source-ranges=59.152.0.0/16 --target-tags=sshfromquantiphi
gcloud compute --project=pe-training firewall-rules create adithyavpc1-allow-http --direction=INGRESS --priority=1000 --network=adithyavpc1 --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server
gcloud compute --project=pe-training firewall-rules create adithyavpc1-allow-https --direction=INGRESS --priority=1000 --network=adithyavpc1 --action=ALLOW --rules=tcp:443 --source-ranges=0.0.0.0/0 --target-tags=https-server

printf "Creating VPC with custom subnets"
gcloud compute --project=pe-training networks create adithyavpc2 --subnet-mode=custom
gcloud compute --project=pe-training networks subnets create subnet1 --network=adithyavpc2 --region=us-east1 --range=10.0.0.0/24
gcloud compute --project=pe-training networks subnets create subnet2 --network=adithyavpc2 --region=us-central1 --range=10.0.1.0/24

printf "Creating Instance"
gcloud compute --project=pe-training instances create adithyaprivateinstance --zone=us-east1-b --machine-type=n1-standard-1 --subnet=adithyavpc1 --no-address --maintenance-policy=MIGRATE --service-account=912623308461-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server,https-server --image=debian-9-stretch-v20180716 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=adithyaprivateinstance
