return function()
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

  return {
    GetTemplateInfo = GetTemplateInfo,
    templates = templates,
  }
end
