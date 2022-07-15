# wowless

A headless WoW client Lua and FrameXML interpreter. Intended for addon testing.

Development is easiest with VSCode and Docker.
Use `Clone Repository in Container Volume...`, select this repository to clone,
and then watch as VSCode builds a container and installs all necessary dependencies.

Running on WoW client Lua/XML code requires some additional steps.
From inside the container:

```sh
bin/wowcig.sh
bin/run.sh --product wow
```

The above will:

* use [wowcig] to download WoW client Lua/XML interface code
* load WoW retail FrameXML
* mess around with the frames created: click around, mouse over things, etc.

[wowcig]: https://github.com/lua-wow-tools/wowcig
