
def _windows_setup_7zip(rctx, build_template):

    msiexec = rctx.which("msiexec.exe")
    if not msiexec:
        fail("Unable to find msiexec.exe")

    rctx.report_progress("Fetching 7z1900-x64.msi")
    rctx.download(
        url = "https://www.7-zip.org/a/7z1900-x64.msi",
        output = "7z1900-x64.msi",
        sha256 = "a7803233eedb6a4b59b3024ccf9292a6fffb94507dc998aa67c5b745d197a5dc",
    )

    msi_path = str(rctx.path("7z1900-x64.msi")).replace("/", "\\")
    msi_target_dir = str(rctx.path("7z1900-x64")).replace("/", "\\")

    msi_extract_args = [
        msiexec,
        "/a",
        msi_path,
        "TARGETDIR=%s" % msi_target_dir,
        "/qn",
    ]

    rctx.report_progress("Extracting %s" % msi_path)
    msi_extract_result = rctx.execute(msi_extract_args)

    if msi_extract_result.return_code != 0:
        err_message = msi_extract_result.stdout if msi_extract_result.stdout else msi_extract_result.stderr
        fail("7zip MSI extraction failed: exit_code=%s\n\n%s" % (msi_extract_result.return_code, err_message))

    exec_7z_path = rctx.path("7z1900-x64/Files/7-Zip/7z.exe")

    if not exec_7z_path.exists:
        fail("Missing %s after MSI extraction" % exec_7z_path)

    rctx.download(
        url = "https://www.7-zip.org/a/7z1900-extra.7z",
        output = "7z1900-extra.7z",
        sha256 = "af6eca1c8578df776189ee7785ab5d21525e42590f788c4e82e961a36c3a5306",
    )

    extra_archive_path = rctx.path("7z1900-extra.7z")
    extra_dir_path = rctx.path("7z1900-extra")

    rctx.report_progress("Extracting %s" % extra_archive_path)
    extra_extract_result = rctx.execute([
        exec_7z_path,
        "e",
        extra_archive_path,
        "-o%s" % extra_dir_path,
        "-y",
    ])

    if extra_extract_result.return_code != 0:
        err_message = msi_extract_result.stdout if msi_extract_result.stdout else msi_extract_result.stderr
        fail("Extracting 7z1900-extra.7z failed: exit_code=%s\n\n%s" % (msi_extract_result.return_code, err_message))

    rctx.template("BUILD.bazel", rctx.path(build_template), executable = False)

def _posix_setup_7zip(rctx, build_template):
    rctx.download_and_extract(
        url = "https://downloads.sourceforge.net/project/p7zip/p7zip/16.02/p7zip_16.02_src_all.tar.bz2",
        stripPrefix = "p7zip_16.02",
        sha256 = "5eb20ac0e2944f6cb9c2d51dd6c4518941c185347d4089ea89087ffdd6e2341f",
    )
    rctx.patch(rctx.attr._p7zip_patch, strip = 1)
    rctx.template("BUILD.bazel", rctx.path(build_template), executable = False)

def _setup_7zip_impl(rctx):
    os_name = rctx.os.name

    if os_name.startswith("windows"):
        _windows_setup_7zip(rctx, rctx.attr._windows_build_template)
    else:
        _posix_setup_7zip(rctx, rctx.attr._posix_build_template)

_setup_7zip = repository_rule(
    implementation = _setup_7zip_impl,
    attrs = {
        "_posix_build_template": attr.label(
            default = Label("@rules_7zip//:posix.BUILD.bazel"),
        ),
        "_windows_build_template": attr.label(
            default = Label("@rules_7zip//:windows.BUILD.bazel"),
        ),
        "_p7zip_patch": attr.label(
            default = Label("@rules_7zip//patches:p7zip_cpu_arch_include.patch"),
        )
    },
)

def setup_7zip():
    _setup_7zip(name = "7zip")
