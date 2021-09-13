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
    },
    {
      name = 'command with no action',
      inputs = {'/hello'},
      outputs = {},
    },
    {
      name = 'command with target and no action',
      inputs = {'/hello [@Alice]'},
      outputs = {},
    },
  },
}
