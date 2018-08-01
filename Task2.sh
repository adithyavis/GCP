printf "Creating instance template"
gcloud beta compute --project=pe-training instance-templates create adithyainstancetemplate --machine-type=n1-standard-1 --network=projects/pe-training/global/networks/default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=912623308461-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server,https-server --image=debian-9-stretch-v20180716 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=adithyainstancetemplate --metadata=startup-script=\#\!\ /bin/bash$'\n'apt-get\ update\ -y$'\n'apt-get\ install\ apache2\ -y$'\n'cd\ /var/www/html/$'\n'echo\ \"\<html\>\<title\>HTTP\ APPLICATION\ PART1\</title\>\<body\>\<h1\>Hello\ World\</h1\>\</body\>\</html\>\"\ \>\ index.html 


printf "Creating Health check"
gcloud compute --project "pe-training" http-health-checks create "adithyahealthcheck" --port "80" --request-path "/" --check-interval "15" --timeout "5" --unhealthy-threshold "10" --healthy-threshold "2"

printf "Creating instance group"
gcloud beta compute --project "pe-training" instance-groups managed create "adithyainstancegroup" --base-instance-name "adithyainstancegroup" --template "adithyainstancetemplate" --size "1" --zones "us-east1-b,us-east1-c,us-east1-d" http-health-checks "adithyahealthcheck"
gcloud compute --project "pe-training" instance-groups managed set-autoscaling "adithyainstancegroup" --region "us-east1" --cool-down-period "60" --max-num-replicas "10" --min-num-replicas "2" --target-cpu-utilization "0.8"

printf "Creating load balancer"
gcloud compute backend-services create adithybackend --http-health-checks adithyahealthcheck --protocol http --load-balancing-scheme external --global
gcloud compute backend-services add-backend adithybackend --instance-group adithyainstancegroup --max-utilization 0.8 --global --capacity-scaler 1.0 --instance-group-region us-east1
gcloud compute addresses create adithyaip --global --ip-version ipv4
gcloud compute url-maps create adithyaurlmap --default-service=adithybackend 
gcloud compute target-http-proxies create adithyatargetproxy --url-map=adithyaurlmap 
gcloud compute forwarding-rules create adithyafrontend --target-http-proxy adithyatargetproxy --address adithyaip --global-address --ports 80 --global      

printf "Creating storage bucket"
gsutil mb -p pe-training -c regional -l us-east1 gs://adithya/

