return function(log)
  local templates = {}

  local function GetTemplateInfo(name)
    local t = templates[name:lower()]
    if t then
      return {
        height = 1,
        inherits = t.inherits and table.concat(t.inherits, ','),
        keyValues = {},
        sourceLocation = 'source',
        type = t.type,
        width = 1,
      }
    end
  end

  local function GetTemplateOrThrow(name)
    local t = templates[name:lower()]
    if not t then
      error('unknown template ' .. name)
    end
    return t
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
