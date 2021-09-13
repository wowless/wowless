return {
  name = 'SecureCmdOptionParse',
  inputs = 's',
  outputs = 's?s?',
  status = 'stub',
  impl = function(s)
    return s
  end,
  tests = {
    {
      name = 'empty string',
      inputs = {''},
      outputs = {''},
    },
    {
      name = 'command with no action',
      inputs = {'/hello'},
      outputs = {'/hello'},
    },
    {
      name = 'command with target and no action',
      inputs = {'/hello [@Alice]'},
      outputs = {'', 'Alice'},
      pending = true,
    },
  },
}
