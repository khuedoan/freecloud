.POSIX:
.PHONY: *

env ?= dev

default: infra cluster system

infra:
	make -C infra env=${env}

cluster:
	make -C cluster env=${env}

system:
	make -C system env=${env}
