# rules_7zip

This repository adds [7zip](https://www.7-zip.org/) support for your [bazel](https://bazel.build/) projects. If you want to just use the 7zip executable then you can access it as `@7zip//:7za` or use the `pkg_7z` rule.

## Installation

Add this to your `WORKSPACE`:

```python
http_archive(
    name = "rules_7zip",
    strip_prefix = "rules_7zip-25d3b858a37580dbc1f1ced002e210be15012e2f",
    urls = ["https://github.com/zaucy/rules_7zip/archive/25d3b858a37580dbc1f1ced002e210be15012e2f.zip"],
    sha256 = "29ba984e2a7d48540faa839efaf09be4b880d211a93575e7ac87abffc12dbdea",
)

load("@rules_7zip//:setup.bzl", "setup_7zip")
setup_7zip()
```

## Rules

Similar to `pkg_*` rules in [rules_pkg](https://github.com/bazelbuild/rules_pkg) except the package is created with 7-zip.

```python
load("@rules_7zip//:defs.bzl", "pkg_7z")
pkg_7z(name)
```

Similar to [`http_archive`](https://docs.bazel.build/versions/main/repo/http.html#http_archive) except the archive will be extracted with 7zip. This enables you to fetch and extract `.7z`, `.exe`, `.msi`, or other 7-zip supported archives that `http_archive` does not support.

```python
load("@rules_7zip//:defs.bzl", "http_7z")
http_7z(name)
```

## How it works

7zip pre-built binaries are used on windows and p7zip is downloaded and compiles on all other platforms. Regardless of the platform you use rules_7zip you will be able to run and utilise `@7zip//:7z` and `@7zip//:7za`.

### On Windows

1) Downloads 7zip 19.00 MSI installer
2) Extracts 7zip with msiexec.exe
3) Downloads 7zip 19.00 extras
4) Extract 7zip extras _with_ previously extracted 7zip

Now you can use 7zip 19.00!

### On POSIX

1) Download and extract p7zip source
2) Setup bazel build files in order for it to be compiled

Now you can use p7zip 16.02!

## License

This repository is licensed under MIT. Please note that rules_7zip downloads and uses 7zip which has it's own license. You can find the license for 7zip on their website [https://7-zip.org/](https://7-zip.org/).
