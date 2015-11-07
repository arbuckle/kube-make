# Dangerous Kubernetes Management Tool

> ... 
> What if this is as good as it gets?
>                      - Melvin Udall

This tool provides some capabilities related to managing a bunch of kubernetes configurations on a remote server.

Kubernetes configs are stored in `./apps/<myapp>/` and are read by the various deploy scripts to facilitate changes
to the remote server.   


## Supported capabilities

You can **audit** the configuration in a given namespace.
You can **create** a new namespace and add replication controllers, services, and endpoints to that namespace.
You can **update** an existing application with new replica counts / service endpoint addresses.
You can **delete** a namespace outright

A word of warning:  This tool is a loaded weapon.  It's really easy to take deployed services down.


## Conventions

Applications are represented as folders in the `./apps` directory.

An application folder _must_ contain a file named `namespace.json`, that contains a Kubernetes v1 namespace configuration.

An application folder _may_ contain files prefixed by each of `rc-`, `svc-`, or `endpoint-`.  These files must contain a 
Kubernetes configuration for any of a ReplicationController, Service, or Endpoint respectively.  

**Important Note**:  In order for updates to work correctly, the name of the remote resource _must_ match the configuration
filename, excluding the extention. Example:

```
sassafras:apps arbuckle$ cat example/rc-example.json
{
    "apiVersion": "v1",
        "kind": "ReplicationController",
        "metadata": {
            "name": "rc-example"
        },
        ...
}
```

It's up to the operator to ensure that manually-specified service ports do not conflict between applications.


## Usage

```
    usage: deploy.sh options

    This script does a thing in a place.

    Required arguments:
       -h      Show this message
       -s      Server hostname / IP
       -p      Server port
       -t      Server authentication token.  Authentication: Bearer <ProvidedToken>
       -a      Action to perform. audit|create|delete|reset
       -e      Target environment / application
```

**-s - Server**

The IP or Hostname of the remote host.  Can also be provided via the `KUBE_DEPLOY_SERVER` environmental variable

**-p - Port**

The port upon which to contact the remote host.  Can also be provided via the `KUBE_DEPLOY_PORT` environmental variable

**-t - Token**

An authentication token for the remote host.  This value must be set, but in the case of unauthenticated access, can simply be set to a bogus value.  
Can also be provided via the `KUBE_DEPLOY_TOKEN` environmental variable

**-a - Action**

The action to perform against the remote host.  Any one of audit, create, update, delete, reset; Detailed below.

**-e - Environment**

The environment, or namespace, in which to perform the action.  This parameter must correspond to a directory name in the `./apps` folder.



### deploy.sh -e <env> -a audit

This command calls the API to retrieve services, replicationcontrollers, endpoints, pods, and events for the namespace, as well as the node list.

Output is printed to the console.


### deploy.sh -e <env> -a create

This command reads the contents of prefixed-json files in the same working directory and pushes them to the API.

These JSON files can contain either JSON or YAML (though only files with the json suffix will be read), which is simply POSTed to the kube master to create new resources.  Errors are printed to the console, but an error creating a resource will not impact the exit code meaningfully.  Most often you'll see errors if a nodePort on a new service has a conflict with an existing service in a different namespace.

`<namespace>.json` - this is a namespace definition file

`svc-*.json` - for services

`rc-*.json` - for replication controllers

`endpoint-*.json` - for endpoints


### deploy.sh -e <env> -a update

This command updates the replicationControllers and Endpoints definitions **only**.

Service updates require some sort of versioning that is beyond the level of sophistication 
for what a reasonable person might implement in a bash script, so they have been excluded.

Endpoints definitions updates haven't been tested, but I presume that you can change an ExternalIP
using this method.

Caveat for ReplicationController updates:  Changes to the container spec do not modify running 
containers, and the RC logic assumes that _any_ running container that matches that ReplicationController
satisfies the conditions of said RC.  

The recommendation for updating a pod spec is to create a new RC with the new spec and to modify the 
`replicas` value to retire the old RC.  This is what `kubectl migrate` does.


### deploy.sh -e <env> -a delete

Deletes the namespace for the environment. 
This will stop all running containers and delete all existing resources.


### deploy.sh -e <env> -a reset

Runs delete, waits five second, then runs create.


