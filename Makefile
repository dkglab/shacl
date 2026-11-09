SHELL := /usr/bin/env bash

.PHONY: validate

# shacl is Jena's, on the PATH in the devcontainer image
# (ghcr.io/dkglab/shacl-and-owl-dev, built from dkglab/shacl-and-owl).
validate:
	shacl validate --shapes shapes.ttl --data data.ttl

# Allemang's account example (Semantic Web for the Working Ontologist, ch. 7).
.PHONY: accounts
accounts:
	shacl validate --shapes accounts/shapes.ttl --data accounts/data.ttl
