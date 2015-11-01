#!/bin/bash
# Copyright David Arbuckle 2015
# MIT Licensed

NAMESPACE=$1
KUBE_MASTER=$2
API="$KUBE_MASTER/namespaces/$NAMESPACE"

if [ "$NAMESPACE" == "" ]; then
	echo invalid namespace
	exit 1
fi;

if [ "$KUBE_MASTER" == "" ]; then
	echo invalid kube master
	exit 1
fi;

echo deleting namespace
curl -s -X DELETE "$API"

