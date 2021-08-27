require('wowless.runner').run({
  loglevel = arg[1] and tonumber(arg[1]) or 0,
  dir = 'extracts/' .. (arg[2] or 'wow_classic') .. '/Interface',
  version = arg[3] or 'TBC',
  otherAddonDirs = { arg[4] },
})
