#!/bin/bash

usage() {
cat << EOF
    usage: $0 options

    This script does a thing in a place.

    Required arguments:
       -h      Show this message
       -s      Server hostname / IP
       -p      Server port
       -a      Action to perform. audit|create|delete|reset
       -e      Target environment / application

    Optional:
       -t      Server authentication token.  Authentication: Bearer <ProvidedToken>
       -c      Server client certificate. Not implemented.
EOF
}

while getopts "htc:s:p:a:e:" opt; do
  case $opt in
    s) host=$OPTARG ;;
    p) port=$OPTARG ;;
    a) action=$OPTARG ;;
    e) env=$OPTARG ;;
    t) token=$OPTARG ;;
    c) 
        usage;
        echo Certificate authentication is not yet implemented
        exit 1
        ;;
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
#cert=${cert:-$KUBE_DEPLOY_CERT}

# And set up 
protocol=https
if [[ -z $token ]]; then  #&& [[ -z $cert ]]; then
    protocol=http
    token=xxx # need to set a dummy token, since CRUD scripts are expecting one.
fi;
api=$protocol://$host:$port/api/v1
workdir=./apps/$env

echo $api

# Validate:
if [[ -z $host ]] ||[[ -z $port ]] || [[ -z $action ]] ||[[ -z $env ]]; then
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
    update)
        sh ./src/update.sh $env $api $token $workdir
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
