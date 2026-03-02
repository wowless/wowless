local pprintYaml = require('wowapi.yaml').pprint
local schema = require('wowapi.yaml').parseFile('data/schemas/doctable.yaml').type
local validate = require('wowapi.schema').validate

local mixmt = {
  __index = function()
    return function() end
  end,
}
local nummt = {
  __index = function()
    return 42
  end,
}
local nsmt = {
  __index = function()
    return setmetatable({}, nummt)
  end,
}

local function runDocChunk(product, docs, f, fn)
  local success, err = pcall(setfenv(fn, {
    APIDocumentation = {
      AddDocumentationTable = function(_, t)
        assert(xpcall(validate, pprintYaml, product, schema, t))
        docs[f] = t
      end,
    },
    Constants = setmetatable({}, nsmt),
    CreateFromMixins = function()
      return setmetatable({}, mixmt)
    end,
    Enum = setmetatable({}, nsmt),
  }))
  if not success then
    error(('error loading %s: %s'):format(f, err), 0) -- issue #551
  end
end

return {
  runDocChunk = runDocChunk,
}
