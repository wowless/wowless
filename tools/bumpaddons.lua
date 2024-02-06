local function fix(addon)
  local p = io.popen(([[
    gh api graphql -f query='query {
      repository(owner: "%s", name: "%s") {
        releases(first: 1) { nodes { tagName } }
      }
    }' --jq .data.repository.releases.nodes[].tagName
  ]]):format(addon.owner, addon.repo))
  addon.tag = p:read('*a'):sub(1, -2)
  p:close()
end
local addons = require('wowapi.yaml').parseFile('tools/addons.yaml')
if arg[1] then
  fix(assert(addons[arg[1]]))
else
  for _, v in pairs(addons) do
    fix(v)
  end
end
require('pl.file').write('tools/addons.yaml', require('wowapi.yaml').pprint(addons))
