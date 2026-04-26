# Package Lists

This directory contains package manifests consumed by the installation scripts.

- `base-packages.txt`: Core packages for development and daily usage.
- `extended-packages.txt`: Optional packages for additional desktop and development tooling.

Format:

- One package name per line
- Empty lines are allowed
- Lines starting with `#` are treated as comments

Installation source:

- Packages are installed through `yay` by `scripts/install-packages.sh`
