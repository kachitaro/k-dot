# ==============================================================================
# 🚀 ZSH Configuration File (Dotfiles)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Environment Variables & Paths (Load First)
# ------------------------------------------------------------------------------
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LESSCHARSET="utf-8"

# Preferred Editor
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
    export VISUAL='nvim'
fi

# Path Setup
export PATH="$HOME/.local/bin:$PATH"

# Bun & FNM Runtime
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
[ -d "$HOME/.local/share/fnm" ] && export PATH="$HOME/.local/share/fnm:$PATH"

# Custom Config Paths
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export BAT_CONFIG_DIR="$HOME/.config/bat"
export BAT_CONFIG_PATH="$HOME/.config/bat/config"

# Dotfiles Directory Logic
if [ -z "$DOTFILES_DIR" ]; then
    if [ -n "${(%):-%x}" ]; then
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
# 2. Aliases & Utility Shortcuts
# ------------------------------------------------------------------------------
# Navigation
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'

# Basic Tools
alias g='git'
alias vi='nvim'
alias vim='nvim'

# Bat (Modern cat)
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
    alias b='bat'
fi

# Eza (Modern ls)
export EZA_COLORS="di=1;34:ln=35"
export EZA_STANDARD_OPTIONS="--color=always --icons=always --group-directories-first"

alias ls="eza $EZA_STANDARD_OPTIONS"
alias ll="eza -al $EZA_STANDARD_OPTIONS --git --time-style=long-iso --color-scale"
alias la="eza -a $EZA_STANDARD_OPTIONS"
alias lt="eza -a --tree --level=3 $EZA_STANDARD_OPTIONS"

# ------------------------------------------------------------------------------
# 3. Completion Base (Compinit)
# ------------------------------------------------------------------------------
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ------------------------------------------------------------------------------
# 4. Modern CLI Tools & Completion Initializations
# ------------------------------------------------------------------------------

# Zoxide (Modern cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Atuin (SQLite Shell History) environment
[ -f "$HOME/.atuin/bin/env" ] && source "$HOME/.atuin/bin/env"

# Fzf (Fuzzy Finder) environment
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --info=inline"
    export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza -a --tree --level=2 --color=always --icons=always {}; else bat --color=always --style=numbers,changes {}; fi' --preview-window 'right:55%,border-left' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    export FZF_ALT_C_OPTS="--preview 'eza -a --tree --level=2 --color=always --icons=always {}' --preview-window 'right:55%,border-left' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
fi

if [ -f "$DOTFILES_DIR/themes/generated/init.zsh" ]; then
    source "$DOTFILES_DIR/themes/generated/init.zsh"
else
    # Fallback: chạy trực tiếp các lệnh khởi tạo
    command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"
    command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
    command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell zsh)"
    command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
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

# Load Theme
if [ -f "$DOTFILES_DIR/themes/generated/theme.sh" ]; then
    source "$DOTFILES_DIR/themes/generated/theme.sh"
elif [ -f "$HOME/.dotfiles/themes/generated/theme.sh" ]; then
    source "$HOME/.dotfiles/themes/generated/theme.sh"
fi

# ------------------------------------------------------------------------------
# 6. ZSH Plugins (Must be loaded at the very end!)
# ------------------------------------------------------------------------------
if [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# NOTE: zsh-syntax-highlighting MUST be the LAST plugin sourced!
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
