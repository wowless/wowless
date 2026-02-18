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

The test target rebuilds changed sources then runs `build/cmake/runtests`.
A successful run exits with code 0 and produces no output. Tests are also
run by the `build and test` pre-commit hook, so they execute automatically
on every commit.

Tests are in `spec/` directory and use luassert. Test specs are defined in
CMakeLists.txt around line 985. The test addon in `addon/Wowless/` contains
in-game tests that run inside the simulated WoW environment during `runtests`.

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

### Test Addon Structure (`addon/Wowless/`)

The test addon runs inside the simulated WoW environment. Files load in
`.toc` order:

- `util.lua`: Assertion helpers (`assertEquals`, `check0`–`check7`, `match`,
  `retn`) stored on the addon table `G`
- `statemachine.lua`: `checkStateMachine(states, transitions, init)` for
  exhaustive state machine testing via BFS traversal of all edge combinations
- `init.lua`: Sets up `G.testsuite = {}` and `_G.assertEquals`
- `framework.lua`: Test runner iterator; walks nested tables depth-first,
  collecting sub-tests returned from test functions
- Per-domain test files (`uiobjects.lua`, `luaobjects.lua`, `test.lua`,
  etc.): Each adds an entry to `G.testsuite` (e.g.,
  `G.testsuite.uiobjects = function() ... end`)
- `test.lua`: Runs all sync tests via `G.tests()` iterator on `OnUpdate`,
  budgeted per frame. Also defines async tests (timers, events) that use
  a `done(check)` callback pattern. Results go to `_G.WowlessTestFailures`.

#### Writing tests

- Test functions return a table of named sub-tests (keys = names,
  values = functions) for hierarchical organization. Sub-tests can
  themselves return tables for further nesting.
- Use `assertEquals(expected, actual)` for assertions
- Use `checkN(e1, ..., eN, ...)` to assert both return count and values
- Use `match(k, e1..ek, a1..ak)` to return a table of individual value
  checks (useful as sub-tests)
- Use `retn(n, ...)` to assert return count and pass values through
- Check C functions with `assertEquals(false, pcall(coroutine.create, fn))`
- Use `checkStateMachine` when testing objects with multiple states and
  transitions (buttons, visibility, rects, event registration)
- Guard wowless-only or real-client-only tests with
  `if _G.__wowless then return end`
- Pre-compute data tables outside test functions when iterating `WowlessData`
- Keep test modules focused on type-specific behavior

### C Stubs for API Typechecking

Eligible global API stubs (no `impl`, no outputs, string/number inputs only)
are generated as native C functions rather than Lua closures. See issue #523
for the full migration plan.

- `wowless/typecheck.h`: Inline helpers for input checking
  (`wowless_stubchecknumber`, `wowless_stubchecknilablenumber`,
  `wowless_stubcheckstring`, `wowless_stubchecknilablestring`)
- `prep.lua` emits a per-product `generated/${product}_stubs.c` when
  `--coutput` is passed; eligible APIs are marked `cstub=true` in the data
- CMakeLists wires the generated C file into `datalua_${product}` via
  `target_sources` and registers it as a cmodule (`build.products.X.stubs=c`)
  in the `lua2c()` call
- `apiloader.lua` loads `build.products.<product>.stubs` and uses the C
  function directly (no `bubblewrap`) for `cstub`-flagged APIs
- To add a C-provided module to a `lua2c()` target, use `modulename=c` in
  the argument list and add the C source with `target_sources`

### Data Format Conventions

- Use sets (tables with `key = true`) for collections like method names,
  not arrays
- gentest.lua and prep.lua should produce consistent data formats for the
  same concepts
- Iterate sets with `pairs()`, not `ipairs()`
- API input parameters with a `default` field are implicitly nilable (accept
  nil/missing arguments); use the nilable typecheck variant for them

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

## GitHub Issues

- Add the `claude` label to any issues you create
- Add a `-- issue #nnn` comment to the line of Lua code most relevant to the
  issue

## Commit Message Style

- Prefix with module name and colon when changes are localized:
  `luaobjects: description`
- Keep messages concise (no period at end)
