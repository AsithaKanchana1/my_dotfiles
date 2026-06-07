# Package Catalog

This directory contains the package manifests consumed by `scripts/install-software.sh`.

## Structure

| File | Purpose |
|------|---------|
| `catalog/index.tsv` | Master index — lists every category with its key, label, description, and path to its package list. |
| `catalog/<category>.txt` | One package name per line for that category. |

## Categories

| Key | Label |
|-----|-------|
| `core` | Core workstation essentials |
| `development` | Development toolchain |
| `desktop` | Desktop and shell integration |
| `media` | Media and creative apps |
| `internet` | Internet and communication |
| `system` | System maintenance |
| `drivers-intel` | Intel drivers |
| `drivers-amd` | AMD drivers |
| `drivers-nvidia` | NVIDIA drivers |
| `drivers-virtualization` | Virtualization and guest tools |
| `drivers-printing` | Printing and scanning |
| `gaming` | Gaming stack |
| `productivity` | Productivity and office |

## Package File Format

- One package name per line.
- Empty lines are ignored.
- Lines starting with `#` are treated as comments.
- Packages are installed via `yay` (AUR helper).

## Adding a New Category

1. Create `catalog/<key>.txt` with your package list.
2. Add a row to `catalog/index.tsv`:
   ```
   <key>\t<label>\t<description>\tpackages/catalog/<key>.txt
   ```
3. The new category will appear automatically in the interactive installer.
