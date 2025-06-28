local args
do
  local parser = require('argparse')()
  parser:argument('edit', 'edit.yaml')
  parser:argument('target', 'target.yaml'):args('*')
  args = parser:parse()
end

local tedit = require('tools.tedit')
local file = require('pl.file')
local yaml = require('wowapi.yaml')

local function readyaml(f)
  return yaml.parse(file.read(f))
end

local function writeyaml(f, t)
  file.write(f, yaml.pprint(t))
end

local edit = readyaml(args.edit)
for _, f in ipairs(args.target) do
  writeyaml(f, tedit(readyaml(f), edit))
end
