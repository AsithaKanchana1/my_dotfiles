source /usr/share/cachyos-fish-config/cachyos-config.fish

# Enable zoxide commands in Fish (`z` and `zi`).
if type -q zoxide
    zoxide init fish | source
end

# Yazi wrapper: jump to the directory selected in Yazi.
function y --description "Open Yazi and cd to the selected directory"
    set -l tmp (mktemp -t yazi-cwd.XXXXXX)
    yazi $argv --cwd-file="$tmp"

    if test -f "$tmp"
        set -l cwd (cat "$tmp")
        if test -n "$cwd" -a "$cwd" != "$PWD"
            read -l -P "Keep terminal in this folder? $cwd [Y/n]: " ans
            set -l normalized (string lower -- (string trim -- "$ans"))

            # Default to yes on Enter; press n/no explicitly to stay.
            if test -z "$normalized"
                cd "$cwd"
            else if contains -- "$normalized" y yes
                cd "$cwd"
            else if contains -- "$normalized" n no
                true
            else
                cd "$cwd"
            end
        end
    end

    rm -f "$tmp"
end
