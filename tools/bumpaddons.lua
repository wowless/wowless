local addons = require('wowapi.yaml').parseFile('tools/addons.yaml')
for _, v in pairs(addons) do
  local p = io.popen(([[
    gh api graphql -f query='query {
      repository(owner: "%s", name: "%s") {
        releases(first: 1) { nodes { tagName } }
      }
    }' --jq .data.repository.releases.nodes[].tagName
  ]]):format(v.owner, v.repo))
  v.tag = p:read('*a'):sub(1, -2)
  p:close()
end
require('pl.file').write('tools/addons.yaml', require('wowapi.yaml').pprint(addons))
