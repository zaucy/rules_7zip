def _write_rn_listfile(ctx = None, listFile = None):
    listFileLines = []

    for srcFile in ctx.files.srcs:
        if srcFile.short_path != srcFile.path:
            listFileLines.append(srcFile.path)
            listFileLines.append(srcFile.short_path)

    ctx.actions.write(
        output = listFile,
        content = "\n".join(listFileLines),
        is_executable = False,
    )

    return len(listFileLines) > 0

def _write_strip_prefix_listfile(ctx = None, listFile = None):
    listFileLines = []
    stripPrefix = ctx.attr.strip_prefix

    for srcFile in ctx.files.srcs:
        if srcFile.short_path.startswith(stripPrefix):
            newShortPath = srcFile.short_path[len(stripPrefix):]
            listFileLines.append(srcFile.short_path)
            listFileLines.append(newShortPath)

    ctx.actions.write(
        output = listFile,
        content = "\n".join(listFileLines),
        is_executable = False,
    )

    return len(listFileLines) > 0

def _write_remap_listfile(ctx = None, listFile = None):
    listFileLines = []

    for key in ctx.attr.remap_paths:
        listFileLines.append(key)
        listFileLines.append(ctx.attr.remap_paths[key])

    ctx.actions.write(
        output = listFile,
        content = "\n".join(listFileLines),
        is_executable = False,
    )

    return len(listFileLines) > 0

def _pkg_7z_impl(ctx):
    name = ctx.attr.name
    archive_name = name + '.' + ctx.attr.extension
    archive_file = ctx.actions.declare_file(archive_name)
    outs = depset([archive_file])

    srcsListFile = ctx.actions.declare_file(name + "__srcs.listfile")

    is_p7zip = not ctx.executable._7zip.path.endswith(".exe")

    args = ["a", "-y"]
    srcPaths = []

    if is_p7zip:
        args.append("-l")

    args.append(archive_file.path)
    args.append("@" + srcsListFile.path)

    for src in ctx.files.srcs:
        srcPaths.append(src.path)

    ctx.actions.write(
        output = srcsListFile,
        content = "\n".join(srcPaths),
        is_executable = False,
    )

    exec_7za = ctx.executable._7zip.path + " "
    exec_7za_rn = exec_7za + "rn " + archive_file.path + " "
    command = exec_7za + " ".join(args) + " > nul"
    listFileInputs = [srcsListFile]

    if not ctx.attr.full_paths:
        rnSrcsListFile = ctx.actions.declare_file(name + "__rn_srcs.listfile")
        listFileInputs.append(rnSrcsListFile)
        filledRnListFile = _write_rn_listfile(
            ctx = ctx,
            listFile = rnSrcsListFile
        )

        if filledRnListFile:
            command += " && " + exec_7za_rn + "@" + rnSrcsListFile.path + "> nul"

    if len(ctx.attr.strip_prefix) > 0:
        strippedSrcsListFile = ctx.actions.declare_file(name + "__stripped_srcs.listfile")
        listFileInputs.append(strippedSrcsListFile)
        filledStrippedListFile = _write_strip_prefix_listfile(
            ctx = ctx,
            listFile = strippedSrcsListFile,
        )

        if filledStrippedListFile:
            command += " && " + exec_7za_rn + "@" + strippedSrcsListFile.path + " > nul"

    if len(ctx.attr.remap_paths.keys()) > 0:
        remapSrcsListFile = ctx.actions.declare_file(name + "__remap_srcs.listfile")
        listFileInputs.append(remapSrcsListFile)

        filledRemapListFile = _write_remap_listfile(
            ctx = ctx,
            listFile = remapSrcsListFile,
        )

        if filledRemapListFile:
            command += " && " + exec_7za_rn + "@" + remapSrcsListFile.path + " > nul"

    ctx.actions.run_shell(
        outputs = [archive_file],
        command = command,
        tools = [ctx.executable._7zip],
        inputs = ctx.files.srcs + listFileInputs,
        arguments = [],
    )

    return [
        DefaultInfo(files = outs),
        OutputGroupInfo(listfiles = depset(listFileInputs)),
    ]

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
        "strip_prefix": attr.string(),
        "remap_paths": attr.string_dict(default = {}),
        "full_paths": attr.bool(default = False),
        "_7zip": attr.label(
            default = Label("@zip7//:7za"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
    },
)
