.POSIX:
.PHONY: *

env ?= dev

export KUBECONFIG = $(shell pwd)/../cluster/kubeconfig-${env}.yaml

default: apply

# TODO DRY
apply:
	timoni bundle apply --file gitops.cue
	timoni bundle apply --file addons.cue

diff:
	timoni bundle apply --file gitops.cue --dry-run --diff
	timoni bundle apply --file addons.cue --dry-run --diff
