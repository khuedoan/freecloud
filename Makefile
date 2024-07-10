.POSIX:
.PHONY: *

env ?= dev

default: infra cluster system platform apps

infra:
	make -C infra env=${env}

cluster:
	make -C cluster env=${env}

system:
	make -C system env=${env}

platform:
	make -C platform env=${env}

apps:
	make -C apps env=${env}
