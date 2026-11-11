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

# Validate against all of exercises/ at once, save the report, and query it:
# the report is RDF too.
.PHONY: report
report:
	shacl validate $(foreach f,$(wildcard exercises/*.ttl),--shapes $(f)) --data data.ttl > report.ttl
	arq --data report.ttl --query queries/report-by-component.rq
	arq --data report.ttl --query queries/report-by-node.rq

# The ShEx version of a dog shape.
.PHONY: shex
shex:
	shex validate --schema shex/dog.shex --map shex/dogs.shapemap --data data.ttl --text
