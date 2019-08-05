def _pkg_7z_impl(ctx):
    archive_name = ctx.attr.name + '.' + ctx.attr.extension
    archive_file = ctx.actions.declare_file(archive_name)
    outs = depset([archive_file])

    is_p7zip = not ctx.executable._7zip.path.endswith(".exe")

    args = ["a", "-y"]

    if is_p7zip:
        args.append("-l")

    args.append(archive_file.path)

    for src in ctx.files.srcs:
        args.append(src.path)

    rename_srcs = []
    rename_args = ["rn", archive_file.path]

    for src in ctx.files.srcs:
        if src.short_path != src.path:
            rename_srcs.append(src)
            rename_args.append(src.path)
            rename_args.append(src.short_path)

    exec_7za = ctx.executable._7zip.path + " "

    if not ctx.attr.full_paths and len(rename_srcs) > 0:
        ctx.actions.run_shell(
            outputs = [archive_file],
            command =
                exec_7za + " ".join(args) + " > nul && " +
                exec_7za + " ".join(rename_args) + " > nul",
            tools = [ctx.executable._7zip],
            inputs = ctx.files.srcs,
            arguments = [],
        )
    else:
        ctx.actions.run(
            outputs = [archive_file],
            executable = ctx.executable._7zip,
            inputs = ctx.files.srcs,
            arguments = args,
        )

    return DefaultInfo(files = outs)

pkg_7z = rule(
    implementation = _pkg_7z_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "extension": attr.string(
            default = '7z',
            values = ['7z', 'zip'],
        ),
        "full_paths": attr.bool(default = False),
        "_7zip": attr.label(
            default = Label("@7zip//:7za"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
    },
)
