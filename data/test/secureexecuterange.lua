local T = ...
return {
  empty = function()
    T.check0(T.env.secureexecuterange({}, error))
  end,
  nonempty = function()
    local log = {}
    T.check0(T.env.secureexecuterange({ 'foo', 'bar' }, function(...)
      table.insert(log, '[')
      for i = 1, select('#', ...) do
        table.insert(log, (select(i, ...)))
      end
      table.insert(log, ']')
    end, 'baz', 'quux'))
    T.assertEquals('[,1,foo,baz,quux,],[,2,bar,baz,quux,]', table.concat(log, ','))
  end,
}
