# Dangerous Kubernetes Management Tool

This utility provides some simple capabilities related to managing a Kubernetes cluster over the api.

The Makefile is configured with an address and a namespace, which it provides to a variety of simple shell scripts.

There are four commands:

```
    make audit
    make create
    make delete
    make reset
```

## make audit

This command calls the API to retrieve services, replicationcontrollers, endpoints, pods, and events for the namespace, as well as the node list.

It prints its output to the console.

## make create

This command reads the contents of prefixed-json files in the same working directory and pushes them to the API.

These JSON files can contain either JSON or YAML (though only files iwth the json suffix will be read), which is simply POSTed to the kube master to create new resources.  Errors are returned, but an error creating a resource will not impact the exit code meaningfully.  Most often you'll see this if a nodePort on a new service has a conflict with an existing service in a different namespace.

`<namespace>.json` - this is a namespace definition file
`svc-*.json` - for services
`rc-*.json` - for replication controllers
`endpoint-*.json` - for endpoints


## make delete

Deletes the namespace.  This will stop all running containers and delete all existing resources.


## make reset

Runs delete, then create.


