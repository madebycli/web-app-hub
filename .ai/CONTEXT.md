# AI Context Route

```yaml
schema_version: 1
context_repo: https://github.com/madebycli/master-context
project_id: web-app-hub
source_repo: https://github.com/madebycli/web-app-hub
context_root: projects/web-app-hub/
entrypoint: projects/web-app-hub/INDEX.md
```

## Mandatory AI behavior

Use this exact project route. Validate it against `REGISTRY.yaml`, read the declared entrypoint first, never guess sibling project paths, and use cross-project context only through explicit links or user instruction.
