local mixin = require('wowless.util').mixin

local function preprocess(tree)
  local newtree = {}
  for k, v in pairs(tree) do
    local attrs = mixin({}, v.attributes)
    local kids = {}
    for _, kid in ipairs(v.children or {}) do
      kids[kid:lower()] = true
    end
    local supertypes = { [k:lower()] = true }
    local text = v.text
    local t = v
    while t.extends do
      supertypes[t.extends:lower()] = true
      t = tree[t.extends]
      mixin(attrs, t.attributes)
      for _, kid in ipairs(t.children or {}) do
        kids[kid:lower()] = true
      end
      text = text or t.text
    end
    newtree[k:lower()] = mixin({}, v, {
      attributes = attrs,
      children = kids,
      supertypes = supertypes,
      text = text,
    })
  end
  return newtree
end

local lang = preprocess(require('wowapi.data').xml)

local attrBasedElementMT = {
  __index = (function()
    local fields = {
      attr = true,
      kids = true,
      line = true,
      text = true,
      type = true,
    }
    return function(_, k)
      assert(fields[k], 'invalid table key ' .. k)
    end
  end)(),
  __metatable = 'attrBasedElementMT',
  __newindex = function()
    error('cannot add fields')
  end,
}

local attrMTs = (function()
  local result = {}
  for name, spec in pairs(lang) do
    -- TODO be more defensive in loader.lua and remove these
    local attrs = {
      inherits = true,
      intrinsic = true,
      mixin = true,
      name = true,
      securemixin = true,
      text = true,
      virtual = true,
    }
    for attr in pairs(spec.attributes) do
      attrs[attr] = true
    end
    result[name] = {
      __index = function(_, k)
        assert(attrs[k], 'invalid table key ' .. k)
      end,
      __metatable = 'attrMT:' .. name,
      __newindex = function()
        error('cannot add fields')
      end,
    }
  end
  return result
end)()

local attributeTypes = {
  bool = function(s)
    local x = string.lower(s)
    if x == 'true' then
      return true
    elseif x == 'false' then
      return false
    else
      return nil
    end
  end,
  number = function(s)
    return tonumber(s)
  end,
  string = function(s)
    return s
  end,
  stringlist = function(s)
    local result = {}
    for part in string.gmatch(s, '[^, ]+') do
      table.insert(result, part)
    end
    return result
  end,
}

local function parseRoot(_, root)
  local warnings = {}
  local function run(e, tn, tk)
    assert(e._type == 'ELEMENT', 'invalid xml type ' .. e._type .. ' on child of ' .. tn)
    local tname = string.lower(e._name)
    local ty = lang[tname]
    assert(ty, tname .. ' is not a type')
    assert(not ty.virtual, tname .. ' is virtual and cannot be instantiated')
    local extends = false
    for k in pairs(tk) do
      extends = extends or ty.supertypes[k]
    end
    if not extends then
      table.insert(warnings, tname .. ' cannot be a child of ' .. tn)
      return nil
    end
    local resultAttrs = {}
    for k, v in pairs(e._attr or {}) do
      local an = string.lower(k)
      local attr = ty.attributes[an]
      if not attr then
        table.insert(warnings, 'attribute ' .. k .. ' is not supported by ' .. tname)
      else
        local vv = attributeTypes[attr.type](v)
        if vv == nil then
          table.insert(warnings, 'attribute ' .. k .. ' has invalid value ' .. v)
        else
          resultAttrs[an] = vv
        end
      end
    end
    if ty.text then
      assert(e._children, 'missing text in ' .. tname)
      local texts = {}
      local line
      for _, kid in ipairs(e._children) do
        assert(kid._type == 'TEXT', 'invalid xml type ' .. kid._type .. ' on ' .. tname)
        table.insert(texts, kid._text)
        line = line or kid._line
      end
      return setmetatable({
        attr = setmetatable(resultAttrs, attrMTs[tname]),
        kids = {},
        line = line,
        text = #texts > 0 and table.concat(texts, '\n') or nil,
        type = tname,
      }, attrBasedElementMT)
    else
      local resultKids = {}
      for _, kid in ipairs(e._children or {}) do
        if kid._type == 'TEXT' then
          table.insert(warnings, 'ignoring text kid of ' .. tname)
        else
          local newkid = run(kid, tname, ty.children)
          if newkid then
            table.insert(resultKids, newkid)
          end
        end
      end
      return setmetatable({
        attr = setmetatable(resultAttrs, attrMTs[tname]),
        kids = resultKids,
        type = tname,
      }, attrBasedElementMT)
    end
  end
  local result = run(root, 'toplevel', {
    bindings = true,
    ui = true,
  })
  return result, warnings
end

-- Simulates xml2lua dom output via luaexpat.
local function xml2dom(xmlstr)
  local stack = { { _children = {} } }
  local parser = require('lxp').new({
    CharacterData = function(p, text)
      table.insert(stack[#stack]._children, {
        _line = p:pos() - select(2, text:gsub('\n', '')),
        _text = text,
        _type = 'TEXT',
      })
    end,
    EndElement = function()
      table.remove(stack)
    end,
    StartElement = function(_, name, attrs)
      local t = {
        _attr = attrs,
        _children = {},
        _name = name,
        _type = 'ELEMENT',
      }
      table.insert(stack[#stack]._children, t)
      table.insert(stack, t)
    end,
  })
  parser:parse(xmlstr)
  parser:close()
  return stack[1]._children[1]
end

return {
  newParser = function()
    return {
      parse = function(self, xmlstr)
        return parseRoot(self, xml2dom(xmlstr))
      end,
    }
  end,
}
