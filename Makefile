.POSIX:
.PHONY: *

default: infra cluster

infra:
	make -C infra

cluster:
	make -C cluster
	kubectl create secret generic sops-age \
		--namespace=argocd \
		--from-file=age.agekey=.secrets/age.agekey
