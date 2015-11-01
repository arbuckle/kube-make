
#!/bin/bash
# Copyright David Arbuckle 2015
# MIT Licensed

NAMESPACE=$1
KUBE_MASTER=$2
API="$KUBE_MASTER/namespaces/$NAMESPACE"
RESOURCES=("svc" "rc" "endpoint")

if [ "$NAMESPACE" == "" ]; then
	echo invalid namespace
	exit 1
fi;

if [ "$KUBE_MASTER" == "" ]; then
	echo invalid kube master
	exit 1
fi;

echo checking for namespace file at ./$NAMESPACE.json
if [ ! -f $NAMESPACE.json ]; then
	# This actually doesn't even get executed
	echo unable to find namespace file.  expected ./$NAMESPACE.json
	exit 1
fi;

echo creating namespace: $API
curl --data @$NAMESPACE.json "$KUBE_MASTER/namespaces"

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
	for file in $(ls $resource*.json); do
		echo creating $file in $NAMESPACE
		echo curl --data @$file $endpoint 
		curl --data @$file $endpoint
	done
done;


