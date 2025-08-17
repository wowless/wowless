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
      assert.same({ { 1, 'rofl' }, { 2, 'copter'} }, t)
    end)
  end)
  describe('stmt', function()
    local stmt = db:prepare('SELECT F2, F1 FROM Foo')
    it('urows', function()
      local t = {}
      for a, b in stmt:urows('SELECT F1, F2 FROM Foo') do
        table.insert(t, { a, b })
      end
      assert.same({ { 1, 'rofl' }, { 2, 'copter'} }, t)
    end)
    stmt:reset()
  end)
end)
