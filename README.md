# wowless

A headless WoW client Lua and FrameXML interpreter. Intended for addon testing.

Wowless is still pre-alpha. If you run your addon through it, if it outputs any
errors, those errors are almost certainly still in Wowless, not your addon. That
said, Wowless is undergoing active development. If you're interested, join the
Discord at <https://discord.gg/rTwWcfJXuz>.

Development is currently only supported via Docker.

Using VSCode:
Use `Clone Repository in Container Volume...`, select this repository to clone,
and then watch as VSCode builds a container and installs all necessary dependencies.

Using Docker Compose:

```sh
cp .env.dist .env
docker-compose up -d
docker-compose exec wowless bash
```

Running on WoW client Lua/XML code requires some additional steps.
From inside the container:

```sh
git submodule update --init --depth 1
cmake --preset default
bin/run.sh wow
```

The above will:

* download WoW retail client Lua/XML interface code
* evaluate that code
* mess around with the frames created: click around, mouse over things, etc.

To run an addon through it, download it into the container, then run:

```sh
bin/run.sh wow --addondir path/to/your/AddonName
```
