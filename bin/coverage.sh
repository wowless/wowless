#!/bin/sh
set -e
eval "$(.lua/bin/luarocks path)"
if [ -f luacov.stats.out ] && [ ! -f luacov.stats.out.orig ]; then
  echo 'moving luacov output to .orig'
  mv luacov.stats.out luacov.stats.out.orig
fi
if [ -f luacov.stats.out.orig ] && [ ! -f luacov.stats.out ]; then
  echo 'preprocessing luacov stats'
  .lua/bin/lua tools/precov.lua < luacov.stats.out.orig > luacov.stats.out
fi
if [ ! -f luacov.report.out ]; then
  echo 'producing luacov report'
  .lua/bin/luacov
fi
