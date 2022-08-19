# wowless

A headless WoW client Lua and FrameXML interpreter. Intended for addon testing.

Wowless is still pre-alpha. If you're interested in Wowless development,
join the Discord at <https://discord.gg/rTwWcfJXuz>.

Development is easiest with VSCode and Docker.
Use `Clone Repository in Container Volume...`, select this repository to clone,
and then watch as VSCode builds a container and installs all necessary dependencies.

Running on WoW client Lua/XML code requires some additional steps.
From inside the container:

```sh
lua tools/fetch.sh wow
bin/run.sh --product wow
```

The above will:

* download WoW retail client Lua/XML interface code
* evaluate that code
* mess around with the frames created: click around, mouse over things, etc.
