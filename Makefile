.POSIX:
.PHONY: *

env ?= dev

export KUBECONFIG = $(shell pwd)/cluster/kubeconfig-${env}.yaml

default: infra cluster system platform apps

infra:
	make -C infra env=${env}

cluster:
	make -C cluster env=${env}

system:
	sops exec-env ./secrets/common.enc.yaml 'timoni bundle apply --runtime-from-env --file system/addons.cue'

platform:
	sops exec-env ./secrets/common.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/vpn.cue'
	sops exec-env ./secrets/common.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/sso.cue'
	sops exec-env ./secrets/common.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/cicd.cue'

apps:
	sops exec-env ./secrets/common.enc.yaml 'timoni bundle apply --runtime-from-env --file apps/blog.cue'
	sops exec-env ./secrets/common.enc.yaml 'timoni bundle apply --runtime-from-env --file apps/homelab-docs.cue'
