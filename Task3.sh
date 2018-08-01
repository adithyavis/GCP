#!/bin/bash
#ASSIGNMENT 3 : Cloud Pub/Sub & Cloud Functions assignment

printf "Creating Pub/Sub Topic and Subcription"
gcloud pubsub topics create adithyatopic
gcloud pubsub subscriptions create cdm-subscription --topic adithyatopic

printf "Cloning directory from github"
sudo apt install git -y
git clone https://github.com/adithyavis/GCP-PubSub.git

cd ~/GCP-PubSub/

printf "Deploying cloud function"
gcloud beta functions deploy adithyafunction --runtime python37 --source ~/GCP-PubSub --trigger-topic adithyatopic --timeout 540s

printf"Publishing message to subrcriber"
msg=$(<pubsub-msg.txt)
gcloud pubsub topics publish adithyatopic --message $msg

printf"Wait for logs to be printed. Waiting time: 5m"
sleep 5m
printf"Printing logs"
gcloud beta functions logs read adithyafunction
