load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")

LuaLibraryInfo = provider(
    fields = {
        "modules": "",
    },
)

def _lua_library_impl(ctx):
    modules = {}
    for d in ctx.attr.deps:
        for k, v in d[LuaLibraryInfo].modules.items():
            if k in modules:
                fail("moo")
            modules[k] = v
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

def _path(name):
    return "build/luarocks/share/lua/5.1/" + name.replace(".", "/") + ".lua"

def _lua_binary_impl(ctx):
    runfiles = [ctx.executable.interpreter, ctx.file.src]
    for l in ctx.attr.deps:
        for k, v in l[LuaLibraryInfo].modules.items():
            dst = ctx.actions.declare_file(_path(k))
            ctx.actions.symlink(output = dst, target_file = v)
            runfiles.append(dst)
    script = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(script, "./" + ctx.executable.interpreter.short_path + " " + ctx.file.src.short_path, is_executable = True)
    return [DefaultInfo(
        executable = script,
        runfiles = ctx.runfiles(runfiles),
    )]

lua_binary = rule(
    implementation = _lua_binary_impl,
    attrs = {
        "deps": attr.label_list(providers = [LuaLibraryInfo]),
        "interpreter": attr.label(executable = True, cfg = "exec"),
        "src": attr.label(allow_single_file = [".lua"]),
    },
    executable = True,
)

def _lua_cc_library_impl(ctx):
    return [
        cc_common.merge_cc_infos(cc_infos = [dep[CcInfo] for dep in ctx.attr.deps]),
        DefaultInfo(files = depset(ctx.files.srcs)),
        LuaLibraryInfo(modules = {}),
    ]

lua_cc_library = rule(
    implementation = _lua_cc_library_impl,
    attrs = {
        "module": attr.string(mandatory = True),
        "srcs": attr.label_list(allow_files = [".c", ".h"]),
        "deps": attr.label_list(providers = [CcInfo]),
    },
)

def _lua_materialized_cc_library_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    allsrcs = [f for d in ctx.attr.deps for f in d[DefaultInfo].files.to_list()]
    _, compilation_outputs = cc_common.compile(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        name = ctx.label.name,
        srcs = [s for s in allsrcs if s.extension != "h"],
        private_hdrs = [s for s in allsrcs if s.extension == "h"],
        compilation_contexts = [ctx.attr.lua[CcInfo].compilation_context],
    )
    linking_context, _ = cc_common.create_linking_context_from_compilation_outputs(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        name = ctx.label.name,
        compilation_outputs = compilation_outputs,
    )
    ccinfo = CcInfo(linking_context = linking_context)
    depccinfos = [dep[CcInfo] for dep in ctx.attr.deps]
    return [cc_common.merge_cc_infos(cc_infos = [ccinfo] + depccinfos)]

lua_materialized_cc_library = rule(
    implementation = _lua_materialized_cc_library_impl,
    attrs = {
        "lua": attr.label(mandatory = True, providers = [CcInfo]),
        "deps": attr.label_list(providers = [LuaLibraryInfo]),
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
    },
    fragments = ["cpp"],
    toolchains = use_cpp_toolchain(),
)
