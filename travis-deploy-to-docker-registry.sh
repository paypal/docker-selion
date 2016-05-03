#!/bin/bash
#################################################
# Deploys resulting containers to docker registry
#################################################

DOCKER_USERNAME=${DOCKER_USERNAME-foo}
DOCKER_PASSWORD=${DOCKER_PASSWORD-bar}

# Deploy only if the following conditions are satisfied
# 1. The build is for the project paypal/docker-selion, not on the fork
# 3. The build is not on a pull request
# 4. The build is on the develop branch
if [ "$TRAVIS_REPO_SLUG" = "paypal/docker-selion" ] && [ "$TRAVIS_PULL_REQUEST" = "false" ] && [ "$TRAVIS_BRANCH" = "develop" ]; then
    echo "Deploying to Docker registry...\n"
    # verify that we are on develop branch, otherwise exit with error code
    output=$(git rev-parse --abbrev-ref HEAD)
    if [ "$output" = "develop" ]; then
      docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
      if [ $? -ne 0 ]; then
        echo "Failed to authenticate with Docker registry."
        exit 1
      fi
      make dev_release
    else
        echo "Not on the develop branch."
        exit 1
    fi
else
    echo "Deployment selection criteria not met."
fi
