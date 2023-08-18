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
