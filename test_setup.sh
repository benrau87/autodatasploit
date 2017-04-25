#!bin/bash
apt-get update
apt-get install git unzip -y
wget https://github.com/upgoingstar/datasploit/archive/master.zip
unzip master.zip
cd master
pip install -r requirements.txt
mv config_sample.py config.py
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.9/rabbitmq-server_3.6.9-1_all.deb
dpkg -i rabb*
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 &>> $logfile
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list &>> $logfile
apt-get install mongodb-org
mkdir datasploitDb
mongod --dbpath datasploitDb
brew services restart mongodb 
brew services restart rabbitmq
C_FORCE_ROOT=root celery -A core worker -l info --concurrency 20       
python manage.py runserver 0.0.0.0:8000  & 
