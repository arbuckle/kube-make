#!/bin/bash
# Copyright David Arbuckle 2015
# MIT Licensed

NAMESPACE=$1
KUBE_MASTER=$2
API="$KUBE_MASTER/namespaces/$NAMESPACE"
RESOURCES=("pods" "replicationcontrollers" "services" "events")

if [ "$NAMESPACE" == "" ]; then
	echo invalid namespace
	exit 1
fi;

if [ "$KUBE_MASTER" == "" ]; then
	echo invalid kube master
	exit 1
fi;

echo auditing kubernetes at $API

echo getting nodes
curl -s "$KUBE_MASTER/nodes"

for resource in "${RESOURCES[@]}"; do
	echo getting $resource
	curl -s "$API/$resource"
done;

