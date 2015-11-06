#!/bin/bash

while getopts ":s:p:t:a:e:" opt; do
  case $opt in
    s) host=$OPTARG ;;
    p) port=$OPTARG ;;
    t) token=$OPTARG ;;
    a) action=$OPTARG ;;
    e) env=$OPTARG ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

host=${host:-$KUBE_DEPLOY_HOST}
port=${port:-$KUBE_DEPLOY_PORT} 
token=${token:-$KUBE_DEPLOY_TOKEN}

echo $host $port $token $action $env

err=0
if [ "$host" = "" ]; then
    echo "missing -s [HOST] option"
    err=1
fi;

if [ "$port" = "" ]; then
    echo "missing -p [PORT] option"
    err=1
fi;

if [ "$token" = "" ]; then
    echo "missing -t [TOKEN] option"
    err=1
fi;


# Validating command-line input
if [ "$env" = "" ]; then
    echo missing environment argument.  provide environment name or * for all
    err=1
fi;

if [ "$action" = "" ]; then
    echo "missing action argument  provide one of audit|create|delete|reset"
    err=1
fi;

if [[ $err = 1 ]]; then 
        echo "USAGE: deploy.sh -h [HOST] -p [PORT] -t [TOKEN] [ACTION] [ENVIRONMENT]"
        exit 1
fi;


# Derived vars
api=https://$host:$port/api/v1
workdir=./kube/$env

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
esac
