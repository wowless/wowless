# wowless

A headless WoW client Lua and FrameXML interpreter. Intended for addon testing.

To get started:

```sh
git clone https://github.com/lua-wow-tools/wowless
cd wowless
bin/setup.sh
bin/test.sh
bin/wowcig.sh
bin/run.sh --product wow
```

The above will:

* set up a local Lua environment
* install wowless dependencies in that environment
* verify that you have a working setup
* use [wowcig] to download WoW client Lua/XML interface code
* download and process `_G` extracts on wowless cloud storage
* load WoW retail FrameXML
* mess around with the frames created: click around, mouse over things, etc.

[wowcig]: https://github.com/lua-wow-tools/wowcig
