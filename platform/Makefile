.POSIX:
.PHONY: *

env ?= dev

export KUBECONFIG = $(shell pwd)/../cluster/kubeconfig-${env}.yaml

default: apply

# TODO DRY
apply:
	sops exec-env ../secrets.enc.yaml 'timoni bundle apply --runtime-from-env --file sso.cue'
	sops exec-env ../secrets.enc.yaml 'timoni bundle apply --runtime-from-env --file cicd.cue'
	sops exec-env ../secrets.enc.yaml 'timoni bundle apply --runtime-from-env --file vpn.cue'
