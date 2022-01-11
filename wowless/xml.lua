local mixin = require('wowless.util').mixin

local function preprocess(tree)
  local newtree = {}
  for k, v in pairs(tree) do
    local attrs = mixin({}, v.attributes)
    local fields = mixin({}, v.fields)
    local kids = mixin({}, v.children)
    local supertypes = { [k] = true }
    local text = v.text
    local t = v
    while t.extends do
      supertypes[t.extends] = true
      t = tree[t.extends]
      mixin(attrs, t.attributes)
      mixin(fields, t.fields)
      mixin(kids, t.children)
      text = text or t.text
    end
    newtree[k] = mixin({}, v, {
      attributes = attrs,
      children = kids,
      fields = fields,
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

local fieldBasedElementMTs = (function()
  local result = {}
  for name, spec in pairs(lang) do
    if next(spec.fields) then
      local fields = {}
      for field in pairs(spec.fields) do
        fields[field] = true
      end
      if spec.text then
        fields.text = true
      end
      result[name] = {
        __index = function(_, k)
          assert(fields[k], 'invalid table key ' .. k)
        end,
        __metatable = 'fieldBasedElementMT:' .. name,
        __newindex = function()
          error('cannot add fields')
        end,
      }
    end
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

local function validateRoot(root)
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
    if next(ty.fields) then
      assert(not next(ty.attributes), 'attributes and fields in ' .. tname)
      assert(not next(ty.children), 'children and fields in ' .. tname)
      local fields = { type = tname }
      local fieldAttrs = {}
      for name, spec in pairs(ty.fields) do
        if spec.source == 'attribute' then
          local aname = spec.attribute or name
          fieldAttrs[aname] = true
          local attr = nil
          for k, v in pairs(e._attr or {}) do
            if string.lower(k) == aname then
              assert(attr == nil, 'duplicate attributes for ' .. aname .. ' in ' .. tname)
              attr = v
            end
          end
          assert(spec.value == nil or attr == spec.value, 'bad attribute value ' .. tostring(attr) .. ' in ' .. tname)
          assert(not spec.required or attr ~= nil, 'missing attribute ' .. aname .. ' in ' .. tname)
          if attr and spec.value == nil then
            assert(spec.type, 'missing type on attribute field ' .. name .. ' of ' .. tname)
            fields[name] = attributeTypes[spec.type](attr)
          end
        elseif spec.source == 'child' then
          local cname = spec.child or name
          local kids = {}
          for _, kid in ipairs(e._children) do
            if kid._name then
              local kty = lang[string.lower(kid._name)]
              assert(kty, 'unknown tag ' .. kid._name)
              if kty.supertypes[cname] then
                local newkid = run(kid, tname, { [cname] = true })
                if newkid then
                  table.insert(kids, newkid)
                end
              end
            end
          end
          assert(not spec.required or #kids > 0, 'missing required child ' .. cname .. ' of ' .. tname)
          assert(spec.repeated or #kids <= 1, 'too many instances of child ' .. cname .. ' of ' .. tname)
          fields[name] = spec.repeated and kids or #kids and kids[1] or nil
        else
          error('invalid spec source ' .. spec.source .. ' in ' .. tname)
        end
      end
      if ty.text then
        local texts = {}
        local line
        for _, kid in ipairs(e._children) do
          assert(kid._type == 'TEXT', 'invalid xml type ' .. kid._type .. ' on ' .. tname)
          table.insert(texts, kid._text)
          line = line or kid._line
        end
        fields.line = line
        fields.text = #texts > 0 and table.concat(texts, '\n') or nil
      end
      for k in pairs(e._attr or {}) do
        if not fieldAttrs[string.lower(k)] then
          table.insert(warnings, 'attribute ' .. k .. ' is not supported by ' .. tname)
        end
      end
      return setmetatable(fields, fieldBasedElementMTs[tname])
    else
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
          attr = resultAttrs,
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
          attr = resultAttrs,
          kids = resultKids,
          type = tname,
        }, attrBasedElementMT)
      end
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

local function validate(xmlstr)
  return validateRoot(xml2dom(xmlstr))
end

return {
  validate = validate,
}
