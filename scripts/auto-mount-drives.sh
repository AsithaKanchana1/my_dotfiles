#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
INCLUDE_SYSTEM_DISK=0

usage() {
  cat <<'EOF'
Usage: auto-mount-drives.sh [--dry-run] [--include-system-disk]

Options:
  --dry-run             Show what would be mounted without mounting anything.
  --include-system-disk Also mount eligible partitions on the system/root disk.
  -h, --help            Show this help.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=1
      ;;
    --include-system-disk)
      INCLUDE_SYSTEM_DISK=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage
      exit 1
      ;;
  esac
done

if ! command -v lsblk >/dev/null 2>&1; then
  echo "Error: lsblk is required but not installed." >&2
  exit 1
fi

if ! command -v udisksctl >/dev/null 2>&1; then
  echo "Error: udisksctl is required. Install package: udisks2" >&2
  exit 1
fi

root_source="$(findmnt -n -o SOURCE / || true)"
root_pkname=""
if [[ -n "$root_source" && "$root_source" == /dev/* ]]; then
  root_pkname="$(lsblk -no PKNAME "$root_source" 2>/dev/null || true)"
fi

mounted_count=0
skipped_count=0
error_count=0

# Fields: NAME TYPE FSTYPE MOUNTPOINT PKNAME RO
while IFS='|' read -r name type fstype mnt pkname ro; do
  [[ "$type" == "part" ]] || continue
  [[ -n "$fstype" ]] || continue
  [[ "$fstype" != "swap" ]] || continue
  [[ -z "$mnt" ]] || { ((skipped_count+=1)); continue; }
  [[ "$ro" == "0" ]] || { ((skipped_count+=1)); continue; }

  if [[ "$INCLUDE_SYSTEM_DISK" -ne 1 && -n "$root_pkname" && "$pkname" == "$root_pkname" ]]; then
    echo "Skipping system-disk partition: $name"
    ((skipped_count+=1))
    continue
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] Would mount: $name (fstype=$fstype)"
    ((mounted_count+=1))
    continue
  fi

  if out="$(udisksctl mount -b "$name" 2>&1)"; then
    echo "Mounted: $name"
    echo "  $out"
    ((mounted_count+=1))
  else
    echo "Failed to mount: $name" >&2
    echo "  $out" >&2
    ((error_count+=1))
  fi
done < <(lsblk -rpn -o NAME,TYPE,FSTYPE,MOUNTPOINT,PKNAME,RO | awk '{
  name=$1; type=$2; fstype=$3; mnt=$4; pkname=$5; ro=$6;
  if (mnt == "") mnt="-";
  gsub(/^-$/, "", mnt);
  printf "%s|%s|%s|%s|%s|%s\n", name, type, fstype, mnt, pkname, ro;
}')

echo ""
echo "Summary: mounted=$mounted_count skipped=$skipped_count errors=$error_count"
