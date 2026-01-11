## Roblox Luau project template

This repository is a starter template for a Roblox experience using:

- **Rojo** for filesystem-to-Roblox syncing/builds
- **pesde** (with Wally support) for dependency management
- **Darklua** for transforming `src/` into runtime-ready output in `out/`
- **StyLua** + **Selene** for formatting and linting
- **Zune** to run the automation scripts in `scripts/`

If you’re “creating a new project”, the main steps are: rename the template, install the tools, run sync in development, and run a build when you want an `.rbxlx`.

## Create a new project from this template

### 1) Rename the package

- **Update `pesde.toml`**:
  - `name` (e.g. `yourname/your-game`)
  - `version` (optional)
- **Update `default.project.json`**:
  - `name` (this is just the Rojo project name)

After changing `pesde.toml`, regenerate the lockfile by running `pesde install`.

### 2) Install toolchain

You’ll need the following tools available on your PATH:

- **Rokit** (installs pinned versions of Rojo, pesde, StyLua, Selene, Darklua): [Rokit](https://github.com/rojo-rbx/rokit)
- **Zune** (runs the scripts in `scripts/`): [Zune](https://github.com/Scythe-Technology/Zune)

Then install the pinned tools:

```bash
rokit install
```

Make sure the installed tools are on your PATH (the scripts expect `rojo`, `pesde`, `darklua`, `stylua`, and `selene` to be invokable). A common setup is to add `./.rokit/bin` to your shell PATH.

Install dependencies:

```bash
pesde install
```

## Common workflows

### Development sync (Studio)

This runs three watchers:
- Rojo sourcemap watcher
- Darklua transform watcher (`src/` -> `out/`)
- Rojo serve (to sync `out/` to Studio)

```bash
zune run scripts/sync.luau
```

Then connect Roblox Studio using the Rojo plugin (Rojo server is started by the script).

### Build an `.rbxlx`

```bash
zune run scripts/build.luau
```

This produces `game.rbxlx` in the repo root.

### Format + lint

```bash
zune run scripts/check.luau
```

## Project layout

- `src/`: source code (what you edit)
  - `src/client/`: client entrypoint(s) and UI/controllers
  - `src/server/`: server entrypoint(s) and services
  - `src/shared/`: shared modules/types/constants
- `out/`: Darklua output used for Rojo syncing
- `default.project.json`: Rojo project mapping for sourcemaps
- `build.project.json`: Rojo project mapping used for builds/serve
- `roblox_packages/`: Roblox-runtime dependencies (from pesde/Wally)
- `scripts/`: automation (build/sync/check)

## Example content

This template currently includes a sample “Pet Shop System” implementation; see `SHOP_README.md` for a walkthrough and file map.
