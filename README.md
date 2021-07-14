# wowless
A headless WoW client Lua and FrameXML interpreter. Intended for addon testing.

```sh
$ git clone --recurse-submodules https://github.com/ferronn-dev/wowless
$ cd wowless
$ bin/setup.sh
$ bin/run.sh
```

The above will:
* set up a local Lua environment
* install wowless dependencies in that environment
* use [wowcig] to download WoW client Lua/XML interface code
* for each client:
  * load the code, just like a WoW client would
  * mess around with the frames created: click around, mouse over things, etc.

The loading and testing work for Classic and Classic Era, but do not yet work for Retail. To see the litany of errors caused by Retail, run `bin/try.sh 0 wow`, and then help fix the resulting issues!

[wowcig]: https://github.com/ferronn-dev/wowcig
