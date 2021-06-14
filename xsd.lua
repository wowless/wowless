local handler = require('xmlhandler.dom')
local xml2lua = require('xml2lua')

local function topLevel()
  return 'k', 'v'
end

local function loadXmlString(str)
  local h = handler:new()
  h.options.commentNode = false
  xml2lua.parser(h):parse(str)
  assert(h.root, 'missing root')
  assert(h.root._name == 'schema', 'wrong root')
  local result = {}
  for _, kid in ipairs(h.root._children) do
    local k, v = topLevel(kid)
    result[k] = v
  end
  return result
end

return {
  loadXmlString = loadXmlString,
}
