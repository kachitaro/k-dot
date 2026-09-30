# ==============================================================================
# Dotfiles Shell Configuration (Bash & Zsh compatible for Linux / macOS)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Environment Variables & Paths
# ------------------------------------------------------------------------------
# UTF-8 Encoding
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LESSCHARSET="utf-8"

# Xử lý PATH cho local bin (Quan trọng để chạy các tool như bat qua symlink)
export PATH="$HOME/.local/bin:$PATH"

# Bun & FNM (Thêm vào PATH an toàn)
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
[ -d "$HOME/.local/share/fnm" ] && export PATH="$HOME/.local/share/fnm:$PATH"

# Eza colors & Custom Config Paths
export EZA_COLORS="di=36"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export BAT_CONFIG_DIR="$HOME/.config/bat"
export BAT_CONFIG_PATH="$HOME/.config/bat/config"

# Dotfiles Directory Logic
if [ -z "$DOTFILES_DIR" ]; then
    if [ -n "$BASH_VERSION" ] && [ -n "${BASH_SOURCE[0]}" ]; then
        _CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
        if [ -d "$_CURRENT_DIR/../../themes" ]; then
            DOTFILES_DIR="$(cd "$_CURRENT_DIR/../.." 2>/dev/null && pwd)"
        else
            DOTFILES_DIR="$(cd "$_CURRENT_DIR/.." 2>/dev/null && pwd)"
        fi
        unset _CURRENT_DIR
    elif [ -n "$ZSH_VERSION" ]; then
        _CURRENT_DIR="$(dirname "${(%):-%x}")"
        if [ -d "$_CURRENT_DIR/../../themes" ]; then
            DOTFILES_DIR="$(cd "$_CURRENT_DIR/../.." 2>/dev/null && pwd)"
        else
            DOTFILES_DIR="$(cd "$_CURRENT_DIR/.." 2>/dev/null && pwd)"
        fi
        unset _CURRENT_DIR
    fi
fi
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# ------------------------------------------------------------------------------
# 2. Base Configuration & Editors
# ------------------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
    export VISUAL='nvim'
    alias vi='nvim'
    alias vim='nvim'
fi

# ------------------------------------------------------------------------------
# 3. Aliases
# ------------------------------------------------------------------------------
alias g='git'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'

# --- Eza (Modern ls) ---
if command -v eza >/dev/null 2>&1; then
    export EZA_STANDARD_OPTIONS="--color=always --icons=always --group-directories-first"
    alias ls="eza $EZA_STANDARD_OPTIONS"
    alias ll="eza -al $EZA_STANDARD_OPTIONS --git --time-style=long-iso --color-scale"
    alias la="eza -a $EZA_STANDARD_OPTIONS"
    alias lt="eza -a --tree --level=3 $EZA_STANDARD_OPTIONS"
else
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# --- Bat (Modern cat) ---
# Xử lý trường hợp Ubuntu cài thành batcat
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
    alias b='bat'
fi

# ------------------------------------------------------------------------------
# 4. Tool Initializations (Lazy Load / Check)
# ------------------------------------------------------------------------------

# Detect current shell (zsh or bash)
CURRENT_SHELL=$(basename "$SHELL")

# Fzf environment configuration
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --info=inline"
    export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza -a --tree --level=2 --color=always --icons=always {}; else bat --color=always --style=numbers,changes {}; fi' --preview-window 'right:55%,border-left' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    export FZF_ALT_C_OPTS="--preview 'eza -a --tree --level=2 --color=always --icons=always {}' --preview-window 'right:55%,border-left' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
fi

# Nạp file cache khởi động đóng băng nếu có; fallback sang chạy động nếu chưa tạo cache
if [ -f "$DOTFILES_DIR/themes/generated/init.bash" ]; then
    source "$DOTFILES_DIR/themes/generated/init.bash"
else
    # Fallback: chạy trực tiếp các lệnh khởi tạo
    if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd --shell $CURRENT_SHELL)"
    fi

    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init $CURRENT_SHELL)"
    fi

    if command -v fzf >/dev/null 2>&1; then
        if [ "$CURRENT_SHELL" = "zsh" ]; then
            for f in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/share/fzf/key-bindings.zsh /usr/share/fzf/shell/key-bindings.zsh ~/.fzf.zsh; do
                [ -f "$f" ] && source "$f" && break
            done
            for f in /usr/share/doc/fzf/examples/completion.zsh /usr/share/fzf/completion.zsh /usr/share/fzf/shell/completion.zsh; do
                [ -f "$f" ] && source "$f" && break
            done
        elif [ "$CURRENT_SHELL" = "bash" ]; then
            for f in /usr/share/doc/fzf/examples/key-bindings.bash /usr/share/fzf/key-bindings.bash /usr/share/fzf/shell/key-bindings.bash ~/.fzf.bash; do
                [ -f "$f" ] && source "$f" && break
            done
            for f in /usr/share/doc/fzf/examples/completion.bash /usr/share/fzf/completion.bash /usr/share/fzf/shell/completion.bash; do
                [ -f "$f" ] && source "$f" && break
            done
        fi
    fi
fi

# ------------------------------------------------------------------------------
# 5. Functions & Themes
# ------------------------------------------------------------------------------
get_system_size() {
    echo -e "\033[0;32m====== Disk Usage Report ======\033[0m"
    df -h /
    echo ""
    echo -e "\033[0;32m====== Top 10 Largest Directories in Home ======\033[0m"
    du -h -d 2 "$HOME" 2>/dev/null | sort -hr | head -n 10
}

# Load Themes
if [ -f "$DOTFILES_DIR/themes/generated/theme.sh" ]; then
    source "$DOTFILES_DIR/themes/generated/theme.sh"
elif [ -f "$HOME/.dotfiles/themes/generated/theme.sh" ]; then
    source "$HOME/.dotfiles/themes/generated/theme.sh"
fi