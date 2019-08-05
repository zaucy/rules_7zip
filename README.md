# rules_7zip

This repository adds [7zip](https://www.7-zip.org/) support for your [bazel](https://bazel.build/) projects. If you want to just use 7-zip then you can access it as `@7zip//:7za` or use the `pkg_7z` rule.

## How it works

### On Windows

1) Downloads and extracts 7zip 9.20 zip file
2) Downloads 7zip 16.04 .7z file
3) Extracts 7zip 16.04 .7z file with 7zip 9.20

Now you can use 7zip 16.04!

### On POSIX

(untested)

1) Download and extract p7zip bin

Now you can use p7zip 16.02!
