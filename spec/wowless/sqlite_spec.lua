describe('sqlite', function()
  local db = require('lsqlite3').open_memory()
  db:exec([=[
    CREATE TABLE Foo (F1 INT, F2 STRING);
    INSERT INTO Foo VALUES (1, "rofl");
    INSERT INTO Foo VALUES (2, "copter");
  ]=])
  describe('db', function()
    it('urows', function()
      local t = {}
      for a, b in db:urows('SELECT F1, F2 FROM Foo') do
        table.insert(t, { a, b })
      end
      assert.same({ { 1, 'rofl' }, { 2, 'copter' } }, t)
    end)
  end)
  describe('stmt', function()
    local stmt = db:prepare('SELECT F2, F1 FROM Foo')
    it('rows', function()
      local t = {}
      for a in stmt:rows() do
        table.insert(t, a)
      end
      assert.same({ { 'rofl', 1 }, { 'copter', 2 } }, t)
    end)
    stmt:reset()
    it('nrows', function()
      local t = {}
      for a in stmt:nrows() do
        table.insert(t, a)
      end
      assert.same({ { F2 = 'rofl', F1 = 1 }, { F2 = 'copter', F1 = 2 } }, t)
    end)
    stmt:reset()
    it('urows', function()
      local t = {}
      for a, b in stmt:urows() do
        table.insert(t, { a, b })
      end
      assert.same({ { 'rofl', 1 }, { 'copter', 2 } }, t)
    end)
    stmt = db:prepare('SELECT F2 FROM Foo WHERE F1 = ?1')
    it('bind_values', function()
      stmt:bind_values(2)
      local t = {}
      for a in stmt:rows() do
        table.insert(t, a)
      end
      assert.same({ { 'copter' } }, t)
    end)
  end)
end)
