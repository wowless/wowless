local topLevel = (function()
  local tags = {
    complexType = function()
      return 'complexType', 'moo'
    end,
    element = function()
      return 'element', 'moo'
    end,
    simpleType = function(e)
      assert(e._attr and e._attr.name, 'missing simpleType name')
      assert(#e._children == 1, 'wrong number of simpleType kids')
      local kid = e._children[1]
      assert(kid._name == 'xs:restriction', 'wrong simpleType kid type')
      assert(kid._attr, 'simpleType kid missing attributes')
      local base = kid._attr.base
      assert(base and base:sub(1, 3) == 'xs:', 'malformed simpleType restriction ' .. base)
      local types = {
        float = true,
        int = true,
        NMTOKEN = true,
      }
      local type = base:sub(4)
      assert(types[type], 'unknown simpleType restriction data type ' .. type)
      return e._attr.name, type
    end,
  }
  return function(e)
    assert(e._name and e._name:sub(1, 3) == 'xs:', 'malformed tag ' .. tostring(e._name))
    local tag = e._name:sub(4)
    local handler = tags[tag]
    assert(handler, 'unknown tag ' .. tag)
    return handler(e)
  end
end)()

local loadXmlString = (function()
  local handler = require('xmlhandler.dom')
  local xml2lua = require('xml2lua')
  return function(str)
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
end)()

local filename = ...
if filename then
  local file = assert(require('io').open(filename, 'r'))
  local data = file:read('*all')
  file:close()
  for k, v in pairs(loadXmlString(data)) do
    print(k .. ' = ' .. v)
  end
end

return {
  loadXmlString = loadXmlString,
}
