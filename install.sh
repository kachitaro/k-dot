#!/usr/bin/env bash
# ==============================================================================
# 🚀 Linux / macOS Dotfiles & Dev Environment Installer
# Usage:
#   # ⚡ Fast Install: Tải CLI dot và gắn cấu hình ngay
#   curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash
#
#   # 🚀 Full Machine Setup: Cài đặt toàn bộ môi trường phần mềm
#   curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash -s -- --full
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'

FULL_INSTALL=false
FORCE_INSTALL=false

for arg in "$@"; do
    case "$arg" in
        --full)
            FULL_INSTALL=true
            ;;
        --force)
            FORCE_INSTALL=true
            ;;
    esac
done

echo -e "${MAGENTA}====================================================================${NC}"
echo -e "${MAGENTA}  [+] KACHITARO DOTFILES & DEV ENVIRONMENT INSTALLER                ${NC}"
echo -e "${MAGENTA}  Repository: https://github.com/kachitaro/dotfiles                ${NC}"
echo -e "${MAGENTA}====================================================================${NC}\n"

# 1. Determine Dotfiles Directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/apps/wezterm/wezterm.lua" ]; then
    DOTFILES_DIR="$SCRIPT_DIR"
else
    DOTFILES_DIR="$HOME/.dotfiles"
fi

# 2. Prepare ~/.local/bin
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"
export DOTFILES_DIR="$DOTFILES_DIR"

DOT_BIN="$BIN_DIR/dot"

# 3. Detect Platform & Download Binary Release
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

TARGET=""
case "$OS" in
    linux)
        case "$ARCH" in
            x86_64) TARGET="x86_64-unknown-linux-gnu" ;;
            aarch64|arm64) TARGET="aarch64-unknown-linux-gnu" ;;
        esac
        ;;
    darwin)
        case "$ARCH" in
            arm64|aarch64) TARGET="aarch64-apple-darwin" ;;
            x86_64) TARGET="x86_64-apple-darwin" ;;
        esac
        ;;
esac

INSTALLED_FROM_RELEASE=false
if [ -n "$TARGET" ]; then
    RELEASE_URL="https://github.com/kachitaro/dotfiles/releases/latest/download/dot-${TARGET}.tar.gz"
    TEMP_TAR="/tmp/dot-${TARGET}.tar.gz"
    echo -e "${CYAN}[*] Đang tải binary release (${TARGET}) từ GitHub...${NC}"
    if curl -fsSL -o "$TEMP_TAR" "$RELEASE_URL" 2>/dev/null; then
        tar -xzf "$TEMP_TAR" -C "$BIN_DIR" dot 2>/dev/null || tar -xzf "$TEMP_TAR" -C "$BIN_DIR"
        chmod +x "$DOT_BIN"
        rm -f "$TEMP_TAR"
        INSTALLED_FROM_RELEASE=true
        echo -e "  ${GREEN}[+] Đã tải và thiết lập binary 'dot' tại $DOT_BIN${NC}"
    else
        echo -e "  ${YELLOW}[!] Không thể tải binary release từ GitHub (offline hoặc chưa phát hành).${NC}"
    fi
fi

if [ "$INSTALLED_FROM_RELEASE" = false ]; then
    LOCAL_RELEASE="$DOTFILES_DIR/cli/target/release/dot"
    if [ -f "$LOCAL_RELEASE" ]; then
        cp "$LOCAL_RELEASE" "$DOT_BIN"
        chmod +x "$DOT_BIN"
        echo -e "  ${GREEN}[+] Đã dùng binary có sẵn tại $DOT_BIN${NC}"
    elif command -v cargo >/dev/null 2>&1 && [ -f "$DOTFILES_DIR/cli/Cargo.toml" ]; then
        echo -e "${CYAN}[*] Biên dịch CLI từ mã nguồn qua Cargo...${NC}"
        cargo build --release --manifest-path "$DOTFILES_DIR/cli/Cargo.toml"
        if [ -f "$LOCAL_RELEASE" ]; then
            cp "$LOCAL_RELEASE" "$DOT_BIN"
            chmod +x "$DOT_BIN"
            echo -e "  ${GREEN}[+] Đã biên dịch thành công 'dot' vào $DOT_BIN${NC}"
        fi
    fi
fi

# 4. Full Machine Environment Setup (--full)
if [ "$FULL_INSTALL" = true ]; then
    echo -e "${CYAN}[*] Đang cài đặt các công cụ hệ thống...${NC}"
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y
        sudo apt-get install -y git curl wget unzip build-essential ripgrep fzf zoxide
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Syu --noconfirm git curl wget unzip base-devel ripgrep fd fzf bat eza zoxide
    elif command -v brew >/dev/null 2>&1; then
        brew install git curl ripgrep fd fzf bat eza zoxide starship neovim
    fi

    # Starship
    if ! command -v starship >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$BIN_DIR"
    fi

    # Clone dotfiles repo if missing
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo -e "${CYAN}[*] Đang clone dotfiles repository về $DOTFILES_DIR...${NC}"
        if command -v git >/dev/null 2>&1; then
            mkdir -p "$(dirname "$DOTFILES_DIR")"
            git clone https://github.com/kachitaro/dotfiles.git "$DOTFILES_DIR"
            echo -e "  ${GREEN}[+] Dotfiles đã sẵn sàng tại $DOTFILES_DIR${NC}"
        fi
    fi
fi

# 5. Inject Configurations
if [ -x "$DOT_BIN" ]; then
    echo -e "${CYAN}[*] Đồng bộ liên kết cấu hình qua 'dot inject'...${NC}"
    INJECT_ARGS=("inject")
    if [ "$FORCE_INSTALL" = true ]; then INJECT_ARGS+=("--force"); fi
    "$DOT_BIN" "${INJECT_ARGS[@]}"
fi

echo -e "\n${GREEN}====================================================================${NC}"
echo -e "${GREEN}  [+] HOAN TAT THIET LAP KACHITARO DOTFILES!                        ${NC}"
echo -e "${GREEN}====================================================================${NC}"
echo -e "  * Lenh 'dot' da san sang trong PATH (~/.local/bin)."
echo -e "  * Ban co the dung 'dot --help' de xem toan bo huong dan."
echo -e "${GREEN}====================================================================${NC}\n"
