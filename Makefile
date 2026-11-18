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

# 17 Nov: inference and validation together ---------------------------------
#
# Inference is by EYE with the rules in rules/ (RDFS, plus OWL's inverse,
# symmetric and transitive properties), the same rules as the SHACL and OWL
# assignment's. Not riot --rdfs, which mishandles rdfs:subPropertyOf.
EYE := eye --quiet --nope
RULES := $(sort $(wildcard rules/*.n3))

# What RDFS infers from data.ttl with inference/vocab.ttl.
inferred.ttl: $(RULES) inference/vocab.ttl data.ttl
	$(EYE) $^ --pass-only-new 2> /dev/null | riot --syntax=ttl --formatted=ttl - > $@

data-inferred.nt: data.ttl inferred.ttl
	riot --quiet --output=nt $^ > $@

# Validate before and after inference. Delete Elisa's `a ex:Dog` from
# data.ttl first to see the difference (and git checkout data.ttl after).
.PHONY: after-inference
after-inference: data-inferred.nt
	@echo "== data.ttl"
	@shacl validate --shapes inference/mother-is-a-dog.ttl --data data.ttl --text
	@echo "== data.ttl plus inferred.ttl"
	@shacl validate --shapes inference/mother-is-a-dog.ttl --data $< --text

# Is ex:louie ex:mother "Puddles" an error? Add that triple to data.ttl,
# then ask a reasoner (with ex:mother an owl:ObjectProperty) and a shape.
.PHONY: object-property
object-property:
	@echo "== The reasoner infers:"
	@$(EYE) $(RULES) inference/object-property.ttl data.ttl --pass-only-new; \
	  echo "(exit status $$?: 0 means no contradiction)"
	@echo "== The shape reports:"
	@shacl validate --shapes more-shapes/mother-is-an-iri.ttl --data data.ttl --text

# The CONSTRUCT behind more-shapes/sibling-rule.ttl, a SHACL rule.
.PHONY: siblings
siblings:
	arq --data data.ttl --query queries/siblings.rq

# SKOS: eight Library of Congress Subject Headings, and what SKOS's own
# definition lets a reasoner infer about them.
skos/inferred.ttl: $(RULES) skos/skos.ttl skos/lcsh.ttl
	$(EYE) $^ --pass-only-new 2> /dev/null | riot --syntax=ttl --formatted=ttl - > $@

skos/lcsh-inferred.nt: skos/lcsh.ttl skos/inferred.ttl
	riot --quiet --output=nt $^ > $@

.PHONY: skos
skos: skos/inferred.ttl skos/lcsh-inferred.nt
	cat skos/inferred.ttl
	arq --data skos/lcsh-inferred.nt --query skos/predictions.rq

# Two SKOS integrity conditions as shapes, before and after inference.
# Add lcsh:sh98004876 skos:related lcsh:sh85038796 . to skos/lcsh.ttl first.
.PHONY: skos-validate
skos-validate: skos/lcsh-inferred.nt
	@echo "== skos/lcsh.ttl"
	@shacl validate --shapes skos/shapes.ttl --data skos/lcsh.ttl --text
	@echo "== skos/lcsh.ttl plus skos/inferred.ttl"
	@shacl validate --shapes skos/shapes.ttl --data $< --text

# 12 Nov: shapes as queries --------------------------------------------------
#
# Each queries/twin-*.rq is a SPARQL query meant to find the same focus nodes
# as one constraint in exercises/. make twins runs each query on data.ttl and
# compares its ?this column with the focus nodes that constraint's component
# flags in the shape's validation report. twin-3-mother-wrong.rq is meant to
# disagree: it checks only the sexes that are there.

twins/%.report.ttl: exercises/%.ttl data.ttl
	@mkdir -p twins
	shacl validate --shapes $< --data data.ttl > $@

# $(call twin,query,exercise,constraint component)
define twin
@if diff <(arq --data data.ttl --query $(1) --results=TSV | tail -n +2 | cut -f1 | sort -u) \
         <(arq --data twins/$(2).report.ttl --query queries/focus-nodes.rq --results=TSV \
           | awk -F'\t' '$$1 == "<http://www.w3.org/ns/shacl#$(3)>" { print $$2 }' | sort -u) \
         > twins/diff; \
  then echo "same       $(1)  =  $(2) sh:$(3)  ($$(arq --data data.ttl --query $(1) --results=TSV | tail -n +2 | wc -l) focus nodes)"; \
  else echo "DIFFERENT  $(1)  ≠  $(2) sh:$(3)  (< query only, > shape only)"; sed -n 's/^\([<>]\)/             \1/p' twins/diff; \
  fi
endef

.PHONY: twins
twins: twins/1-sex.report.ttl twins/2-color.report.ttl twins/4-mothers.report.ttl
	$(call twin,queries/twin-1-sex-in.rq,1-sex,InConstraintComponent)
	$(call twin,queries/twin-1-sex-mincount.rq,1-sex,MinCountConstraintComponent)
	$(call twin,queries/twin-2-color.rq,2-color,MaxCountConstraintComponent)
	$(call twin,queries/twin-2-color-count.rq,2-color,MaxCountConstraintComponent)
	$(call twin,queries/twin-3-mother.rq,4-mothers,HasValueConstraintComponent)
	$(call twin,queries/twin-3-mother-wrong.rq,4-mothers,HasValueConstraintComponent)
