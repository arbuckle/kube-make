#!/bin/bash
# Copyright David Arbuckle 2015
# MIT Licensed

NAMESPACE=$1
KUBE_MASTER=$2
KUBE_TOKEN=$3
WORKDIR=$4

API="$KUBE_MASTER/namespaces/$NAMESPACE"

if [ "$NAMESPACE" == "" ]; then
	echo invalid namespace
	exit 1
fi;

if [ "$KUBE_MASTER" == "" ]; then
	echo invalid kube master
	exit 1
fi;

echo cd $WORKDIR
cd $WORKDIR

echo deleting namespace
curl -k -s -X DELETE --header "Authorization: Bearer $KUBE_TOKEN" "$API"

