read_globals = {
  'debug.gettime',
  'debug.newcfunction',
  'forceinsecure',
  'issecure',
  'issecurevariable',
  'loadstring_untainted',
  'scrub',
  'securecall',
}
files['addon/Wowless'] = {
  read_globals = {
    'C_CovenantSanctumUI',
    'CreateFrame',
    'debugprofilestop',
    'DevTools_Dump',
    'format',
    'SendSystemMessage',
    'WOW_PROJECT_ID',
    'WOW_PROJECT_MAINLINE',
  },
}
-- TODO remove this when it is no longer necessary
files['data/uiobjects'] = {
  read_globals = {
    'api',
    'kids',
    'm',
    'u',
    'UpdateVisible',
    'util',
  },
}
