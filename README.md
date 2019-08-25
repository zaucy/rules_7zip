# rules_7zip

This repository adds [7zip](https://www.7-zip.org/) support for your [bazel](https://bazel.build/) projects. If you want to just use the 7zip executable then you can access it as `@7zip//:7za` or use the `pkg_7z` rule.

## Installation

Add this to your `WORKSPACE`:

```python
http_archive(
    name = "com_github_zaucy_rules_7zip",
    strip_prefix = "rules_7zip-9d135c6d2ba86464582109c133023d10d1e73deb",
    urls = ["https://github.com/zaucy/rules_7zip/archive/9d135c6d2ba86464582109c133023d10d1e73deb.zip"],
    sha256 = "3cfb3e783d5b73d22276de4e3c16455a60cbd94f65ba42341c963d076a25bdac",
)

load("@com_github_zaucy_rules_7zip//:setup.bzl", "setup_7zip")
setup_7zip()
```

## How it works

### On Windows

1) Downloads and extracts 7zip 9.20 zip file
2) Downloads 7zip 16.04 extras .7z file
3) Extracts 7zip 16.04 extras .7z file with 7zip 9.20
4) 7za is now available from 7zip 16.04 extras
5) Downloads 7zip 16.04 msi installer
6) Extract files from 16.04 msi installer using 7za

Now you can use 7zip 16.04!

### On POSIX

1) Download and extract p7zip bin

Now you can use p7zip 16.02!

## License

This repository is licensed under MIT. Please note that rules_7zip downloads and uses 7zip which has it's own license. You can find the license for 7zip on their website [https://7-zip.org/](https://7-zip.org/).
