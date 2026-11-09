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

[SHACL Core constraint components](https://www.w3.org/TR/shacl/#core-components)
