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

[SHACL Core constraint components](https://www.w3.org/TR/shacl/#core-components)

[SHACL-SPARQL](https://www.w3.org/TR/shacl/#sparql-constraints) ·
[ShEx primer](https://shex.io/shex-primer/)
