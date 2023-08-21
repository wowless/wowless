load("@bazel_skylib//rules:run_binary.bzl", "run_binary")

def _run_lua_script_impl(ctx):
    paths = {}
    cpaths = {}
    for d in ctx.files.data:
        f = d.path
        parts = f.split("/")
        if parts[0] == "bazel-out":
            prefix = parts[:5]
        elif parts[0] == "external":
            prefix = parts[:2]
        else:
            prefix = []
        if f.endswith("/init.lua"):
            paths["/".join(prefix + ["?/init.lua"])] = True
        elif f.endswith(".lua"):
            paths["/".join(prefix + ["?.lua"])] = True
        elif f.endswith(".so"):
            cpaths["/".join(prefix + ["?.so"])] = True
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
