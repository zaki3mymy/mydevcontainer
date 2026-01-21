# devcontainer

## setup

- [Dev Container CLI](https://github.com/devcontainers/cli)
- [Podman](https://podman.io/)
- [npm](https://www.npmjs.com/)

```shell
npm install -g @devcontainers/CLI
devcontainer up --workspace-folder . --docker-path podman
devcontainer exec --workspace-folder . --docker-path podman bash
```
