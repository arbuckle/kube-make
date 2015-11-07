#!/bin/bash

usage() {
cat << EOF
    usage: $0 options

    This script does a thing in a place.

    Required arguments:
       -h      Show this message
       -s      Server hostname / IP
       -p      Server port
       -t      Server authentication token.  Authentication: Bearer <ProvidedToken>
       -a      Action to perform. audit|create|delete|reset
       -e      Target environment / application
EOF
}

while getopts "h:s:p:t:a:e:" opt; do
  case $opt in
    s) host=$OPTARG ;;
    p) port=$OPTARG ;;
    t) token=$OPTARG ;;
    a) action=$OPTARG ;;
    e) env=$OPTARG ;;
    h) 
        usage;
        exit 1
        ;;
    ?)
        usage
        exit 1
        ;;
  esac
done

# Fallback to environmental variables if the cmd line args aren't passed
host=${host:-$KUBE_DEPLOY_HOST}
port=${port:-$KUBE_DEPLOY_PORT} 
token=${token:-$KUBE_DEPLOY_TOKEN}

# And set up 
api=https://$host:$port/api/v1
workdir=./kube/$env

# Validate:
if [[ -z $host ]] ||[[ -z $port ]] ||[[ -z $token ]] ||[[ -z $action ]] ||[[ -z $env ]]; then
        usage
        exit 1
fi;


if [ ! -d $workdir ]; then 
    echo $workdir does not exist
    exit 1
fi;

# Dealing with the * case, redeploy everything...
if [ "$env" = "*" ]; then
    echo not implemented ha ha ha
    exit 2
fi;

# Performing the action
case "$action" in 
    audit)
        sh ./src/audit.sh $env $api $token $workdir
        ;;
    create)
        sh ./src/create.sh $env $api $token $workdir
        ;;
    delete)
        sh ./src/delete.sh $env $api $token $workdir
        ;;
    reset)
        sh ./src/delete.sh $env $api $token $workdir
        echo waiting 5s...
        sleep 5
        sh ./src/create.sh $env $api $token $workdir
        ;;
esac
