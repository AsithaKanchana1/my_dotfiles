source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

zoxide init fish | source
fnm env --use-on-cd | source
export PATH="$HOME/.local/bin:$PATH"

# OminiRoute Api Keyas for Cloude Code 
set -gx CLAUDE_CONFIG_DIR "$HOME/.claude-omniroute"
set -gx ANTHROPIC_BASE_URL "http://localhost:20128"
set -gx ANTHROPIC_AUTH_TOKEN sk-d12c57279fcd5450-ba3b70-e885ce99
set -gx ANTHROPIC_API_KEY ""
set -gx ANTHROPIC_MODEL ominiPack1

# Change WallPaper Alius 
alias cwp="~/.config/hypr/scripts/change_wallpaper.sh"

# pnpm
set -gx PNPM_HOME "/home/asithakanchana/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
    set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
#
#
# Yazi Open file manage 
#
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        read -l -p "echo 'Move to current Yazi directory ($cwd)? [Y/n]: '" confirm
        if test -z "$confirm" || test "$confirm" = Y || test "$confirm" = y
            builtin cd -- "$cwd"
        end
    end
    rm -f -- "$tmp"
end

# opencode
fish_add_path /home/asithakanchana/.opencode/bin
