return {
  constructor = function(self)
    u(self).childrenList = {}
    u(self).childrenSet = {}
    u(self).forbidden = false
  end,
  inherits = {'UIObject'},
  mixin = {
    GetDebugName = UNIMPLEMENTED,
    GetParent = function(self)
      return u(self).parent
    end,
    IsForbidden = function(self)
      return u(self).forbidden
    end,
    SetForbidden = function(self)
      u(self).forbidden = true
    end,
  },
}
