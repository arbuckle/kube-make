# Copyright David Arbuckle 2015
# MIT Licensed

all:

NAMESPACE = medusa
KUBE_MASTER = http://localhost:8080/api/v1


audit:
	# Prints a complete record of all the artifacts in a namespace
	sh audit.sh $(NAMESPACE) $(KUBE_MASTER)

delete:
	# Deletes everything in the namespace
	sh delete.sh $(NAMESPACE) $(KUBE_MASTER)

create:
	# Pushes all of the configs in the colocated files to the namespace
	sh create.sh $(NAMESPACE) $(KUBE_MASTER)

reset: delete create
	# deletes, then pushes

