local _, v = ...
-- TODO actually do the transformation
local out = { x = v.x, y = v.y, z = v.z }
return require('wowless.util').mixin(out, api.env.Vector3DMixin)
