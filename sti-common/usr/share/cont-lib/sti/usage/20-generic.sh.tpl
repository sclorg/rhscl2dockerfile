STI {{ name }} {{ platform }} image:
{{ '=' * (name|length + 12 + platform|length) }}

To use this STI docker image, install STI: https://github.com/openshift/source-to-image

Sample invocation:
------------------

```
sti build https://github.com/org/project.git --context-dir=path/to/application/ namespace/image-name application-name
```

