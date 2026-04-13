# Usage Guide

## 1. Backup current dotfiles

```bash
./scripts/backup-dotfiles.sh --clean
```

What it does:

- Reads `manifests/home-paths.txt` and copies those paths from `$HOME` into `dotfiles/home`
- Reads `manifests/config-paths.txt` and copies those paths from `$HOME/.config` into `dotfiles/config`

## 2. Install packages

Base packages only:

```bash
./scripts/install-packages.sh
```

Base + extended packages:

```bash
./scripts/install-packages.sh --extended
```

## 3. Apply dotfiles on a new machine

```bash
./scripts/apply-dotfiles.sh
```

## 4. Update tracked files later

1. Edit manifests:
   - `manifests/home-paths.txt`
   - `manifests/config-paths.txt`
2. Run backup again:

```bash
./scripts/backup-dotfiles.sh --clean
```
3. Commit updates:

```bash
git add .
git commit -m "Update dotfiles backup"
```
