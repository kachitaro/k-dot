# 🛠️ Cross-Platform Dotfiles & Dev Environment

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/anhtai2k)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

🌐 **Language**: **English** | [Tiếng Việt](README.vi.md)

A personal cross-platform dotfiles suite for **PowerShell 7**, **Bash / Zsh**, modern CLI tools, **WezTerm** GPU terminal emulator, and **Neovim (NvChad)** IDE, powered by a native Rust management CLI (`k-dot` / `dot`) & **Theme Engine**.

Rebuild your development environment on **Windows 11/10** and **Linux / WSL / macOS** with a single command.

---

## 📸 Showcase & Preview

![Dotfiles Terminal & Neovim Preview](assets/showcase.png)

## 📑 Table of Contents

- [📸 Showcase & Preview](#-showcase--preview)
- [📁 Repository Structure](#-repository-structure)
- [🚀 Installation Guide](#-installation-guide)
- [🔄 Migration Guide (For Existing Users)](#-migration-guide-for-existing-users)
- [🧰 Management with `dot` CLI](#-management-with-dot-cli-rust-powered)
- [🎨 Theme Engine & Shell Cache](#-theme-engine--shell-cache)
- [⌨️ Keybindings & Utilities](#️-keybindings--utilities)
- [🩺 Troubleshooting](#-troubleshooting)
- [🧑‍💻 Development & Release](#-development--release)
- [☕ Support / Donate](#-support--donate)
- [📜 License](#-license)

---

## 📁 Repository Structure

```
k-dot/
├── .github/workflows/       # ⚙️ CI (test, lint) & Release (build + publish binaries)
├── apps/                    # 📦 Application configurations (Auto-discovered by 'dot')
│   ├── bat/                 # Syntax-highlighted cat alternative
│   ├── nvim/                # Neovim IDE configuration (NvChad)
│   ├── powershell/          # PowerShell 7 profile & functions
│   ├── scoop/               # Scoop package manager configs
│   ├── shell/               # POSIX Shell profiles (.bashrc, .zshrc)
│   ├── starship/            # Starship cross-shell prompt
│   └── wezterm/             # WezTerm GPU terminal emulator
├── assets/                  # 🖼️ Screenshots for this README
├── cli/                     # 🦀 Native Rust CLI ('dot' / 'k-dot')
├── themes/                  # 🎨 Single-source-of-truth Theme Engine
│   ├── theme.json           # Palette configuration (default: VS Code Dark Modern)
│   └── generated/           # Compiled theme & cached shell init scripts
├── install.ps1              # Windows setup script
├── install.sh               # Linux/macOS setup script
└── README.md                # Documentation
```

Every folder inside `apps/` is linked to `~/.config/<name>` by `dot inject`. The exceptions are `shell/` and `powershell/`: those are loaded by a line that `dot inject` adds to your shell profiles (`~/.bashrc`, `~/.zshrc`, PowerShell `$PROFILE`).

---

## 🚀 Installation Guide

### 1. Windows (PowerShell)

Open **PowerShell** (Run as Administrator recommended for full setup) and run:

```powershell
# ⚡ Fast Install: Downloads dot CLI binary & syncs configs immediately
irm https://raw.githubusercontent.com/kachitaro/k-dot/main/install.ps1 | iex

# 🚀 Full Machine Setup: Installs Scoop, Neovim, WezTerm, Font, Node, Tools & virtualization
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/kachitaro/k-dot/main/install.ps1))) -Full
```

`install.ps1` options:

| Option          | Effect                                                                 |
| :-------------- | :--------------------------------------------------------------------- |
| `-Full`         | Also install Scoop, packages, PowerShell modules and Windows features  |
| `-SkipFeatures` | With `-Full`: do not enable WSL / Hyper-V / Virtual Machine Platform   |
| `-ForceInstall` | Re-download `dot.exe` and overwrite existing configs without backup    |
| `-DotfilesDir`  | Use a custom dotfiles folder (default: `~\.dotfiles`)                  |

### 2. Linux / macOS

Open **Terminal** and run:

```bash
# ⚡ Fast Install: Downloads pre-built dot binary & syncs configs immediately
curl -fsSL https://raw.githubusercontent.com/kachitaro/k-dot/main/install.sh | bash

# 🚀 Full Machine Setup: Installs system packages (apt/brew/pacman), Starship & Tools
curl -fsSL https://raw.githubusercontent.com/kachitaro/k-dot/main/install.sh | bash -s -- --full
```

Pre-built binaries are published for Linux (x86_64, aarch64) and macOS (Apple Silicon, Intel). On other platforms the installer builds the CLI with Cargo if it is available.

### 3. Run Directly from Cloned Repo

```bash
# Windows
.\install.ps1        # or .\install.ps1 -Full

# Linux/macOS
./install.sh         # or ./install.sh --full
```

> [!IMPORTANT]
> After a full install on Windows, **restart your machine** to apply Hyper-V, WSL, and font settings. On Linux/macOS, run `source ~/.bashrc` or open a new terminal tab.

### 4. Overwrite & Uninstall

| Action                                              | Windows                       | Linux/macOS              |
| :-------------------------------------------------- | :---------------------------- | :----------------------- |
| Overwrite (skip backup)                             | `.\install.ps1 -ForceInstall` | `./install.sh --force`   |
| Uninstall (remove symlinks, restore original shell) | `dot uninstall`               | `dot uninstall`          |

Without the overwrite option, any existing file or folder is renamed to `<name>.bak_<timestamp>` before it is replaced by a link.

---

## 🔄 Migration Guide (For Existing Users)

If you previously installed/cloned this dotfiles suite with the old flat root structure, follow these steps to transition cleanly to the `apps/` structure:

```bash
# 1. Unlink legacy symlinks pointing to old root paths
dot eject

# 2. Pull the latest repository changes containing the apps/ directory
git pull

# 3. (If using prebuilt CLI) Update your dot binary
dot update

# 4. Re-link all configurations to the new apps/ structure
dot inject --force
```

> [!NOTE]
> The repository was renamed from `kachitaro/dotfiles` to `kachitaro/k-dot`. GitHub still redirects the old URL, but you can point your clone at the new one:
> `git remote set-url origin https://github.com/kachitaro/k-dot.git`

---

## 🧰 Management with `dot` CLI (Rust-powered)

The management CLI (`k-dot` / `dot`) is written in **Rust** for blazing-fast startup, robust cross-platform path resolution, and native symlink handling without runtime dependencies.

```bash
dot init [path] [--force]        # Initialize standalone dotfiles workspace (default ~/.dotfiles) with starter theme.json
dot install [--force]            # Run the platform installer (install.ps1 / install.sh)
dot update                       # Self-update CLI binary (dot) to latest version from GitHub Release (SHA-256 verified)
dot add <path>                   # Adopt a config into apps/ folder (e.g. dot add ~/.config/alacritty)
dot eject                        # Unlink dotfiles and restore independent real files to system
dot inject [--force]             # Re-link configs, re-add shell profile lines and rebuild theme & shell caches
dot uninstall                    # Fully uninstall dotfiles
dot theme reload                 # Recompile theme.json and regenerate shell caches
dot theme path                   # Print absolute path of themes/generated directory (for dynamic scripts)
dot --help                       # Display help menu
```

The CLI finds your dotfiles folder from the `DOTFILES_DIR` environment variable first (set by the installers), then from the location of the binary, then the current directory, and finally `~/.dotfiles`.

On Windows, links are created as symlinks when possible (requires Developer Mode or admin rights). If that fails, folders fall back to junctions and files are copied.

### 🦀 Build CLI from Source

To compile the CLI binary manually:

```bash
cd cli
cargo build --release
```

#### Cross-compilation Targets:
- **Windows (MSVC)**: `cargo build --release --target x86_64-pc-windows-msvc`
- **Linux (x86_64)**: `cargo build --release --target x86_64-unknown-linux-gnu`
- **macOS (Apple Silicon)**: `cargo build --release --target aarch64-apple-darwin`

---

## 🎨 Theme Engine & Shell Cache

All colors across Neovim, WezTerm, Starship, bat, Bash, Zsh, and PowerShell are synchronized from a **single source of truth**: `themes/theme.json`.

1. Edit colors in `themes/theme.json`.
2. Run `dot theme reload` (or `dot inject`).
3. The built-in Rust Theme Engine compiles the JSON into:
   - `themes/generated/theme.lua` (WezTerm & Neovim)
   - `themes/generated/theme.sh` (Bash & Zsh)
   - `themes/generated/theme.ps1` (PowerShell)
   - `apps/starship/starship.toml` (Starship Prompt Palette)
   - `apps/bat/config` (bat theme)
4. WezTerm and Neovim reload the new colors automatically. Open a new shell tab to apply them to the prompt.

Current default theme: **VS Code Dark Modern**.

### ⚡ Shell Cache (Fast Startup)

The same commands also write precompiled init scripts so shells do not have to spawn every tool on startup:

- `themes/generated/init.ps1` / `init.bash` / `init.zsh` contain the frozen init output of **Starship**, **zoxide** and (Bash/Zsh) **fzf**.
- **fnm** is intentionally **not** cached: `fnm env` creates a per-session folder and prints the current `PATH`, so it runs live in every new shell.
- These files contain absolute paths of the machine that generated them, so they are listed in `.gitignore`. Re-run `dot theme reload` after installing or moving any of these tools.

On PowerShell, the **PSFzf** module is loaded on the first `Ctrl + F` press instead of at startup.

---

## ⌨️ Keybindings & Utilities

### WezTerm

| Keybinding          | Action                                         |
| :------------------ | :--------------------------------------------- |
| `Ctrl + Shift + \|` | Split pane left / right                        |
| `Ctrl + Shift + D`  | Split pane top / bottom                        |
| `Ctrl + Shift + P`  | Disabled (frees the key for the shell / Neovim) |

### Core Shell & Shell Tools

| Keybinding / Command   | Description                                                                          |
| :--------------------- | :----------------------------------------------------------------------------------- |
| `Ctrl + R`             | **FZF** fuzzy history search (Bash/Zsh) / **PSReadLine** reverse search (PowerShell) |
| `Ctrl + T`             | *(Bash/Zsh)* **FZF** file finder with preview                                        |
| `Alt + C`              | *(Bash/Zsh)* **FZF** jump into a sub-directory                                       |
| `Ctrl + F`             | *(PowerShell)* **PSFzf** file finder                                                 |
| `z <dir>` / `zi`       | **Zoxide** jump to a frequently used directory (`zi` = interactive)                  |
| `g`                    | Alias for `git`                                                                      |
| `vi`, `vim`            | Alias for `nvim`                                                                     |
| `ls`, `ll`, `la`, `lt` | **Eza** modern file listings (icons, git status, tree view)                          |
| `cat <file>`, `b`      | **Bat** file viewer with syntax highlighting (`b` uses the pager)                    |

### PowerShell Utilities

| Command                | Description                                                                   |
| :--------------------- | :---------------------------------------------------------------------------- |
| `grep`, `find`         | Linux-style wrappers around `rg` and `fd` (fall back to built-in cmdlets)     |
| `which`, `touch`       | Linux-style helpers                                                           |
| `Get-SystemSizeReport` | Size of `C:\Windows`, Program Files and `C:\Users` compared to a clean install |
| `Get-AppSizeReport`    | Installed applications sorted by disk usage (Program Files, AppData, Scoop)   |

### Bash / Zsh Utilities

| Command           | Description                                       |
| :---------------- | :------------------------------------------------ |
| `get_system_size` | Disk usage of `/` and the 10 largest folders in `~` |
| `cd..`, `cd...`   | Go up one / two directories                       |

---

## 🩺 Troubleshooting

**PowerShell changes do not take effect / startup is still slow.**
PowerShell loads up to four profile files. If one of them still loads an old copy of `user_profile.ps1`, the dotfiles profile sees it as "already loaded" and stops. List them and check each one:

```powershell
$PROFILE | Select-Object *
```

Every profile that loads the dotfiles should point to `$env:DOTFILES_DIR\apps\powershell\user_profile.ps1`. Scoop's `pwsh` keeps its all-users profile in `~\scoop\persist\pwsh\profile.ps1`.

**Node or other tools are missing from `PATH` in a new shell.**
Your shell cache was generated by an older `dot` that froze `PATH` into it. Run `dot update`, then `dot theme reload`.

**Measure PowerShell startup time:**

```powershell
Measure-Command { pwsh -NoLogo -Command exit }
```

---

## 🧑‍💻 Development & Release

Branches:

```
feature/* ──PR──▶ develop ──PR──▶ release ──▶ GitHub Release (vX.Y.Z)
                                     └──PR──▶ main
```

- **CI** (`.github/workflows/ci.yml`) runs `cargo check`, `cargo fmt --check`, `cargo clippy -D warnings` and `cargo test` on Windows, Linux and macOS, plus a syntax check of every `.ps1` file. It runs on pushes to `main` / `develop` and on pull requests to `main`, `develop` and `release`.
- **Release** (`.github/workflows/release.yml`) runs when a push to `release` (merging a PR counts) changes anything under `cli/`, on a `v*` tag, or manually. Changes that only touch docs, scripts or configs pass through `release` to `main` without publishing a new binary; run the workflow manually if you still want a release.
  1. Runs the CI tests.
  2. Picks the version: the one in `cli/Cargo.toml`, bumped by one patch until an unused tag is found. A version entered manually must not already exist.
  3. Builds the 5 binaries and publishes a GitHub Release with SHA-256 checksums. The tag points at the commit that was built.
  4. Commits the new version (`Cargo.toml` + `Cargo.lock`) back to `main` and `develop`.
- After a release, open a PR from `release` into `main` so `main` gets the code as well.

> [!WARNING]
> Never use GitHub's **Resolve conflicts** button on a PR whose head branch is `release`: it pushes a merge commit to `release` and starts another release. Resolve conflicts on a separate branch instead.

Run the same checks locally before opening a PR:

```bash
cd cli
cargo fmt -- --check
cargo clippy --all-targets -- -D warnings
cargo test
```

---

## ☕ Support / Donate

If you find this dotfiles setup useful, consider supporting:

- **Ko-fi**: [ko-fi.com/anhtai2k](https://ko-fi.com/anhtai2k)
- **Star the repo**: ⭐ Leave a star on GitHub!

---

## 📜 License

Distributed under the **MIT License**. See `LICENSE` for more information.
