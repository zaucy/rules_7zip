
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

    extraExtractResult = rctx.execute([
        "7za920/7za.exe",
        "x",
        "-y",
        "-o7z1604-extra",
        "7z1604-extra.7z"
    ])

    if extraExtractResult.return_code != 0:
        errMsg = extraExtractResult.stderr
        fail("Failed to extract 7z1604-extra with 7za920/7za.exe: %s" % errMsg)

    rctx.download(
        url = "https://www.7-zip.org/a/7z1604-x64.msi",
        output = "7z1604-x64.msi",
        sha256 = "b3885b2f090f1e9b5cf2b9f802b07fe88e472d70d60732db9f830209ac296067",
    )

    extractResult = rctx.execute([
        "7z1604-extra/7za.exe",
        "x",
        "-y",
        "-o7z1604-x64",
        "7z1604-x64.msi",
    ])

    if extractResult.return_code != 0:
        errMsg = extractResult.stderr
        fail("Failed to extract 7z1604-x64.msi: %s " % errMsg)

    rctx.execute([
        "7z1604-extra/7za.exe",
        "a",
        "-y",
        "7z1604-x64-minimal.7z",
        "7z1604-x64/License.txt",
        "7z1604-x64/_7z.exe",
        "7z1604-x64/_7z.dll",
    ])

    rctx.execute([
        "7z1604-extra/7za.exe",
        "rn",
        "-y",
        "7z1604-x64-minimal.7z",
        "7z1604-x64/_7z.exe",
        "7z1604-x64/7z.exe",
        "7z1604-x64/_7z.dll",
        "7z1604-x64/7z.dll",
    ])

    rctx.delete("7z1604-x64")

    rctx.execute([
        "7z1604-extra/7za.exe",
        "e",
        "-y",
        "-o7z1604-x64",
        "7z1604-x64-minimal.7z",
    ])

    rctx.template("BUILD.bazel", rctx.path(build_template), executable = False)

    # Cleanup unused files
    rctx.delete("7z1604-x64-minimal.7z")
    rctx.delete("7z1604-x64.msi")
    rctx.delete("7z1604-extra.7z")

def _posix_setup_7zip(rctx, build_template):
    rctx.download_and_extract(
        url = "https://astuteinternet.dl.sourceforge.net/project/p7zip/p7zip/16.02/p7zip_16.02_x86_linux_bin.tar.bz2",
        stripPrefix = "p7zip_16.02/bin",
        sha256 = "96c93a440b04013a23fbea39555816c0dac51d3ade56153f0a68c41d3c1d7b61",
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
