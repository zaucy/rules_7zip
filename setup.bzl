
def _windows_setup_7zip(rctx, build_template):
    rctx.download_and_extract(
        url = "https://www.7-zip.org/a/7za920.zip",
        output = "7za920",
        sha256 = "2a3afe19c180f8373fa02ff00254d5394fec0349f5804e0ad2f6067854ff28ac",
    )

    rctx.download(
        url = "https://www.7-zip.org/a/7z1604-extra.7z",
        output = "7z1604-extra.7z",
        sha256 = "59f41025acc40cf2e0b30b5cc6e4bcb1e07573201e256fbe8edb3c9c514dd251",
    )

    rctx.execute([
            "7za920/7za.exe",
            "x",
            "-y",
            "-o7z1604-extra",
            "7z1604-extra.7z"
    ])

    rctx.template("BUILD.bazel", rctx.path(build_template), executable = False)

def _posix_setup_7zip(rctx, build_template):
    rctx.download_and_extract(
        url = "https://astuteinternet.dl.sourceforge.net/project/p7zip/p7zip/16.02/p7zip_16.02_x86_linux_bin.tar.bz2",
        stripPrefix = "p7zip_16.02/bin",
    )

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
            default = Label("@com_github_zaucy_rules_7zip//:posix.BUILD.bazel"),
        ),
        "_windows_build_template": attr.label(
            default = Label("@com_github_zaucy_rules_7zip//:windows.BUILD.bazel"),
        ),
    },
)

def setup_7zip():
    _setup_7zip(name = "7zip")
