--
-- Profiling Tests
--
-- The profiling tests below replicate known behaviors and observable quirks
-- against the reference client profiling APIs like 'GetFunctionCPUUsage()'.
--

case("profiling: call counts and timings work post-call", function()
    local function test()
        for _ = 1, 2 ^ 20 do
        end
    end

    test()

    local stats = debug.getfunctionstats(test)
    assert(stats.calls == 1)
    assert(stats.ownticks > 0)
    assert(stats.ownticks == stats.subticks)
end)

case("profiling: call counts and tminigs work in-call", function()
    local stats

    local function test()
        for _ = 1, 2 ^ 20 do
        end
        stats = debug.getfunctionstats(test)
    end

    test()

    assert(stats.calls == 1)
    assert(stats.ownticks > 0)
    assert(stats.ownticks == stats.subticks)
end)

case("profiling: subroutine time freezes on recursive call", function()
    local stats

    local function test(n)
        if n > 0 then
            test(n - 1) -- Note: OP_CALL
        else
            for _ = 1, 2 ^ 20 do
            end
            stats = debug.getfunctionstats(test)
        end
    end

    test(1)

    assert(stats.calls == 2)
    assert(stats.ownticks > 0)
    assert(stats.subticks > 0)
    assert(stats.ownticks > stats.subticks) -- Subticks will be very small.
end)

case("profiling: subroutine time continues on recursive tailcall", function()
    local stats

    local function test(n)
        if n > 0 then
            return test(n - 1) -- Note: OP_TAILCALL
        else
            for _ = 1, 2 ^ 20 do
            end
            stats = debug.getfunctionstats(test)
        end
    end

    test(1)

    assert(stats.calls == 2)
    assert(stats.ownticks > 0)
    assert(stats.subticks > 0)
    assert(stats.subticks >= stats.ownticks) -- Subticks will be _slightly_ larger.
end)

case("profiling: execution time discarded on script errors", function()
    local a

    local function test()
        for _ = 1, 2 ^ 20 do
        end
        a = a + 1
    end

    pcall(test)

    local stats = debug.getfunctionstats(test)
    assert(stats.calls == 1)
    assert(stats.ownticks == 0)
    assert(stats.subticks == 0)
end)

case("profiling: execution time commits on function call", function()
    local function test()
        for _ = 1, 2 ^ 20 do
        end
        (function() end)()
        a = a + 1
    end

    pcall(test)

    local stats = debug.getfunctionstats(test)
    assert(stats.calls == 1)
    assert(stats.ownticks > 0)
    assert(stats.ownticks == stats.subticks)
end)

case("profiling: execution time pauses for direct yields", function()
    local function test1()
        coroutine.yield()
    end

    local function test2()
        local thread = coroutine.create(test1)
        coroutine.resume(thread)
        for _ = 1, 2 ^ 20 do
        end
        coroutine.resume(thread)
    end

    test2()

    local stats1 = debug.getfunctionstats(test1)
    local stats2 = debug.getfunctionstats(test2)

    assert(stats1.calls == 1)
    assert(stats2.calls == 1)

    -- To avoid a hardcoded time limit, this test passes so long as 'test1'
    -- reported an execution time that was <10% of 'test2'.
    --
    -- The actual expectation is that 'test1' won't accrue any time while
    -- suspended and waiting for resumption; so the tick counts should be
    -- very small!

    assert(stats1.ownticks < (stats2.ownticks * 0.1))
    assert(stats1.subticks < (stats2.subticks * 0.1))
end)

case("profiling: execution time does not pause for indirect yields", function()
    local function test1()
        -- Added IIFE to spice things up for an indirect (nested call) yield.
        (function()
            coroutine.yield()
        end)()
    end

    local function test2()
        local thread = coroutine.create(test1)
        coroutine.resume(thread)
        for _ = 1, 2 ^ 20 do
        end
        coroutine.resume(thread)
    end

    test2()

    local stats1 = debug.getfunctionstats(test1)
    local stats2 = debug.getfunctionstats(test2)

    assert(stats1.calls == 1)
    assert(stats2.calls == 1)

    -- As with the previous test we'll use percentages. The difference here
    -- is that 'test1' should have a small 'ownticks' count, but a very
    -- large 'subticks' one proportional to the time the thread was suspended.

    assert(stats1.ownticks < (stats2.ownticks * 0.1))
    assert(stats1.subticks >= (stats2.subticks * 0.9))
end)

case("profiling: execution time over multiple subroutine calls", function()
    local function test1()
        for i = 1, 2 ^ 16 do
        end
    end

    local function test2()
        for i = 1, 20 do
            test1()
        end
    end

    test2()

    local stats1 = debug.getfunctionstats(test1)
    local stats2 = debug.getfunctionstats(test2)

    assert(stats1.calls == 20)
    assert(stats2.calls == 1)

    -- Expect all execution times except 'stats2.ownticks' to be very large.
    assert(stats1.ownticks == stats1.subticks)
    assert(stats2.subticks >= stats1.ownticks)
    assert(stats2.ownticks < (stats1.ownticks * 0.1))
end)

-- This test case is for an assertion failure raised during handling of
-- tailcalls during stack unwinding, where the wrong function would have its
-- open call count decremented.
--
-- This test won't fail outside of debug builds.
case("profiling: tailcall unwinding state check", function()
    local function test1(n)
        if n > 0 then
            test1(n - 1)
        end
    end

    local function test2(n)
        if n > 0 then
            return test1(n - 1) -- Note: Calling 'test1'!
        end
    end

    test2(10)
end)
