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

echo -e "${YELLOW}\nPreparing Initial Setup...${NC}\n"
if [ ! -f .env ];
then
    echo -e "${RED}Missing .env !${NC}"
    exit 0
else
  echo -e "${LGRAY}Exported Environment Variables.${NC}"
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

if [ ! -d ./db ];
then
    mkdir db
    echo -e "${LGRAY}db Directory successfully created.${NC}"
else
  echo -e "${LGRAY}db Directory already exists.${NC}"
fi

if [ ! -d ./pimcore ];
then
    mkdir pimcore
    echo -e "${LGRAY}pimcore Directory successfully created.\n${NC}"
else
  echo -e "${LGRAY}pimcore Directory already exists.\n${NC}"
fi

echo -e "${YELLOW}Deploying Stack. Running...${NC}\n"
docker stack deploy -c docker-compose.yml $1

PIMCORE_CONTAINER_NAME=$1_pimcore.1
finished=false
n=1

while [ ${finished} = "false" ];
do
  sleep 8
  if [ ! $(docker ps -qf name="$PIMCORE_CONTAINER_NAME") ];
  then
     echo -e "${BLACK}Waiting For Rising Docker Container... TRY ${n}${NC}"
     n=$(( n+1 ))
  else
    finished=true
    PIMCORE_CONTAINER_ID=$(docker ps -qf name="$PIMCORE_CONTAINER_NAME")
    echo -e "${GREEN}Successfully deployed your stack, hooray!${NC}\n"
  fi
done

chmod +x ./prepare.sh
docker cp ./prepare.sh ${PIMCORE_CONTAINER_ID}:/var/www/html/prepare.sh
docker cp ./.env ${PIMCORE_CONTAINER_ID}:/var/www/html/.env
echo -e "${YELLOW}Copied Prepare-Script & Environment Variables To Its Container Location${NC}"
echo -e "${YELLOW}Entering Pimcore Container, Preparing Setup...${NC}\n"

docker exec ${PIMCORE_CONTAINER_ID} bash -c "./prepare.sh"
echo -e "\n${GREEN}Wohoo! Finished Setup! Let's Get Stuff Done!${NC}\n"

echo -e "Frontend -> \t http://localhost:5000 or http://localhost:5001"
echo -e "Backend -> \t http://localhost:5000/admin"
echo -e "Adminer -> \t http://localhost:5003"

echo -e "\nPreconfigured Admin Credentials:"
echo -e "User: ${PIMCORE_ADMIN_USER} Password: ${PIMCORE_ADMIN_PASSWORD}\n"
docker exec -it ${PIMCORE_CONTAINER_ID} bash