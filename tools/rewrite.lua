local lfs = require('lfs')
local pf = require('pl.file')
local yaml = require('wowapi.yaml')

local function apiRewriter(fn)
  for filename in lfs.dir('data/api') do
    if filename:sub(-5) == '.yaml' then
      local api = yaml.parseFile('data/api/' .. filename)
      local newapi = fn(api)
      if newapi then
        pf.write('data/api/' .. filename, yaml.pprint(newapi))
      end
    end
  end
end

local function uiobjectRewriter(fn)
  for d in lfs.dir('data/uiobjects') do
    if d ~= '.' and d ~= '..' then
      local filename = ('data/uiobjects/%s/%s.yaml'):format(d, d)
      local cfg = yaml.parseFile(filename)
      local newcfg = fn(cfg)
      if newcfg then
        pf.write(filename, yaml.pprint(newcfg))
      end
    end
  end
end

local function xmlRewriter(fn)
  for filename in lfs.dir('data/xml') do
    if filename:sub(-5) == '.yaml' then
      local xml = yaml.parseFile('data/xml/' .. filename)
      local newxml = fn(xml)
      if newxml then
        pf.write('data/xml/' .. filename, yaml.pprint(newxml))
      end
    end
  end
end

return {
  api = apiRewriter,
  uiobject = uiobjectRewriter,
  xml = xmlRewriter,
}
