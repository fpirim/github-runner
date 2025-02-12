#!/bin/bash

RUNNER_ALLOW_RUNASROOT=1

if [ -z "${GITHUB_URL}" ]; then
    echo "Error: GITHUB_URL environment variable is not set"
    exit 1
fi

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set"
    exit 1
fi

if [ -z "${RUNNER_NAME}" ]; then
    RUNNER_NAME=$(hostname)
fi

if [ -z "${RUNNER_LABELS}" ]; then
    RUNNER_LABELS="self-hosted,Linux,Docker"
fi

if [ -z "${RUNNER_WORK_DIRECTORY}" ]; then
    RUNNER_WORK_DIRECTORY="_work"
fi

cd /home/ubuntu/actions-runner

./config.sh \
    --unattended \
    --url "${GITHUB_URL}" \
    --token "${GITHUB_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --work "${RUNNER_WORK_DIRECTORY}" \
    --replace

remove() {
    ./config.sh remove --token "${GITHUB_TOKEN}"
}

trap remove EXIT

./run.sh