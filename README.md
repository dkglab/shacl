# SHACL

Open this repository in a codespace. The devcontainer image has Jena's
`shacl` command on the PATH. To validate [`data.ttl`](data.ttl) using
[`shapes.ttl`](shapes.ttl):

```text
make validate
```

`data.ttl` is the dogs graph, the same 109 triples as the `dogs` dataset on
<https://sparql-datasets.fly.dev>.

`make accounts` validates the account example from Allemang, Hendler and
Gandon, ch. 7 ([`accounts/`](accounts/)).

The shapes in [`exercises/`](exercises/) are from the 10 Nov handout. Run one with

```text
shacl validate --shapes exercises/1-sex.ttl --data data.ttl
```

The shapes in [`more-shapes/`](more-shapes/) are from the 12 Nov class:
combining shapes with `sh:node` and `sh:or`, a closed shape, a constraint
written in SPARQL (SHACL-SPARQL), and one that looks as if it needs SPARQL
but doesn't. Run one with

```text
shacl validate --shapes more-shapes/own-ancestor.ttl --data data.ttl
```

A validation report is RDF, so it can be queried. `make report` validates
the data against all the exercise shapes at once, saves the report as
`report.ttl`, and runs the queries in [`queries/`](queries/) on it.

[`shex/dog.shex`](shex/dog.shex) is a dog shape in ShEx, the other shapes
language. `make shex` checks every dog against it.

## Inference and validation together (17 Nov)

[`rules/`](rules/) holds EYE rules for RDFS and for OWL's inverse,
symmetric and transitive properties, the same rules as the SHACL and OWL
assignment's.

- `make after-inference` validates `data.ttl` against
  [`inference/mother-is-a-dog.ttl`](inference/mother-is-a-dog.ttl), then
  validates it again with what RDFS infers from
  [`inference/vocab.ttl`](inference/vocab.ttl). Delete Elisa's `a ex:Dog`
  first to see a difference.
- `make object-property`: add `ex:louie ex:mother "Puddles" .` to
  `data.ttl`, then see what a reasoner makes of it when `ex:mother` is an
  `owl:ObjectProperty`, and what
  [`more-shapes/mother-is-an-iri.ttl`](more-shapes/mother-is-an-iri.ttl)
  makes of it.
- [`more-shapes/dog-form.ttl`](more-shapes/dog-form.ttl) is a shape with
  `sh:name` and `sh:order`, which a tool could turn into a form.
- [`more-shapes/sibling-rule.ttl`](more-shapes/sibling-rule.ttl) is a SHACL
  rule. Jena doesn't run rules, so `make siblings` runs its CONSTRUCT.
- [`skos/`](skos/) has eight Library of Congress Subject Headings
  ([`lcsh.ttl`](skos/lcsh.ttl)) and part of SKOS's own definition
  ([`skos.ttl`](skos/skos.ttl)). `make skos` shows what follows from them
  and checks the handout's predictions; `make skos-validate` checks two SKOS
  rules written as shapes ([`shapes.ttl`](skos/shapes.ttl)), before and
  after inference.

Run `git checkout data.ttl` between these, so one demo's edit doesn't
carry into the next.

[SHACL Core constraint components](https://www.w3.org/TR/shacl/#core-components)

[SHACL-SPARQL](https://www.w3.org/TR/shacl/#sparql-constraints) ·
[ShEx primer](https://shex.io/shex-primer/)
