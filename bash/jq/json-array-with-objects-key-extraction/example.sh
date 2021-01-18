#!/usr/bin/zsh

# Online JQ test
# https://jqplay.org/

# Manually test a expression in terminal
# cat foo.json | jq '<expression>'

# Get external file
local json=$(cat ./data.json)

# Set array length
local jsonLength=$(jq '. | length' <<< "$json")

# Foreach the length of the array in json object
# E.g. `seq 3` will just loop 3 times.
for i in `seq $jsonLength`; do

    # Since an array start at 0, make sure that we subtract by 1
    key=$(expr $i - 1)

    # Debug
    echo "Parsing object ${key} in array"

    # Assign variables for each key in object
    local dataText=$(jq ".[$key].text" --raw-output <<< "$json")
    local dataExecutable=$(jq ".[$key].executable" --raw-output <<< "$json")
    local dataPath=$(jq ".[$key].path" --raw-output <<< "$json")

    # Debug
    echo " dataText: ${dataText}"
    echo " dataExecutable: ${dataExecutable}"
    echo " dataPath: ${dataPath}"
    echo

done