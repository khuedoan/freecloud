.POSIX:
.PHONY: *

env ?= dev

export KUBECONFIG = $(shell pwd)/../cluster/kubeconfig-${env}.yaml

default: apply

# TODO DRY
apply:
	sops exec-env ../secrets.enc.yaml 'timoni bundle apply --runtime-from-env --file cicd.cue'
