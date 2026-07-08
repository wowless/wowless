return function(bindings, chunks, datalua)
  return require('build.products.' .. datalua.product .. '.xmlcode')(bindings.AddBinding, chunks.LoadChunk)
end
