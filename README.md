# rules_7zip

This repository adds [7zip](https://www.7-zip.org/) support for your [bazel](https://bazel.build/) projects. If you want to just use the 7zip executable then you can access it as `@zip7//:7za` or use the `pkg_7z` rule.

## Installation

Add this to your `MODULE.bazel` file:

```python
bazel_dep(name = "rules_7zip")

extension_setup_7zip = use_extension("@rules_7zip//:extension_setup_7zip.bzl", "extension_setup_7zip")
use_repo(extension_setup_7zip, "zip7")
```
Note that "7zip" is renamed to "zip7" due to constraints with naming inside Bzlmod. In case you were using `@7zip` in your code, modify that with `@zip7`.

In case you're not using Bzlmod, add this to your `WORKSPACE`:

```python
http_archive(
    name = "rules_7zip",
    strip_prefix = "rules_7zip-e00b15d3cb76b78ddc1c15e7426eb1d1b7ddaa3e",
    urls = ["https://github.com/zaucy/rules_7zip/archive/e00b15d3cb76b78ddc1c15e7426eb1d1b7ddaa3e.zip"],
    sha256 = "fd9e99f6ccb9e946755f9bc444abefbdd1eedb32c372c56dcacc7eb486aed178",
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

7zip pre-built binaries are used on windows and p7zip is downloaded and compiles on all other platforms. Regardless of the platform you use rules_7zip you will be able to run and utilise `@zip7//:7z` and `@zip7//:7za`.

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
