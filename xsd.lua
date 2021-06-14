local handler = require('xmlhandler.dom')
local xml2lua = require('xml2lua')

local UNIMPLEMENTED = function() end

local function topLevel(e)
  assert(e._name and e._name:sub(1, 3) == 'xs:', 'malformed tag ' .. tostring(e._name))
  local tag = e._name:sub(4)
  local tags = {
    complexType = UNIMPLEMENTED,
    element = UNIMPLEMENTED,
    simpleType = UNIMPLEMENTED,
  }
  assert(tags[tag], 'unknown tag ' .. tag)
  return 'k', 'v'
end

local function loadXmlString(str)
  local h = handler:new()
  h.options.commentNode = false
  xml2lua.parser(h):parse(str)
  assert(h.root, 'missing root')
  assert(h.root._name == 'xs:schema', 'wrong root')
  local result = {}
  for _, kid in ipairs(h.root._children) do
    local k, v = topLevel(kid)
    result[k] = v
  end
  return result
end

local filename = ...
if filename then
  local file = assert(require('io').open(filename, 'r'))
  local data = file:read('*all')
  file:close()
  loadXmlString(data)
end

return {
  loadXmlString = loadXmlString,
}
