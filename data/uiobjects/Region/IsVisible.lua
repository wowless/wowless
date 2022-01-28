local self = ...
local ud = u(self)
local p = ud.parent
return ud.shown and (not p or m(p, 'IsVisible'))
