#!/bin/bash

# Ensure configuration exists
if [ ! -d "/config/nodes" ]
then
    mkdir -p /config/nodes 

    # Copy in template files
    cp /etc/node-red/flows.json /config/
    cp /etc/node-red/settings.js /config/
    
    # Create random flow id
    id=$(node -e "console.log((1+Math.random()*4294967295).toString(16));")
    sed -i "s/%%ID%%/${id}/" "/config/flows.json"

    echo "First container startup copying settings"
# else
#     echo "-- Not first container startup --"
fi







