#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed or not in PATH${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}Docker daemon is not running${NC}"
    exit 1
fi

IMAGE_COUNT=$(docker images -aq | wc -l)

if [ "$IMAGE_COUNT" -eq 0 ]; then
    echo -e "${GREEN}No Docker images to delete${NC}"
    exit 0
fi

echo -e "Found ${YELLOW}$IMAGE_COUNT${NC} Docker images"
echo ""

docker images
echo ""

read -p "Are you sure you want to delete ALL Docker images AND containers? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo -e "${GREEN}Operation cancelled${NC}"
    exit 0
fi

echo -e "${YELLOW}Stopping all containers...${NC}"
docker stop $(docker ps -aq) 2>/dev/null

echo -e "${YELLOW}Removing all containers...${NC}"
docker rm $(docker ps -aq) 2>/dev/null

echo -e "${YELLOW}Deleting all Docker images...${NC}"
docker rmi -f $(docker images -aq) 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}All Docker images deleted successfully${NC}"
else
    echo -e "${YELLOW}Attempting with docker system prune...${NC}"
    docker system prune -a -f
fi

REMAINING_IMAGES=$(docker images -aq | wc -l)
REMAINING_CONTAINERS=$(docker ps -aq | wc -l)

if [ "$REMAINING_IMAGES" -eq 0 ]; then
    echo -e "${GREEN}Verification: No images remain${NC}"
else
    echo -e "${RED}$REMAINING_IMAGES images still remain${NC}"
    docker images
fi

if [ "$REMAINING_CONTAINERS" -eq 0 ]; then
    echo -e "${GREEN}Verification: No containers remain${NC}"
fi
