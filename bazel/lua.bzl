load("@bazel_skylib//rules:run_binary.bzl", "run_binary")

LuaLibraryInfo = provider(
    fields = {
        "modules": "",
    },
)

def _merge_deps_modules(deps):
    modules = {}
    for d in deps:
        for k, v in d[LuaLibraryInfo].modules.items():
            if k in modules:
                fail("moo")
            modules[k] = v
    return modules

def _lua_library_impl(ctx):
    modules = _merge_deps_modules(ctx.attr.deps)
    for k, v in ctx.attr.modules.items():
        if v in modules:
            fail("moo")
        modules[v] = k.files.to_list()[0]
    return [
        cc_common.merge_cc_infos(cc_infos = [dep[CcInfo] for dep in ctx.attr.deps]),
        LuaLibraryInfo(modules = modules),
    ]

lua_library = rule(
    implementation = _lua_library_impl,
    attrs = {
        "deps": attr.label_list(providers = [LuaLibraryInfo]),
        "modules": attr.label_keyed_string_dict(allow_files = [".lua"]),
    },
)

def _run_lua_script_impl(ctx):
    paths = {}
    cpaths = {}
    for d in ctx.files.data:
        f = d.path
        if "external/" not in f:
            paths["?.lua"] = True
        elif f.endswith(".lua"):
            paths["/".join(f.split("/", 3)[:2] + ["?.lua"])] = True
        else:
            cpaths["/".join(f.split("/", 6)[:5] + ["?.so"])] = True
    ctx.actions.run(
        executable = ctx.executable.interpreter,
        arguments = [ctx.file.script.path, ctx.outputs.output.path],
        inputs = [ctx.file.script] + ctx.files.data,
        outputs = [ctx.outputs.output],
        env = {
            "LUA_CPATH": ";".join(cpaths.keys()),
            "LUA_PATH": ";".join(paths.keys()),
        },
    )

run_lua_script = rule(
    implementation = _run_lua_script_impl,
    attrs = {
        "interpreter": attr.label(executable = True, cfg = "exec", default = "@puclua"),
        "script": attr.label(allow_single_file = [".lua"]),
        "output": attr.output(),
        "data": attr.label_list(allow_files = True),
    },
)
