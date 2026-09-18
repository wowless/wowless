--
-- Coroutine extension tests
--

-- luacheck: globals coroutine.bind coroutine.call coroutine.mainthread

case("coroutine.call: can call function on another thread", function()
    local otherthread = coroutine.create(function() end)
    local numcalls = 0
    local whatthread

    local function call()
        numcalls = numcalls + 1
        whatthread = coroutine.running()
    end

    coroutine.call(otherthread, call)
    assert(numcalls == 1)
    assert(whatthread == otherthread)
end)

case("coroutine.call: can call function on current thread", function()
    local mainthread = coroutine.mainthread()
    local numcalls = 0
    local whatthread = "any value that isn't nil"

    local function call()
        numcalls = numcalls + 1
        whatthread = coroutine.running()
    end

    assert(coroutine.running() == nil) -- verifies this is the main thread
    coroutine.call(mainthread, call)
    assert(numcalls == 1)
    assert(whatthread == nil)
end)

case("coroutine.call: can supply arguments to called thread", function()
    local otherthread = coroutine.create(function() end)
    local args

    local function call(...)
        args = { n = select("#", ...), ... }
    end

    coroutine.call(otherthread, call, 1, 2, 3)
    assert(args.n == 3)
    assert(args[1] == 1)
    assert(args[2] == 2)
    assert(args[3] == 3)
end)

case("coroutine.call: can return values from called thread", function()
    local otherthread = coroutine.create(function() end)

    local function call()
        return "a", "b", "c"
    end

    local returns = { coroutine.call(otherthread, call) }
    assert(#returns == 3)
    assert(returns[1] == "a")
    assert(returns[2] == "b")
    assert(returns[3] == "c")
end)

case("coroutine.call: returns correct values if calling current thread", function()
    local mainthread = coroutine.mainthread()

    local function call()
        return "a", "b", "c"
    end

    assert(coroutine.running() == nil)
    local returns = { coroutine.call(mainthread, call) }
    assert(#returns == 3)
    assert(returns[1] == "a")
    assert(returns[2] == "b")
    assert(returns[3] == "c")
end)

case("coroutine.call: errors propagate to calling thread", function()
    local otherthread = coroutine.create(function() end)

    local function badcall()
        error("bad!")
    end

    local result, message = pcall(coroutine.call, otherthread, badcall)
    assert(result == false)
    assert(string.find(message, "bad!", 1, true))
end)

case("coroutine.call: errors do not kill called thread", function()
    local otherthread = coroutine.create(function() end)
    local othercalls = 0

    local function goodcall()
        othercalls = othercalls + 1
    end

    local function badcall()
        othercalls = othercalls + 1
        error("bad!")
    end

    assert(not pcall(coroutine.call, otherthread, badcall))
    assert(pcall(coroutine.call, otherthread, goodcall))
    assert(othercalls == 2)
end)

case("coroutine.call: can re-enter calling thread", function()
    local otherthread = coroutine.create(function() end)
    local mainthread = coroutine.mainthread()

    local othercalls = 0
    local maincalls = 0

    local function step3()
        assert(coroutine.running() == nil)
        maincalls = maincalls + 1
        return "value"
    end

    local function step2()
        assert(coroutine.running() == otherthread)
        othercalls = othercalls + 1
        return coroutine.call(mainthread, step3)
    end

    local function step1()
        assert(coroutine.running() == nil)
        maincalls = maincalls + 1
        return coroutine.call(otherthread, step2)
    end

    local result = step1()

    assert(othercalls == 1)
    assert(maincalls == 2)
    assert(result == "value")
end)

case("coroutine.call: can re-enter calling thread multiple times", function()
    local otherthread = coroutine.create(function() end)
    local mainthread = coroutine.mainthread()

    local othercalls = 0
    local maincalls = 0

    local function step6()
        assert(coroutine.running() == otherthread)
        othercalls = othercalls + 1
        return "value"
    end

    local function step5()
        assert(coroutine.running() == nil)
        maincalls = maincalls + 1
        return coroutine.call(otherthread, step6)
    end

    local function step4()
        assert(coroutine.running() == otherthread)
        othercalls = othercalls + 1
        return coroutine.call(mainthread, step5)
    end

    local function step3()
        assert(coroutine.running() == nil)
        maincalls = maincalls + 1
        return coroutine.call(otherthread, step4)
    end

    local function step2()
        assert(coroutine.running() == otherthread)
        othercalls = othercalls + 1
        return coroutine.call(mainthread, step3)
    end

    local function step1()
        assert(coroutine.running() == nil)
        maincalls = maincalls + 1
        return coroutine.call(otherthread, step2)
    end

    local result = step1()

    assert(othercalls == 3)
    assert(maincalls == 3)
    assert(result == "value")
end)

case("coroutine.call: can call function on another thread", function()
    local otherthread = coroutine.create(function() end)
    local numcalls = 0
    local whatthread

    local function call()
        numcalls = numcalls + 1
        whatthread = coroutine.running()
    end

    coroutine.bind(otherthread, call)()
    assert(numcalls == 1)
    assert(whatthread == otherthread)
end)

case("coroutine.bind: can call function on current thread", function()
    local mainthread = coroutine.mainthread()
    local numcalls = 0
    local whatthread = "any value that isn't nil"

    local function call()
        numcalls = numcalls + 1
        whatthread = coroutine.running()
    end

    assert(coroutine.running() == nil) -- verifies this is the main thread
    coroutine.bind(mainthread, call)()
    assert(numcalls == 1)
    assert(whatthread == nil)
end)

case("coroutine.bind: can supply arguments to called thread", function()
    local otherthread = coroutine.create(function() end)
    local args

    local function call(...)
        args = { n = select("#", ...), ... }
    end

    coroutine.bind(otherthread, call)(1, 2, 3)
    assert(args.n == 3)
    assert(args[1] == 1)
    assert(args[2] == 2)
    assert(args[3] == 3)
end)

case("coroutine.bind: can return values from called thread", function()
    local otherthread = coroutine.create(function() end)

    local function call()
        return "a", "b", "c"
    end

    local returns = { coroutine.bind(otherthread, call)() }
    assert(#returns == 3)
    assert(returns[1] == "a")
    assert(returns[2] == "b")
    assert(returns[3] == "c")
end)

case("coroutine.bind: returns correct values if calling current thread", function()
    local mainthread = coroutine.mainthread()

    local function call()
        return "a", "b", "c"
    end

    assert(coroutine.running() == nil)
    local returns = { coroutine.bind(mainthread, call)() }
    assert(#returns == 3)
    assert(returns[1] == "a")
    assert(returns[2] == "b")
    assert(returns[3] == "c")
end)
