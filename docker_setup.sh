#!/bin/bash

apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   
apt-get update
apt-get install -y docker-engine
  
docker pull appsecco/datasploit
  
docker run -p 8000:8000 -it appsecco/datasploit
  
service rabbitmq-server start
mongod --fork --logpath datasploitDb/mongodb.log --dbpath datasploitDb
cd /opt/datasploit/core
nohup C_FORCE_ROOT=root celery -A core worker -l info --concurrency 20 &
nohup python manage.py runserver 0.0.0.0:8000 &
