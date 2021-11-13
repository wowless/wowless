return {
  constructor = function(self)
    u(self).animations = {}
  end,
  inherits = {'ParentedObject', 'ScriptObject'},
  mixin = {
    CreateAnimation = function(self, type)
      local ltype = (type or 'animation'):lower()
      assert(api.InheritsFrom(ltype, 'animation'))
      local anim = api.CreateUIObject(ltype)
      table.insert(u(self).animations, anim)
      return anim
    end,
    GetAnimations = function(self)
      return unpack(u(self).animations)
    end,
    IsPlaying = UNIMPLEMENTED,
    Play = UNIMPLEMENTED,
    SetLooping = UNIMPLEMENTED,
    SetToFinalAlpha = UNIMPLEMENTED,
    Stop = UNIMPLEMENTED,
  },
}
