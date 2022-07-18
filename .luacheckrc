read_globals = {
  'debug.gettime',
  'debug.newcfunction',
  'forceinsecure',
  'issecure',
  'issecurevariable',
  'loadstring_untainted',
  'scrub',
  'securecall',
  'strcmputf8i',
  'strconcat',
  'strjoin',
  'strlenutf8',
  'strsplit',
  'strtrim',
  'table.removemulti',
  'table.wipe',
}
files['addon/Wowless'] = {
  read_globals = {
    'abs',
    'C_CovenantSanctumUI',
    'CreateFrame',
    'debugprofilestop',
    'DevTools_Dump',
    'format',
    'GetBuildInfo',
    'IsTestBuild',
    'RequestTimePlayed',
    'SendSystemMessage',
    'WOW_PROJECT_BURNING_CRUSADE_CLASSIC',
    'WOW_PROJECT_CLASSIC',
    'WOW_PROJECT_ID',
    'WOW_PROJECT_MAINLINE',
  },
}
files['addon/Wowless/global_*'] = {
  max_line_length = false,
}
-- TODO remove this when it is no longer necessary
files['data/uiobjects'] = {
  read_globals = {
    'api',
    'kids',
    'm',
    'toTexture',
    'u',
    'UpdateVisible',
  },
}
