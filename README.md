# wowless
A headless WoW client Lua and FrameXML interpreter. Intended for addon testing.

```sh
$ git clone https://github.com/lua-wow-tools/wowless
$ cd wowless
$ bin/setup.sh
$ bin/test.sh
```

The above will:
* set up a local Lua environment
* install wowless dependencies in that environment
* use [wowcig] to download WoW client Lua/XML interface code
* for each client:
  * load the code, just like a WoW client would
  * mess around with the frames created: click around, mouse over things, etc.

[wowcig]: https://github.com/lua-wow-tools/wowcig
