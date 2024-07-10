.POSIX:
.PHONY: *

env ?= dev

export KUBECONFIG = $(shell pwd)/../cluster/kubeconfig-${env}.yaml

default: apply

# TODO DRY
apply:
	timoni bundle apply --file cicd.cue

diff:
	timoni bundle apply --file cicd.cue --dry-run --diff
