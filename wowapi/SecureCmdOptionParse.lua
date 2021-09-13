return {
  name = 'SecureCmdOptionParse',
  inputs = 's',
  outputs = 's?s?',
  impl = function()
    return ''  -- UNIMPLEMENTED
  end,
  tests = {
    {
      name = 'empty string',
      inputs = {''},
      outputs = {},
      pending = true,
    },
    {
      name = 'command with no action',
      inputs = {'/hello'},
      outputs = {},
      pending = true,
    },
    {
      name = 'command with target and no action',
      inputs = {'/hello [@Alice]'},
      outputs = {},
      pending = true,
    },
  },
}
