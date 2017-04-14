#!/bin/bash

cd /etc/datasploit
print_status "${YELLOW}Starting webserver${NC}"
brew services restart mongodb
brew services restart rabbitmq 
C_FORCE_ROOT=root celery -A core worker -l info --concurrency 20  
python manage.py runserver 0.0.0.0:8000  
