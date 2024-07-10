.POSIX:
.PHONY: *

env ?= dev

export KUBECONFIG = $(shell pwd)/../cluster/kubeconfig-${env}.yaml

default: apply

apply:
	timoni bundle apply --file gitops.cue

diff:
	timoni bundle apply --file gitops.cue --dry-run --diff
