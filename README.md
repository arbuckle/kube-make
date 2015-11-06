# Dangerous Kubernetes Management Tool

Insight:

MAKE is a bad fit for this... 
shell scripts may be too, when it comes to performing updates on existing resources, but moving forward anyways

What I need is an application that lets me manage the artifacts that are important to the kubernetes environment separately from
all of my code repositories.  The source repo should be concerned with creating a shippable "artifact".  This project is concerned 
mainly with orchestrating and connecting all different kinds of artifacts.

So it makes a little bit of sense to colocate the tools responsible for deploying to a remote kubernetes with the configurations
describing how they will be deployed.


## TODOs:

1 improve argument parsing - add help text and consolidate valudation
* create example project
* create example project with secrets
* create example project with externals
* delete actual projects from here
* update functionality
* validation of kube responses functionality
* ~~replace makefile with deploy.sh~~

---

This utility provides some simple capabilities related to managing a Kubernetes cluster over the api.  There is a tool to retrieve the complete state (audit), delete a namespace, and bootstrap an environment from colacated config files.  

The Makefile is configured with an address and a namespace, which are provided to a variety of simple shell scripts.

There are four commands:

```
    make audit
    make create
    make delete
    make reset
```

## make audit

This command calls the API to retrieve services, replicationcontrollers, endpoints, pods, and events for the namespace, as well as the node list.

Output is printed to the console.


## make create

This command reads the contents of prefixed-json files in the same working directory and pushes them to the API.

These JSON files can contain either JSON or YAML (though only files with the json suffix will be read), which is simply POSTed to the kube master to create new resources.  Errors are printed to the console, but an error creating a resource will not impact the exit code meaningfully.  Most often you'll see errors if a nodePort on a new service has a conflict with an existing service in a different namespace.

`<namespace>.json` - this is a namespace definition file

`svc-*.json` - for services

`rc-*.json` - for replication controllers

`endpoint-*.json` - for endpoints


## make delete

Deletes the namespace.  This will stop all running containers and delete all existing resources.


## make reset

Runs delete, then create.


