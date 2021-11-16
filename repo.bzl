load("@bazel_tools//tools/build_defs/repo:utils.bzl", "patch", "update_attrs", "workspace_and_buildfile")

_http_7z_attrs = {
    "url": attr.string(
        doc =
            """A URL to a file that will be made available to Bazel.

This must be a file, http or https URL. Redirections are followed.
Authentication is not supported.

This parameter is to simplify the transition from the native http_archive
rule. More flexibility can be achieved by the urls parameter that allows
to specify alternative URLs to fetch from.
""",
    ),
    "urls": attr.string_list(
        doc =
            """A list of URLs to a file that will be made available to Bazel.

Each entry must be a file, http or https URL. Redirections are followed.
Authentication is not supported.""",
    ),
    "sha256": attr.string(
        doc = """The expected SHA-256 of the file downloaded.

This must match the SHA-256 of the file downloaded. _It is a security risk
to omit the SHA-256 as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but should be set before shipping.""",
    ),
    "patches": attr.label_list(
        default = [],
        doc =
            "A list of files that are to be applied as patches afer " +
            "extracting the archive.",
    ),
    "patch_tool": attr.string(
        default = "patch",
        doc = "The patch(1) utility to use.",
    ),
    "patch_args": attr.string_list(
        default = ["-p0"],
        doc = "The arguments given to the patch tool",
    ),
    "patch_cmds": attr.string_list(
        default = [],
        doc = "Sequence of commands to be applied after patches are applied.",
    ),
    "build_file": attr.label(
        allow_single_file = True,
        doc =
            "The file to use as the BUILD file for this repository." +
            "This attribute is an absolute label (use '@//' for the main " +
            "repo). The file does not need to be named BUILD, but can " +
            "be (something like BUILD.new-repo-name may work well for " +
            "distinguishing it from the repository's actual BUILD files. " +
            "Either build_file or build_file_content can be specified, but " +
            "not both.",
    ),
    "build_file_content": attr.string(
        doc =
            "The content for the BUILD file for this repository. " +
            "Either build_file or build_file_content can be specified, but " +
            "not both.",
    ),
    "workspace_file": attr.label(
        doc =
            "The file to use as the `WORKSPACE` file for this repository. " +
            "Either `workspace_file` or `workspace_file_content` can be " +
            "specified, or neither, but not both.",
    ),
    "workspace_file_content": attr.string(
        doc =
            "The content for the WORKSPACE file for this repository. " +
            "Either `workspace_file` or `workspace_file_content` can be " +
            "specified, or neither, but not both.",
    ),
    "_7zip_windows": attr.label(
        default = Label("@7zip//:7z1604-x64/7z.exe"),
        allow_single_file = True,
    ),
    "_7zip_unix": attr.label(
        default = Label("@7zip//:bin/7z"),
        allow_single_file = True,
    ),
}

def _pickExtname(urls):
    url = urls[0]
    dotIndex = url.rfind('.')
    if dotIndex == -1:
        return ""

    return url[dotIndex:]
    # return ".exe"

def _http_7z_impl(rctx):
    """Implementation of the http_7z rule."""
    if not rctx.attr.url and not rctx.attr.urls:
        fail("At least one of url and urls must be provided")
    if rctx.attr.build_file and rctx.attr.build_file_content:
        fail("Only one of build_file and build_file_content can be provided.")

    all_urls = []
    if rctx.attr.urls:
        all_urls = rctx.attr.urls
    if rctx.attr.url:
        all_urls = [rctx.attr.url] + all_urls

    exec7zip = None

    if rctx.os.name.startswith("windows"):
        exec7zip = rctx.path(rctx.attr._7zip_windows)
    else:
        exec7zip = rctx.path(rctx.attr._7zip_unix)

    download_path = rctx.path("_http_7z/" + rctx.name + _pickExtname(all_urls))

    download_info = rctx.download(
        all_urls,
        output = download_path,
        sha256 = rctx.attr.sha256,
        canonical_id = rctx.attr.sha256,
        executable = False,
    )

    extractResult = rctx.execute([
        exec7zip,
        "x",
        download_path,
    ])

    if extractResult.return_code != 0:
        err = extractResult.stderr
        fail("Failed to extract repo archive with 7zip: %s" % err)

    patch(rctx)
    workspace_and_buildfile(rctx)

    return update_attrs(
        rctx.attr,
        _http_7z_attrs.keys(),
        {"sha256": download_info.sha256},
    )

http_7z = repository_rule(
    implementation = _http_7z_impl,
    attrs = _http_7z_attrs,
)
