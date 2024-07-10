.POSIX:
.PHONY: *

env ?= dev

export KUBECONFIG = $(shell pwd)/../cluster/kubeconfig-${env}.yaml

default: apply

# TODO DRY
apply:
	timoni bundle apply --file blog.cue

diff:
	timoni bundle apply --file blog.cue --dry-run --diff
