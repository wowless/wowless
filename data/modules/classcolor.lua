local env = ...

return {
  api = {
    GetClassColor = function()
      return env.Mixin({r=0, g=0, b=0}, env.ColorMixin)
    end,
  },
}
