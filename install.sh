#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
platform="$(uname -s)"

case "$platform" in
    Darwin) deps=(tmux yabai skhd socat) ;;
    Linux) deps=(tmux sway socat) ;;
    *)
        printf 'error: unsupported platform: %s\n' "$platform" >&2
        exit 1
        ;;
esac

missing=()
for dependency in "${deps[@]}"; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        missing+=("$dependency")
    fi
done

if (( ${#missing[@]} )); then
    printf 'Missing dependencies:\n' >&2
    printf '  - %s\n' "${missing[@]}" >&2
    exit 1
fi

append_source() {
    local config_file="$1"
    local source_line="$2"

    mkdir -p "$(dirname -- "$config_file")"
    touch "$config_file"

    if grep -Fqx -- "$source_line" "$config_file"; then
        printf 'Already configured: %s\n' "$config_file"
        return
    fi

    if [[ -s "$config_file" ]]; then
        printf '\n' >> "$config_file"
    fi
    printf '# nav-bridge\n%s\n' "$source_line" >> "$config_file"
    printf 'Configured: %s\n' "$config_file"
}

install_tmux_config() {
    local config_file
    local xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

    if [[ -e "$xdg_config_home/tmux/tmux.conf" || -d "$xdg_config_home/tmux" ]]; then
        config_file="$xdg_config_home/tmux/tmux.conf"
    elif [[ -e "$HOME/.tmux.conf" ]]; then
        config_file="$HOME/.tmux.conf"
    else
        config_file="$xdg_config_home/tmux/tmux.conf"
    fi

    append_source "$config_file" "source-file \"$project_dir/tmux.conf\""
}

install_skhd_config() {
    local config_file="${SKHD_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/skhd/skhdrc}"
    append_source "$config_file" ".load \"$project_dir/skhd.conf\""
}

install_sway_config() {
    local config_file="${SWAY_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/sway/config}"
    append_source "$config_file" "include $project_dir/sway.conf"
}

escape_sed_replacement() {
    sed 's/[&|]/\\&/g' <<< "$1"
}

install_launch_agent() {
    local socat_path
    local runtime_path
    local source_plist="$project_dir/launchd/com.phil.nav-bridge.plist"
    local launch_agents_dir="$HOME/Library/LaunchAgents"
    local installed_plist="$launch_agents_dir/com.phil.nav-bridge.plist"
    local service="gui/$(id -u)/com.phil.nav-bridge"
    local temporary_plist

    socat_path="$(command -v socat || true)"
    if [[ -z "$socat_path" ]]; then
        printf 'error: socat is required for the macOS launch agent\n' >&2
        exit 1
    fi

    runtime_path="$(dirname -- "$socat_path"):/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    temporary_plist="$(mktemp)"
    trap 'rm -f "$temporary_plist"' RETURN

    sed \
        -e "s|__SOCAT__|$(escape_sed_replacement "$socat_path")|g" \
        -e "s|__NAV_LISTENER__|$(escape_sed_replacement "$project_dir/nav-listener.sh")|g" \
        -e "s|__PATH__|$(escape_sed_replacement "$runtime_path")|g" \
        "$source_plist" > "$temporary_plist"

    plutil -lint "$temporary_plist" >/dev/null
    mkdir -p "$launch_agents_dir"
    install -m 0644 "$temporary_plist" "$installed_plist"

    launchctl bootout "$service" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$installed_plist"
    launchctl enable "$service"
    launchctl kickstart -k "$service"
    printf 'Installed and started: %s\n' "$service"
}

install_tmux_config

case "$platform" in
    Darwin)
        install_skhd_config
        install_launch_agent
        ;;
    Linux)
        install_sway_config
        ;;
esac
