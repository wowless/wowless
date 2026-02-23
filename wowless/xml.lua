local mixin = require('wowless.util').mixin

local lang = setmetatable({}, {
  __index = function(t, k)
    local v = require('build.products.' .. k .. '.data').xmlflat
    t[k] = v
    return v
  end,
})

local attributeTypes = {
  boolean = function(s)
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
for k, v in pairs(require('runtime.stringenums')) do
  attributeTypes[k] = function(s)
    return v[s] and s or nil
  end
end

local function parseRoot(product, root, intrinsics, snapshot)
  local warnings = {}
  local function run(e, tn, tk)
    if e._type ~= 'ELEMENT' then
      error('invalid xml type ' .. e._type .. ' on child of ' .. tn)
    end
    local tname = string.lower(e._name)
    local ty = lang[product][tname] or snapshot[tname]
    if not ty then
      table.insert(warnings, 'unknown type ' .. tname)
      return nil
    end
    if ty.virtual then
      error(tname .. ' is virtual and cannot be instantiated')
    end
    local extends = false
    for k in pairs(tk) do
      extends = extends or ty.supertypes[k]
    end
    if not extends then
      table.insert(warnings, tname .. ' cannot be a child of ' .. tn)
      return nil
    end
    local resultAttrs = {}
    for _, k in ipairs(e._attr) do
      local an = string.lower(k)
      local attr = ty.attributes[an]
      if not attr then
        table.insert(warnings, 'attribute ' .. k .. ' is not supported by ' .. tname)
      else
        local v = e._attr[k]
        local vv = attributeTypes[attr](v)
        if vv == nil then
          table.insert(warnings, 'attribute ' .. k .. ' has invalid value ' .. v)
        else
          resultAttrs[an] = vv
        end
      end
    end
    if ty.text then
      if not e._children then
        error('missing text in ' .. tname)
      end
      local texts = {}
      local line
      for _, kid in ipairs(e._children) do
        if kid._type ~= 'TEXT' then
          error('invalid xml type ' .. kid._type .. ' on ' .. tname)
        end
        table.insert(texts, kid._text)
        line = line or kid._line
      end
      return {
        attr = resultAttrs,
        kids = {},
        line = line,
        name = e._name,
        text = #texts > 0 and table.concat(texts, '\n') or nil,
        type = tname,
      }
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
      if resultAttrs.intrinsic and resultAttrs.name then
        intrinsics[resultAttrs.name:lower()] = {
          attributes = ty.attributes,
          children = ty.children,
          supertypes = mixin({}, ty.supertypes, { tname = true }),
          text = ty.text,
        }
      end
      return {
        attr = resultAttrs,
        kids = resultKids,
        type = tname,
      }
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
  newParser = function(product)
    local intrinsics = {}
    return function(xmlstr)
      local snapshot = {}
      for k, v in pairs(intrinsics) do
        snapshot[k] = v
      end
      return parseRoot(product, xml2dom(xmlstr), intrinsics, snapshot)
    end
  end,
}
