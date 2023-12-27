#!/bin/bash
# Get the ID of the most recently created container
CONTAINER_ID=$(docker ps -lq)
echo $CONTAINER_ID
if [ -n "$CONTAINER_ID" ]
then
    # Container is running, stop it
    echo "Stopping the running container..."
    docker stop ${CONTAINER_ID}
    echo "Container stopped."
fi
#!/bin/bash
# Get the ID of the most recently created container
CONTAINER_ID=$(docker ps -lq)
echo $CONTAINER_ID
if [ -n "$CONTAINER_ID" ]
then
    # Container is running, stop it
    echo "Stopping the running container..."
    docker stop ${CONTAINER_ID}
    echo "Container stopped."
fi
# Define the Docker image name
DOCKER_IMAGE="pardhuguttula/ansible"
DOCKER_TAG=$(curl -s "https://hub.docker.com/v2/repositories/${DOCKER_IMAGE}/tags/" | jq -r '.results[0].name')

# Remove invalid characters from Docker image name and tag
DOCKER_IMAGE_NAME=$(echo "$DOCKER_IMAGE" | tr -cd '[:alnum:]._-' | tr -s '-' | tr '[:upper:]' '[:lower:]')
DOCKER_TAG_NAME=$(echo "$DOCKER_TAG" | tr -cd '[:alnum:]._-' | tr -s '-' | tr '[:upper:]' '[:lower:]')

# Combine Docker image name and tag to create the container name
CONTAINER_NAME="${DOCKER_IMAGE_NAME}-${DOCKER_TAG_NAME}"
# Pull the image with the dynamically determined tag
docker pull "${DOCKER_IMAGE}:${DOCKER_TAG}"
# Run the container
docker run -d --name "${CONTAINER_NAME}" -p 8088:80 "${DOCKER_IMAGE}:${DOCKER_TAG}"
echo "New container started with Docker tag: ${DOCKER_TAG}"