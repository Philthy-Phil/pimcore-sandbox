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