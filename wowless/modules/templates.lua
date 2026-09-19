return function(log)
  local templates = {}

  local function GetTemplateOrThrow(name)
    local t = templates[name:lower()]
    if not t then
      error('unknown template ' .. name)
    end
    return t
  end

  local function computeSize(template)
    local width, height
    for _, inh in ipairs(template.inherits or {}) do
      local w, h = computeSize(GetTemplateOrThrow(inh))
      if w then
        width = w
      end
      if h then
        height = h
      end
    end
    for _, kid in ipairs(template.elem.kids) do
      if kid.type:lower() == 'size' then
        local dim = kid.kids[#kid.kids]
        local x = kid.attr.x or (dim and dim.attr.x)
        local y = kid.attr.y or (dim and dim.attr.y)
        if x then
          width = x
        end
        if y then
          height = y
        end
      end
    end
    return width, height
  end

  local function GetTemplateInfo(name)
    local t = templates[name:lower()]
    if t then
      local width, height = computeSize(t)
      return {
        height = height or 0,
        inherits = t.inherits and table.concat(t.inherits, ','),
        keyValues = {},
        sourceLocation = 'source',
        type = t.type,
        width = width or 0,
      }
    end
  end

  local function SetTemplate(name, template)
    local lname = name:lower()
    if templates[lname] then
      log(1, 'overwriting template %s', name)
    end
    log(3, 'creating template %s', name)
    templates[lname] = template
  end

  return {
    GetTemplateInfo = GetTemplateInfo,
    GetTemplateOrThrow = GetTemplateOrThrow,
    SetTemplate = SetTemplate,
  }
end
