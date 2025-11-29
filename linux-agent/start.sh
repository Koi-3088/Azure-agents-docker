#!/bin/bash
set -e

if [ -z "$AZP_URL" ] || [ -z "$AZP_TOKEN" ]; then
  echo "AZP_URL and AZP_TOKEN must be set"; exit 1;
fi

if [ -z "$AZP_POOL" ]; then AZP_POOL="self-hosted"; fi
if [ -z "$AZP_AGENT_NAME" ]; then AZP_AGENT_NAME=$(hostname); fi

cd /home/azureuser/linux-agent

# If already configured, skip reconfig
if [ ! -f .agent ]; then
  ./config.sh --unattended \
    --url "$AZP_URL" \
    --auth pat \
    --token "$AZP_TOKEN" \
    --pool "$AZP_POOL" \
    --agent "$AZP_AGENT_NAME" \
    --replace \
    --acceptTeeEula
fi

cleanup() {
  echo "Removing agent configuration..."
  ./config.sh remove --unattended --auth pat --token "$AZP_TOKEN"
}
trap cleanup EXIT

./run.sh
