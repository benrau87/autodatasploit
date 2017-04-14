#!/bin/bash

cd /etc/datasploit/core
print_status "${YELLOW}Starting webserver${NC}"
python manage.py migrate
python manage.py runserver 0.0.0.0:8000  
