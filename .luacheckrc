read_globals = {
  'debug.getfunctionstats',
  'debug.getglobalstats',
  'debug.gettime',
  'debug.newcfunction',
  'debug.newsecurefunction',
  'debug.setnewclosuretaint',
  'debug.setprofilingenabled',
  'forceinsecure',
  'issecure',
  'issecurevariable',
  'loadstring_untainted',
  'scrub',
  'securecall',
  'secureexecuterange',
  'seterrorhandler',
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
    'CreateFont',
    'CreateFrame',
    'debugprofilestop',
    'DevTools_Dump',
    'format',
    'GetBuildInfo',
    'IsTestBuild',
    'RequestTimePlayed',
    'SendSystemMessage',
  },
}
-- TODO remove this when it is no longer necessary
files['data/uiobjects'] = {
  read_globals = {
    'api',
    'toTexture',
  },
}
