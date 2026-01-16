# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

Wowless is a headless World of Warcraft client Lua and FrameXML interpreter
intended for addon testing. It interprets WoW's client Lua code and XML UI
definitions without requiring the actual game client.

## Build Commands

Development is primarily done via Docker (devcontainer). Native builds are
also supported.

### Native Build

```sh
git submodule update --init --depth 1
cmake --preset default
cmake --build --preset default
```

Build output goes to `build/cmake/`.

### Running Wowless

```sh
# Build and run on retail WoW
bin/run.sh wow

# Run with an addon
bin/run.sh wow --addondir path/to/YourAddon

# Run directly after building
build/cmake/wowless run -p wow [options]
```

Products: `wow`, `wowt`, `wowxptr`, `wow_beta`, `wow_classic`,
`wow_classic_beta`, `wow_classic_era`, `wow_classic_era_ptr`, `wow_classic_ptr`

### Running Tests

```sh
cmake --build --preset default --target test
```

Tests are in `spec/` directory and use luassert. Test specs are defined in
CMakeLists.txt around line 985.

### Linting and Formatting

Pre-commit hooks handle linting. Key tools:

- **luacheck**: Lua linting (config in `.luacheckrc`)
- **stylua**: Lua formatting (config in `stylua.toml`)
- **clang-format**: C formatting (config in `.clang-format`)
- **yamlfmt**: YAML formatting (`build/cmake/yamlfmt`)

```sh
pre-commit run -a  # Run all checks
```

## Architecture

### Core Runtime (`wowless/`)

- `wowless.lua`: Entry point, parses CLI args and invokes runner
- `runner.lua`: Orchestrates WoW environment simulation (login, events, scripts)
- `modules.lua`: Dependency injection system loading modules from
  `wowless/modules/`
- `modules/`: Individual modules (api, events, loader, security, uiobjects, etc.)

### Module System

Modules are defined in `data/modules.yaml` with explicit dependencies. The
runtime loads them via topological sort. Each module in `wowless/modules/`
receives its dependencies as function arguments.

### Data Layer (`data/`)

YAML files define WoW API specifications, converted to Lua at build time:

- `data/products/<product>/`: Per-product API definitions (apis, events,
  uiobjects, etc.)
- `data/schemas/`: JSON-schema-like definitions for YAML validation
- `data/impl.yaml`, `data/uiobjectimpl.yaml`: Stub implementations

### Tools (`tools/`)

Build-time code generators:

- `gentest.lua`: Generates test addon code
- `prep.lua`: Preprocesses product data
- `docs.lua`: Documentation generator
- `yaml2lua.lua`/`lua2yaml.lua`: Format converters

### Test Addon (`addon/Wowless/`)

In-game test addon that runs within the simulated WoW environment to verify
API behavior.

### C Extensions

- `vendor/elune/`: Custom Lua 5.1 fork with WoW-specific extensions (taint
  tracking, security)
- `wowless/*.c`: Native Lua extensions (sqlite, mixin, bubblewrap, ext)

### External Data (`vendor/`)

- `vendor/dbdefs/`: WoW database definitions
- `vendor/tactless/`: CASC file extraction library

## Key Patterns

### Lua-to-C Compilation

The `lua2c()` CMake function compiles Lua modules into C for static linking.
This bundles all Lua code into the final executables.

### Product-Specific Data

Each WoW product (retail, classic, beta, etc.) has its own data directory
under `data/products/<product>/` with API definitions that may differ between
game versions.

### Security Model

Wowless implements WoW's taint/security system via elune extensions. Framework
code runs "secure" while addon code is "tainted".

### Userdata Objects

WoW exposes several userdata types (luaobjects, funtainers, uiobjects).
Key patterns:

- Use `newproxy(true)` to create userdata with custom metatables
- `__metatable = false` hides the real metatable from `getmetatable()`
- `bubblewrap()` wraps Lua functions to appear as C functions (fails
  `coroutine.create`)
- Methods should be readonly (error on assignment via `__newindex`)
- Custom fields stored in per-instance tables accessed via `__index`/`__newindex`
- `__tostring` format: `"TypeName: 0x..."` (use `tostring(table):sub(8)`
  for address)

### Test Addon Patterns

Test addon files in `addon/Wowless/` use a nested table structure for test
organization:

- Return tables from test functions for sub-tests
- Use `assertEquals(expected, actual)` for assertions
- Check C functions with `assertEquals(false, pcall(coroutine.create, fn))`
- Pre-compute data tables outside test functions when iterating `WowlessData`
- Test both branches of conditional behavior (e.g., when config flags affect
  output)
- Keep test modules focused on type-specific behavior; move generic tests to
  shared utilities
- Use short variable names like `cfg` for config objects

### Data Format Conventions

- Use sets (tables with `key = true`) for collections like method names,
  not arrays
- gentest.lua and prep.lua should produce consistent data formats for the
  same concepts
- Iterate sets with `pairs()`, not `ipairs()`

### Deferred Type Loading

UIObjects and luaobjects use a deferred loading pattern:

- Type registries (`uiobjecttypes`, `luaobjects`) are initialized at module
  load with empty state
- Loader methods (`uiobjectloader(modules)`, `luaobjects.LoadTypes(modules)`)
  process type definitions
- `runner.lua` invokes loaders inside `withglobaltable()` after sandbox
  environment is set up
- This allows type initialization to access the full module graph via the
  `modules` parameter

### Module Delegate Pattern for C_ APIs

When modules export WoW C_ style functions (like `C_FunctionContainers.CreateCallback`):

- Define the function locally with the second part as the name (e.g.,
  `CreateCallback`)
- Export with simple table assignment: `CreateCallback = CreateCallback`
- In `impl.yaml`, use `moduledelegate` with explicit `function` field mapping
  to the local name:

  ```yaml
  C_FunctionContainers.CreateCallback:
    moduledelegate:
      function: CreateCallback
      name: funtainer
  ```

- The `moduledelegate` handler in `prep.lua` generates `return (...)[%q]`
  which does direct table lookup

### impl.yaml Implementation Types

- `stdlib`: Maps to Lua standard library function
- `impl`: Inline implementation with optional `modules` and `sqls` dependencies
- `moduledelegate`: Delegates to a module function (use `function` field for
  non-default name)
- `directsql`: Simple SQL query wrapper
- `luadelegate`: Delegates to a separate Lua module file

## Commit Message Style

- Prefix with module name and colon when changes are localized:
  `luaobjects: description`
- Keep messages concise (no period at end)
