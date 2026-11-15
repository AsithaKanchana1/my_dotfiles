source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# zoxide shortcuts
z() {
	local dir
	dir="$(zoxide query "$@")" || return
	cd -- "$dir"
}

zi() {
	local dir
	dir="$(zoxide query -i "$@")" || return
	cd -- "$dir"
}

# Yazi wrapper: optionally move to the last directory selected in Yazi
y() {
	local tmp cwd
	tmp="$(mktemp -t yazi-cwd.XXXXXX)"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		if whiptail --title "Yazi Exit" --yesno "Keep terminal in this folder?\n\n$cwd" 10 55; then
			cd -- "$cwd"
		fi
	fi
	rm -f -- "$tmp"
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"



export PATH="$PATH:$HOME/development/flutter/bin:$HOME/Android/Sdk/platform-tools:$HOME/Android/Sdk/emulator:$HOME/Android/Sdk/cmdline-tools/latest/bin"
