#!/bin/bash

echo "node-red-init: starting initialization..."

# Ensure configuration exists
if [ ! -d "/config/nodes" ]
then
    echo "node-red-init: creating /config directory"
    mkdir -p /config/nodes 

    # Copy in template files
    cp /etc/node-red/flows.json /config/
    cp /etc/node-red/settings.js /config/
    
    # Create random flow id
    id=$(node -e "console.log((1+Math.random()*4294967295).toString(16));")
    sed -i "s/%%ID%%/${id}/" "/config/flows.json"

    echo "node-red-init: First container startup copying settings"
fi

echo "node-red-init: initialization complete"
