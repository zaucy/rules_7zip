load("@rules_7zip//:setup.bzl", "setup_7zip")

def _extension_setup_7zip(ctx):
    setup_7zip()

extension_setup_7zip = module_extension(implementation = _extension_setup_7zip)
