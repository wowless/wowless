local infile = unpack(arg)
local buildinfo = (function()
  local env = {}
  setfenv(loadfile(infile), env)()
  return env.TheFlatDumperBuildInfo
end)()
local outfile = string.format('%s.%s.lua', buildinfo[1], buildinfo[2])
local outurl = 'gs://wow.ferronn.dev/gscrapes/' .. outfile
assert(os.execute(string.format('gsutil cp %q %s', infile, outurl)))
