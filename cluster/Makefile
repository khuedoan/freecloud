.POSIX:

env ?= dev

apply:
ifeq ($(env), prod)
	ansible-playbook \
		--inventory inventory.yml \
		--ask-vault-pass \
		main.yml
else
	k3d cluster start horus-dev || k3d cluster create --config k3d.yaml
	k3d kubeconfig get horus-dev > kubeconfig-${env}.yaml
endif
