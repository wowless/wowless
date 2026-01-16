local plfile = require('pl.file')
local yaml = require('wowapi.yaml')
for _, fn in ipairs(arg) do
  local orig = plfile.read(fn)
  local formatted = yaml.pprint(yaml.parse(orig))
  if formatted == '\n' then
    formatted = '' -- hack for empty files to avoid fighting pre-commit
  end
  if formatted ~= orig then
    plfile.write(fn, formatted)
  end
end
