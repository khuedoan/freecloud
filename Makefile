.POSIX:
.PHONY: *

env ?= dev

export KUBECONFIG = $(shell pwd)/cluster/kubeconfig-${env}.yaml

default: infra cluster system platform apps hack

infra:
	make -C infra env=${env}

cluster:
	make -C cluster env=${env}

system:
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file system/addons.cue'

platform:
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/micropaas.cue'
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/vpn.cue'
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/sso.cue'

apps:
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file apps/blog.cue'
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file apps/homelab-docs.cue'

hack:
	sops exec-env ./secrets/${env}.enc.yaml 'cd hack && go run .'

fmt:
	tofu fmt --recursive
	cue fmt ./...
	cd hack && go fmt ./...
