local mixin = require('wowless.util').mixin

local function dispatch(t, u, ...)
  if type(u) == 'string' then
    return assert(t[u], u)(...)
  else
    local uk, uv = next(u)
    assert(next(u, uk) == nil, uk)
    return assert(t[uk], uk)(uv, ...)
  end
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
    StartElement = function(p, name, attrs)
      local t = {
        _attr = attrs,
        _children = {},
        _line = (p:pos()),
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

return function(datalua, eventqueue)
  local QueueEvent = eventqueue.QueueEvent
  local lang = datalua.xmlflat
  local stringenums = datalua.stringenums
  local enums = datalua.globals.Enum
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
    enum = function(name, s)
      local set = enums[name]
      return set[s]
    end,
    number = function(s)
      return tonumber(s)
    end,
    string = function(s)
      return s
    end,
    stringenum = function(name, s)
      local set = stringenums[name]
      local upper = s:upper()
      return set[upper] and upper or nil
    end,
    stringlist = function(s)
      local result = {}
      for part in string.gmatch(s, '[^, ]+') do
        table.insert(result, part)
      end
      return result
    end,
  }

  local function parseRoot(root, intrinsics, snapshot, warningPath)
    local warnings = {}
    -- A real client keeps descending into an unrecognized element's
    -- children and attributes rather than dropping the whole subtree
    -- silently, flagging each one individually too.
    local function warnUnrecognized(e)
      QueueEvent('LUA_WARNING', ('%s:%d Unrecognized XML: %s'):format(warningPath, e._line, e._name))
      for _, k in ipairs(e._attr) do
        QueueEvent('LUA_WARNING', ('%s:%d Unrecognized XML attribute: %s'):format(warningPath, e._line, k))
      end
      for _, kid in ipairs(e._children or {}) do
        if kid._type == 'ELEMENT' then
          warnUnrecognized(kid)
        end
      end
    end
    local function run(e, tn, tk)
      if e._type ~= 'ELEMENT' then
        error('invalid xml type ' .. e._type .. ' on child of ' .. tn)
      end
      local tname = string.lower(e._name)
      local ty = lang[tname] or snapshot[tname]
      if not ty then
        warnUnrecognized(e)
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
          local vv = dispatch(attributeTypes, attr, v)
          if vv == nil then
            if ty.warnsinvalid[an] then
              QueueEvent(
                'LUA_WARNING',
                ('%s:%d %s %s: Invalid %s value: %s'):format(warningPath, e._line, e._name, e._name, k, v)
              )
            end
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
          line = e._line,
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

  local intrinsics = {}
  return function(xmlstr, warningPath)
    local snapshot = {}
    for k, v in pairs(intrinsics) do
      snapshot[k] = v
    end
    return parseRoot(xml2dom(xmlstr), intrinsics, snapshot, warningPath)
  end
end
