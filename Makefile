.POSIX:

env ?= dev

export KUBECONFIG = $(shell pwd)/cluster/kubeconfig-${env}.yaml

.PHONY: default
default: infra cluster system platform apps hack

.PHONY: infra
infra:
	make -C infra env=${env}

.PHONY: cluster
cluster:
	make -C cluster env=${env}

.PHONY: system
system:
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file system/addons.cue'

.PHONY: platform
platform:
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/micropaas.cue'
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/vpn.cue'
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file platform/sso.cue'

.PHONY: apps
apps:
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file apps/blog.cue'
	sops exec-env ./secrets/${env}.enc.yaml 'timoni bundle apply --runtime-from-env --file apps/homelab-docs.cue'

.PHONY: hack
hack:
	sops exec-env ./secrets/${env}.enc.yaml 'cd hack && go run .'

# https://linkerd.io/2-edge/tasks/generate-certificates
secrets/certs/${env}/ca.key secrets/certs/${env}/ca.crt:
	mkdir -p secrets/certs/${env}
	step certificate create \
		root.linkerd.cluster.local \
		secrets/certs/${env}/ca.crt \
		secrets/certs/${env}/ca.key \
		--profile root-ca \
		--no-password \
		--insecure
secrets/certs/${env}/issuer.key secrets/certs/${env}/issuer.crt: secrets/certs/${env}/ca.key secrets/certs/${env}/ca.crt
	step certificate create \
		identity.linkerd.cluster.local \
		secrets/certs/${env}/issuer.crt \
		secrets/certs/${env}/issuer.key \
		--profile intermediate-ca \
		--not-after 8760h \
		--no-password \
		--insecure \
		--ca secrets/certs/${env}/ca.crt \
		--ca-key secrets/certs/${env}/ca.key
.PHONY: certs
certs: secrets/certs/${env}/ca.key secrets/certs/${env}/ca.crt secrets/certs/${env}/issuer.key secrets/certs/${env}/issuer.crt
	@sops --set '["linkerd_ca_key"] $(shell cat secrets/certs/${env}/ca.key | jq --raw-input --slurp .)' secrets/${env}.enc.yaml
	@sops --set '["linkerd_ca_crt"] $(shell cat secrets/certs/${env}/ca.crt | jq --raw-input --slurp .)' secrets/${env}.enc.yaml
	@sops --set '["linkerd_issuer_key"] $(shell cat secrets/certs/${env}/issuer.key | jq --raw-input --slurp .)' secrets/${env}.enc.yaml
	@sops --set '["linkerd_issuer_crt"] $(shell cat secrets/certs/${env}/issuer.crt | jq --raw-input --slurp .)' secrets/${env}.enc.yaml

.PHONY: fmt
fmt:
	tofu fmt --recursive
	cue fmt ./...
	cd hack && go fmt ./...
