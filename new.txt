#!/bin/bash

# Define the Docker image name
DOCKER_IMAGE="pardhuguttula/ansible"

# Get the locally stored tag
LOCAL_TAG=$(docker inspect --format '{{ index .Config.Labels "tag" }}' "${DOCKER_IMAGE}" 2>/dev/null)

# Get the latest tag from Docker Hub
LATEST_TAG=$(curl -s "https://hub.docker.com/v2/repositories/${DOCKER_IMAGE}/tags/" | jq -r '.results[0].name')

# Check if Docker tag is available
if [ -z "$LATEST_TAG" ]; then
    echo "Error: Unable to determine the latest Docker tag from Docker Hub."
    exit 1
fi

# Remove invalid characters from Docker image name and tags
DOCKER_IMAGE_NAME=$(echo "$DOCKER_IMAGE" | tr -cd '[:alnum:]._-' | tr -s '-' | tr '[:upper:]' '[:lower:]')
LOCAL_TAG_NAME=$(echo "$LOCAL_TAG" | tr -cd '[:alnum:]._-' | tr -s '-' | tr '[:upper:]' '[:lower:]')
LATEST_TAG_NAME=$(echo "$LATEST_TAG" | tr -cd '[:alnum:]._-' | tr -s '-' | tr '[:upper:]' '[:lower:]')

# Combine Docker image name and tags to create container names
LOCAL_CONTAINER_NAME="${DOCKER_IMAGE_NAME}-${LOCAL_TAG_NAME}"
LATEST_CONTAINER_NAME="${DOCKER_IMAGE_NAME}-${LATEST_TAG_NAME}"

# Check if the locally stored tag is different from the latest tag
if [ "$LOCAL_TAG" != "$LATEST_TAG" ]; then
    # Stop the currently running container (if it exists)
    if [ -n "$(docker ps -q -f name=${LOCAL_CONTAINER_NAME})" ]; then
        echo "Stopping the running container..."
        docker stop "${LOCAL_CONTAINER_NAME}"
        echo "Container stopped."
    fi

    # Pull the image with the latest tag
    docker pull "${DOCKER_IMAGE}:${LATEST_TAG}"

    # Run the container with the latest tag
    docker run -d --name "${LATEST_CONTAINER_NAME}" -p 8088:80 --label "tag=${LATEST_TAG}" "${DOCKER_IMAGE}:${LATEST_TAG}"

    echo "New container started with Docker tag: ${LATEST_TAG}"
else
    echo "Docker tags are the same. No need to stop and run the container."
fi