# Kong LuaRocks Builder Image

This repository builds a Docker image that can be used as an **initContainer** in a Kong deployment (for example, via the official Helm chart).
The purpose is to install LuaRocks dependencies and build third-party Kong plugins without having to modify the base Kong image.

## Background

Kong supports plugins written in Lua. Many community plugins (e.g. `kong-oidc`) depend on libraries distributed via [LuaRocks](https://luarocks.org).
Since the official Kong images often do not include development tools, this image can be used as an initContainer that:

- includes **luarocks**,
- provides **git** (required for rocks hosted on GitHub),
- writes dependencies into a shared volume (`/opt/rocks`), which the main Kong container then consumes.

## How it works

1. The initContainer runs before Kong and installs the required rocks, for example:
   ```bash
   luarocks install --tree=/opt/rocks lua-resty-openidc
   luarocks install --tree=/opt/rocks kong-oidc
   ```
2. Dependencies are placed into a shared `emptyDir` volume mounted at `/opt/rocks`.
3. The Kong container is configured with:
   ```yaml
   env:
     KONG_LUA_PACKAGE_PATH: "/opt/rocks/share/lua/5.1/?.lua;/opt/rocks/share/lua/5.1/?/init.lua;;"
     KONG_LUA_PACKAGE_CPATH: "/opt/rocks/lib/lua/5.1/?.so;;"
   ```
   so plugins can `require` their dependencies.

## Example in Helm values.yaml

```yaml
deployment:
  userDefinedVolumes:
    - name: shared-rocks
      emptyDir: {}
  userDefinedVolumeMounts:
    - name: shared-rocks
      mountPath: /opt/rocks

  initContainers:
    - name: install-luarocks
      image: ghcr.io/<org-or-user>/kong-luarocks-builder:latest
      env:
        - name: HOME
          value: /opt/rocks
      command: ["/bin/sh","-lc"]
      args:
        - |
          set -eux
          mkdir -p /opt/rocks
          luarocks install --tree=/opt/rocks kong-oidc
      volumeMounts:
        - { name: shared-rocks, mountPath: /opt/rocks }
```

## Build

Build locally:

```bash
make build
```

---

### Why this image?

- Ensures **git** is available for rocks pulled from Git repositories.
- Can be reused across multiple Kong deployments without modifying the official Kong image.