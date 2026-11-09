SHELL := /usr/bin/env bash

.PHONY: validate

# shacl is Jena's, on the PATH in the devcontainer image
# (ghcr.io/dkglab/shacl-and-owl-dev, built from dkglab/shacl-and-owl).
validate:
	shacl validate --shapes shapes.ttl --data data.ttl
