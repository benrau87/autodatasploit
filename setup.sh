#!/bin/bash
####################################################################################################################
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
gitdir=$PWD

##Logging setup
logfile=/var/log/datasploit_install.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

##Functions
function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

function error_check
{

if [ $? -eq 0 ]; then
	print_good "$1 successfully."
else
	print_error "$1 failed. Please check $logfile for more details."
exit 1
fi

}

function install_packages()
{

apt-get update &>> $logfile && apt-get install -y --allow-unauthenticated ${@} &>> $logfile
error_check 'Package installation completed'

}

function dir_check()
{

if [ ! -d $1 ]; then
	print_notification "$1 does not exist. Creating.."
	mkdir -p $1
else
	print_notification "$1 already exists. (No problem, We'll use it anyhow)"
fi

}
########################################
##BEGIN MAIN SCRIPT##
#Pre checks: These are a couple of basic sanity checks the script does before proceeding.
##Depos add
print_status "${YELLOW}Adding repos${NC}"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 &>> $logfile
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list &>> $logfile
echo 'deb http://www.rabbitmq.com/debian/ testing main' |sudo tee /etc/apt/sources.list.d/rabbitmq.list &>> $logfile
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add - &>> $logfile
error_check 'Repos added'

print_status "${YELLOW}Updating sources${NC}"
apt-get update &>> $logfile
error_check 'Sources updated'

print_status "${YELLOW}Installing apt packages${NC}"
apt-get install python python-pip mongodb-org rabbitmq-server linuxbrew-wrapper -y &>> $logfile
error_check 'Packages installed'

print_status "${YELLOW}Installing Datasploit and Python requirements${NC}"
cd /etc/
git clone https://github.com/upgoingstar/datasploit.git &>> $logfile
cd datasploit
pip install -r requirements.txt &>> $logfile
mv config_sample.py config.py
mkdir datasploitDb
mongod --dbpath datasploitDb &
print_status "${YELLOW}Press Enter to continue${NC}"
error_check 'Datasploit installed'

print_status "${YELLOW}Starting webserver${NC}"
brew services restart mongodb &>> $logfile
brew services restart rabbitmq &>> $logfile
C_FORCE_ROOT=root celery -A core worker -l info --concurrency 20  &>> $logfile     
python manage.py runserver 0.0.0.0:8000  

