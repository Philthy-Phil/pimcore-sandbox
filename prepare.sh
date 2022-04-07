#!/bin/bash

# Color Definitions
NC='\e[0m'
BLACK='\e[1;30m'
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
LGRAY='\e[1;37m'

# Stop script on first error
set -e

if [ ! -f .env ];
then
    echo -e "${RED}Missing .env !${NC}"
    exit 0
else
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

echo -e "${YELLOW}Updating Composer Version...${NC}"
composer self-update
echo -e "${GREEN}Composer Update Complete!${NC}\n"

echo -e "${YELLOW}Creating Composer Project...${NC}"
COMPOSER_MEMORY_LIMIT=-1 composer create-project pimcore/skeleton tmp
echo -e "${GREEN}Composer Project Created Successfully!${NC}\n"

echo -e "${YELLOW}Fixing Folder Structure...${NC}"
mv tmp/.[!.]* . && mv tmp/* . && rmdir tmp
echo -e "${GREEN}Project Structure Fixed Successfully!${NC}\n"

echo -e "${YELLOW}Installing Pimcore...${NC}"
./vendor/bin/pimcore-install \
--mysql-host-socket=${DATABASE_MYSQL_HOST} \
--mysql-username=${DATABASE_MYSQL_USER} \
--mysql-password=${DATABASE_MYSQL_PASSWORD} \
--mysql-database=${DATABASE_MYSQL_DATABASE} \
--admin-username ${PIMCORE_ADMIN_USER} \
--admin-password ${PIMCORE_ADMIN_PASSWORD} \
--no-interaction
echo -e "${GREEN}Pimcore Installed Successfully!${NC}\n"

echo -e "${YELLOW}Setting Permissions...${NC}"
chown -R www-data: .
echo -e "${GREEN}Permissions Set Successfully!${NC}\n"

echo -e "${YELLOW}Additional Setup (nano, cron)...${NC}"
apt update &&
apt install nano &&
apt install cron
echo -e "${GREEN}Additional Setup Successfully!${NC}\n"

echo -e "${YELLOW}Setup Maintenance Cron Job...${NC}"

echo "" >> /etc/crontab &&
echo "# this command needs anyway executed via cron or similar task scheduler" >> /etc/crontab &&
echo "# it fills the message queue with the necessary tasks, which are then processed by messenger:consume" >> /etc/crontab &&
echo "*/5 * * * * /var/www/html/bin/console pimcore:maintenance --async" >> /etc/crontab &&
echo "" >> /etc/crontab &&
echo "# it's recommended to run the following command using a process control system like Supervisor" >> /etc/crontab &&
echo "# please follow the Symfony Messenger guide for a best practice production setup:" >> /etc/crontab &&
echo "# https://symfony.com/doc/current/messenger.html#deploying-to-production" >> /etc/crontab &&
echo "*/5 * * * * /var/www/html/bin/console messenger:consume pimcore_core pimcore_maintenance --time-limit=300" >> /etc/crontab

echo -e "${YELLOW}Run Maintenance Cron Jobs...${NC}"
./bin/console pimcore:maintenance --async
#./bin/console messenger:consume pimcore_core pimcore_maintenance --time-limit=300
echo -e "${GREEN}Maintenance Cron Job Successfully!${NC}\n"

