def _pkg_7z_impl(ctx):
    archive_name = ctx.attr.name + '.' + ctx.attr.extension
    archive_file = ctx.actions.declare_file(archive_name)
    outs = depset([archive_file])

    args = ["a", "-y", archive_file.path]

    for src in ctx.files.srcs:
        args.append(src.path)

    ctx.actions.run(
        outputs = [archive_file],
        executable = ctx.executable._7zip,
        inputs = ctx.files.srcs,
        arguments = args,
    )

    rename_srcs = []
    rename_args = ["rn", archive_file.path]

    for src in ctx.files.srcs:
        if src.short_path != src.path:
            rename_srcs.append(src)
            rename_args.append(src.path)
            rename_args.append(src.short_path)

    if len(rename_srcs) > 0:
        rn_file = ctx.actions.declare_file(ctx.attr.name + '.rn.log')
        outs = depset([rn_file], transitive=[outs])
        ctx.actions.run_shell(
            outputs = [rn_file],
            command = ctx.executable._7zip.path + " $@ > " + rn_file.path,
            tools = [ctx.executable._7zip],
            inputs = rename_srcs + [archive_file],
            arguments = rename_args,
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
        "_7zip": attr.label(
            default = Label("@7zip//:7za"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
    },
)
