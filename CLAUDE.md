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

Build output goes to `build/`.

### Running Wowless

```sh
# Build and run on retail WoW
bin/run.sh wow

# Run with an addon
bin/run.sh wow --addondir path/to/YourAddon

# Run directly after building
build/wowless run -p wow [options]
```

Prefer `bin/run.sh <product>` over invoking `build/wowless` directly: it
builds both `wowless_<product>` (the product-specific binary) and the
`<product>` target, which pulls the `<product>_data.sqlite3` fetch chain.
Running the generic `build/wowless` binary skips those data dependencies
and can fail with "no such table" if fetch hasn't run. In a worktree,
`cmake --build --preset default --target wowless_<product> <product>` then
`build/wowless_<product> run -p <product>` is the equivalent.

Products: see `data/products.yaml`

### Running Tests

```sh
cmake --build --preset default --target test
```

The test target rebuilds changed sources then runs `build/runtests`.
A successful run exits with code 0 and produces no output. Tests are also
run by the `build and test` pre-commit hook, so they execute automatically
on every commit.

Tests are in `spec/` directory and use luassert. Test specs are defined in
CMakeLists.txt around line 985. The test addon in `addon/Wowless/` contains
in-game tests that run inside the simulated WoW environment during `runtests`.

### Build and Test Gotchas

- **Submodules do not auto-update on pull/rebase.** After any `git pull` or
  `git rebase` that brings in new commits, run `git submodule update` (e.g.
  `git submodule update vendor/dbdefs`) before building. Submodule pointers
  move via commits like "bump wowt to X.Y.Z"; a stale `vendor/dbdefs`
  checkout surfaces as a confusing, seemingly-unrelated data error (e.g.
  `cannot find <version> in dbd FactionGroup`) that looks like a bug in
  your change.
- **`build/extracts/<product>/` is not a dependency of the `test` target.**
  The raw game-client files `tools/fetch.lua` pulls (e.g.
  `Blizzard_SharedXML/UI.xsd`, `Blizzard_APIDocumentation*`) are only
  fetched/consumed by the `docs-<product>` / `docs-all` targets. A green
  `--target test` run does not exercise `tools/docs.lua`; run
  `docs-<product>` (or `docs-all`) and check `git status` on the files it
  writes to actually verify a `tools/docs.lua` change. Populating extracts
  needs network access, but the expensive part — the CASC download — is
  cached at user level by tactless and shared across every checkout, so a
  fresh worktree re-extracts cheaply rather than re-downloading. Don't
  `cp -r` extracts between checkouts.
- **Never run system `lua`/`luajit` against this repo's code or data.** The
  project vendors its own Lua 5.1 fork (`vendor/elune/`) with WoW taint
  extensions and its own module path baked into the CMake-built tooling. A
  system interpreter is a different runtime without the project's modules,
  so nothing "confirmed" through it is trustworthy. For ad hoc data
  inspection use Python (`pyyaml` is available) or `grep`/`awk`; for
  anything that must execute in the real environment use the project's
  build/test targets or the `tools/*.lua` entry points as CMake invokes
  them.
- **Do not chain multiple `git commit` calls in one shell invocation.** The
  `build and test` pre-commit hook reruns the full build+test on *every*
  commit (several commits can exceed a command timeout) and stashes other
  unstaged files to `~/.cache/pre-commit/patch<ts>-<pid>` for the duration.
  If the shell is killed mid-hook, a later commit's stash-restore may never
  run and that file silently reverts to HEAD. Commit one logical change per
  shell call; after any interrupted commit, check `git status` and diff
  your edited files before continuing.
- **"Full eval" means build the `outs` target and confirm the output files
  are empty.** Non-empty output is a regression to investigate. Only run it
  when explicitly asked, not as a routine post-change check.

### Linting and Formatting

Pre-commit hooks handle linting. Key tools:

- **luacheck**: Lua linting (config in `.luacheckrc`)
- **stylua**: Lua formatting (config in `stylua.toml`)
- **clang-format**: C formatting (config in `.clang-format`)
- **yamlfmt**: YAML formatting (`build/yamlfmt`)

```sh
pre-commit run -a  # Run all checks
```

Do not modify `.luacheckrc` to silence a warning. If luacheck flags an
undefined global in new code, reference it as `_G.SomeGlobal` (which its
static analysis does not flag) rather than adding to `read_globals`.

### C Code Style

clang-format handles most C formatting. One rule it cannot enforce:

- Multiline block comments must have the opening `/*` on its own line with no
  text after it:

  ```c
  /* wrong: text on the opening line
   * more text
   */

  /*
   * correct: /* is alone on its line
   * more text
   */
  ```

  Single-line comments (`/* text */`) are unaffected by this rule.

## Architecture

### Core Runtime (`wowless/`)

- `wowless.lua`: Entry point, parses CLI args and invokes runner
- `runner.lua`: Orchestrates WoW environment simulation (login, events, scripts)
- `modules.lua`: Dependency injection system loading modules from
  `wowless/modules/`
- `modules/`: Individual modules (api, events, loader, security, uiobjects,
  etc.)

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
- Custom fields stored in per-instance tables accessed via
  `__index`/`__newindex`
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

### Spec Tests (`spec/`)

luassert/busted unit tests, separate from the in-game addon tests.

- **`spec/wowless/modules/X_spec.lua` corresponds 1:1 with
  `wowless/modules/X.lua`.** One spec file per runtime module, named to
  match. Never add a second spec file for the same module (e.g.
  `X_containment_spec.lua`) no matter how different the new cases feel —
  add a `describe` block inside the existing spec instead.
- **`spec/data/schema_coverage_spec.lua` enforces YAGNI at the schema
  level.** It asserts every field path in `data/schemas/*.yaml` is
  exercised by at least one real data file across all products. Add a new
  schema field only in the same commit that populates it in real data,
  even when the pattern "obviously" generalizes.
- **Table-driven style for repeated near-identical `it()` blocks:** one
  table of named cases, then a single
  `for name, case in pairs(cases) do it(name, ...) end` loop. Use named
  fields (`case.value`), not positional indices. Assert the whole return
  value with one `assert.same` rather than per-key checks. A table
  constructor silently drops a key whose value is literal `nil`, so wrap
  nil cases as `{ value = nil }`. Reference: `spec/addon/util_spec.lua`,
  `spec/tools/xmlcontainment_spec.lua`.
- **Never assert only not-nil.** Assert the actual expected value. The one
  exception is output that is nondeterministic by the implementation's own
  documented contract (e.g. `pairs()` iteration order) — pull that case
  out of the loop and assert membership in the valid set.

### C Stubs for API Typechecking

Eligible global API stubs are generated as native C functions rather than Lua
closures. An API is eligible if it has no `impl` and all input/output types
are supported. `is_eligible` in `prep.lua` hard-errors on unsupported types.

**Supported input types:** `boolean`, `enum`, `FileAsset` (as string),
`function`, `number`, `string`, `stringenum`, `structure`, `table`,
`luaobject`, `uiobject`, `unit`, `unknown`, `arrayof`.

**Supported output types:** `boolean`, `enum`, `FileAsset` (returns `1`),
`function`, `nil`, `number`, `oneornil`, `string`, `stringenum`, `structure`,
`table`, `unit`, `unknown`, `luaobject`, `uiobject`, `arrayof`.

Key files:

- `wowless/typecheck.h`: Inline helpers for each supported type, both nilable
  and non-nilable variants (e.g., `wowless_stubchecknumber`,
  `wowless_stubchecknilablestringenum`). Complex types (luaobject, uiobject,
  stringenum) call into the `cgencode` upvalue.
- `wowless/stubs.h`/`stubs.c`: Loading infrastructure; `wowless_load_stubs()`
  registers C functions as closures with the `cgencode` module as upvalue.
- `wowless/modules/cgencode.lua`: Runtime helper module passed as upvalue to
  C stubs. Provides `CheckStringEnum`, `IsLuaObject`, `IsUiObject`,
  `CreateLuaObject`, `CreateUiObject`.
- `prep.lua` emits a per-product `generated/${product}_stubs.c` when
  `--coutput` is passed; eligible APIs are marked `cstub=true` in the data.
- CMakeLists wires the generated C file into `datalua_${product}` via
  `target_sources` and registers it as a cmodule (`build.products.X.stubs=c`)
  in the `lua2c()` call.
- `wowless/modules/cstubs.lua` requires `build.products.<product>.stubs`
  (the generated C module). `env.lua` calls `modules.cstubs.load(modules)`
  to populate the global environment with all API stubs.
- To add a C-provided module to a `lua2c()` target, use `modulename=c` in
  the argument list and add the C source with `target_sources`.

### YAML Parser (`wowapi/cyaml.c`)

The project uses a custom C YAML parser with a few nonstandard behaviors to
be aware of when reading or writing data files:

- **Scalars**: plain `true`/`false` → Lua boolean; numeric strings → Lua
  number; everything else (including quoted strings) → Lua string.
- **Null values**: a key with no value (`key:`) does **not** produce Lua `nil`.
  It hits the parser's default case and produces an empty table `{}`. This is
  intentional and used as a sentinel to distinguish "field absent" (Lua `nil`
  from table lookup) from "field present with no value" (empty table `{}`).
  For example, `data/types.yaml` uses `c_output:` (no value) to mark types
  that output nil from C stubs, and `default:` (no value) to mark types whose
  default output is an empty table.
- **Empty tables**: when round-tripping through `pprint`, an empty Lua table
  is emitted as a bare empty scalar (zero-length plain scalar), which parses
  back as an empty table.

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

### XML / FrameXML Notes

- **`UI.xsd` is a reference for `xml.yaml`, not the source of truth.** It
  stands to `xml.yaml` roughly as the `Blizzard_APIDocumentation` addons
  stand to the files `docs.lua` generates: upstream documentation that
  `xml.yaml` should ideally track — including a `docs.yaml`-style layer for
  where the schema, like the API docs, is simply wrong about the client.
  The client's own behavior is always the real authority. `xml.yaml` is
  hand-maintained today, so when it disagrees with observed FrameXML, weigh
  the XSD and real client behavior rather than assuming either file is
  right. Blizzard ships it per-product at
  `build/extracts/<product>/Interface/AddOns/Blizzard_SharedXML/UI.xsd`
  (~1600 lines), under the main checkout's `build/`.
- **Virtual templates are valid only at top level, directly under `<Ui>`.**
  A tag can be a top-level virtual template only if it (or something in its
  substitution-group chain) reaches `substitutionGroup="UiField"` *and* its
  own XSD complexType declares `name`/`virtual` attributes. Both must hold.
- **Child widgets need a wrapper tag.** `<Frame>`'s valid direct children
  are limited (`Animations`/`Attributes`/`Frames`/`HitRectInsets`/`Layers`/
  `ResizeBounds`). A child frame-type widget goes inside `<Frames>`;
  `FontString`/`Texture` regions go inside `<Layers><Layer>`. A bare child
  widget is not valid.
- **A rejected child element is dropped, not errored.** `wowless/modules/
  xml.lua` records it in a `warnings` list returned to `xmleval.lua` and
  logged only at `loglevel >= 3`. Schema tags flagged `containmentwarnings`
  (currently just `Ui`) additionally emit a real `LUA_WARNING` for a
  rejected direct child; `spec/wowless/modules/xml_spec.lua`'s "every tag
  as a child of Ui" sweep covers the accept/reject relation against
  `xmlcontainment.legalChildren`.
- **`xml.lua` parses the whole document structurally before `xmleval.lua`
  evaluates any of it.** So every parse-phase `LUA_WARNING` (structural
  rejections, invalid attribute values) fires before *any* evaluation-phase
  one, regardless of the two tags' relative position in the XML text.

### LUA_WARNING Delivery Model

- All `LUA_WARNING`s are queued and delivered next-frame, after other
  same-frame queued events (via a dedicated queue drained after the general
  `eventqueue`). Nothing fires inline.
- XML-parse-time warnings stage in `xmlwarningqueue` and dump into the main
  warning queue once per frame, before it drains. Warnings from an actual
  Lua call (`CreateFrame`, `bindScript`) enqueue directly, bypassing XML
  staging.
- **Hard cap of 100 `LUA_WARNING`s per frame** (client-verified); excess is
  silently dropped, shared across all sources. A test that can produce more
  than 100 warnings in one frame must paginate across real frame boundaries
  (e.g. `LoadOnDemand` addons paced with `C_Timer.After(0, ...)`).
- Sites: `wowless/modules/warningqueue.lua`, `xmlwarningqueue.lua`,
  `api.lua`, `xmleval.lua`, `errorhandler.lua`, `mainloop.lua` (which runs
  `DrainEvents()` → `xmlwarningqueue.Dump()` → `warningqueue.DrainWarnings()`
  → `Advance`). Get real-client confirmation before changing ordering here —
  this subsystem has needed real-client corrections twice.

### Generated Code

- Generated Lua is a DI-instantiated chunk created by a thin shim module in
  the `data/modules.yaml` graph (the cstubs pattern), receiving exactly what
  it needs. Pass bare state tables (`{ bindings = {} }`, callers manipulate
  it directly), not accessor pairs. Drop unused parameters from generated
  signatures. Helpers a generated chunk needs can live in the shim module
  itself rather than getting their own module.
- Do not add new generated `WowlessData/<name>.lua` files (gentest.lua
  `ptablemap` entries) just to hand the addon precomputed data if the addon
  can compute it from existing tables (`WowlessData.Xml`,
  `WowlessData.UIObjectApis`). If a new generated file really is needed, ask
  first.
- `tools/generatexmltest.lua` (and similar Lua-table-to-XML generators):
  build each dynamic node with an inline IIFE that constructs and returns
  the complete tag table including its own `tag` field. No named helper
  functions, no `unpack()` splicing.

### Module Delegate Pattern for C_ APIs

When modules export WoW C_ style functions (like
`C_FunctionContainers.CreateCallback`):

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

## GitHub Issues and PRs

- Add the `claude` label to any issues you create
- Add the `claude` label to any PRs you create
- Add a `-- issue #nnn` comment to the line of Lua code most relevant to the
  issue

### Git / PR Workflow

- **Sync the primary checkout to `origin/main` at the start of every
  session** (fetch + fast-forward/reset). Local changes should never
  persist there between sessions; work happens in ephemeral worktrees,
  which already branch from `origin/main`.
- **`git fetch origin main` before *every* `git worktree add ... origin/main`
  or `git rebase origin/main`,** including mid-session. Merging a PR via
  `gh pr merge` does *not* update the local `refs/remotes/origin/main`; a
  stale local ref silently branches/rebases from the wrong commit with no
  error.
- **Rebase a feature branch onto latest `origin/main` before every push** —
  the first push that opens the PR and every force-push after. Rebuild and
  rerun tests after rebasing. After rebasing onto history that includes an
  upstream rename, grep your branch's own new lines for the old name — a
  clean rebase does not catch a rename that never shares a line with your
  new code.
- Pushing a branch auto-opens a PR against `main`. Just call `gh pr create`;
  on "already exists" fall back to `gh pr edit` / `gh pr ready <n> --undo`.
- **Merging:** squash only, always
  `gh pr merge <n> --squash -b "<summary>"` — the `-b` summary is
  mandatory, written before assembling the command, medium/high-level
  (not a transcript of the review), and ending with the `Co-Authored-By:`
  trailer. Then immediately, as the next command,
  `git push origin --delete <branch>`, then remove the worktree. Leaving
  the branch lets GitHub auto-open a duplicate PR.
- **"Merge on green" means poll CI to success first** (`gh pr view <n>
  --json statusCheckRollup` or `gh run watch`). This repo has no branch
  protection, so `gh pr merge --auto` merges immediately without waiting.
- Merge authorization is per-PR, per-request. A "merge on green" for one PR
  does not authorize merging a later or related one.
- `git worktree remove` refuses on any worktree containing submodules —
  needs `--force` (a second `--force` only for locked worktrees).

## Testing After Code Changes

Always run tests after modifying code:

```sh
cmake --build --preset default --target test
```

A successful run exits with code 0 and produces no output. If tests fail,
fix the issues before considering the task complete.

## Commit Message Style

- Prefix with module name and colon when changes are localized:
  `luaobjects: description` (no period at end)
- Always add a `Co-Authored-By: <model name> <noreply@anthropic.com>` trailer
  using the actual model name (e.g., `Claude Sonnet 4.6`)
- Only confirmed facts in commit messages, PR descriptions, and code
  comments — no speculative explanations of behavior. Say "left for a
  follow-up investigation", not "probably means X". A comment reads as
  settled documentation and does not carry the uncertainty that produced
  it.

## Small-Scope Style

- A constant is worth naming only when reused non-trivially or the name
  adds real clarity; a single literal used once stays inline.
- For a "this should structurally never happen" branch, prefer
  `assert(invariant)` (loud, fails the build) over `if invariant then ...
  end` (silent skip). This codebase has been bitten by
  silently-skipped/dropped edge cases before.
