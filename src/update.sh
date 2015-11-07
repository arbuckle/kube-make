#!/bin/bash
# Copyright David Arbuckle 2015
# MIT Licensed

NAMESPACE=$1
KUBE_MASTER=$2
KUBE_TOKEN=$3
WORKDIR=$4

API="$KUBE_MASTER/namespaces/$NAMESPACE"
RESOURCES=("rc" "endpoint")

if [ "$NAMESPACE" == "" ]; then
	echo invalid namespace
	exit 1
fi;

if [ "$KUBE_MASTER" == "" ]; then
	echo invalid kube master
	exit 1
fi;

# Creates, then updates
cupdate() {
    file=$1
    endpoint=$2
    resource_name=$(echo $file | sed 's/\.json//g')
    if [[ "$resource_name" = "namespace" ]]; then 
        resource_endpoint=$endpoint/$NAMESPACE
    else 
        resource_endpoint=$endpoint/$resource_name
    fi;

    echo $file, $endpoint, $resource_name, $resource_endpoint

    curl -X POST -k --header "Authorization: Bearer $KUBE_TOKEN" --data @$file "$endpoint"
    curl -X PUT  -k --header "Authorization: Bearer $KUBE_TOKEN" --data @$file "$resource_endpoint"
}

echo cd $WORKDIR
cd $WORKDIR

echo checking for namespace file at ./namespace.json
if [ ! -f namespace.json ]; then
	# This actually doesn't even get executed??
	echo unable to find namespace file.  expected ./namespace.json
	exit 1
fi;

echo cupdating namespace: $API
cupdate namespace.json "$KUBE_MASTER/namespaces"

for resource in "${RESOURCES[@]}"; do
	case "$resource" in 
		svc)
			endpoint="$API/services"
			;;
		rc)
			endpoint="$API/replicationcontrollers"
			;;
		endpoint)
			endpoint="$API/endpoints"
			;;
	esac
	if [ "$endpoint" == "" ]; then
		echo this should never happen.  
		exit 1
	fi;

	echo getting $resource files
        if [ ! -f $resource*.json ]; then
            echo no $resource files found.  skipping
            continue    
        fi
         
	for file in $(ls $resource*.json); do
		echo creating $file in $NAMESPACE
                cupdate $file $endpoint
	done
done;


