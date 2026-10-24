# 🛠️ Bộ Dotfiles & Môi trường phát triển Đa nền tảng

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/anhtai2k)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

🌐 **Ngôn ngữ**: [English](README.md) | **Tiếng Việt**

Bộ dotfiles cá nhân được tối ưu hoá cho **PowerShell 7**, **Bash / Zsh**, các công cụ dòng lệnh hiện đại, **WezTerm** GPU terminal emulator, và **Neovim (NvChad)** IDE, được quản lý toàn diện bởi công cụ CLI viết bằng Rust (`k-dot` / `dot`) & **Theme Engine**.

Thiết lập lại toàn bộ môi trường lập trình của bạn trên **Windows 11/10** và **Linux / WSL / macOS** chỉ bằng 1 dòng lệnh duy nhất.

---

## 📸 Hình ảnh giao diện

![Xem trước Terminal & Neovim](assets/showcase.png)

## 📑 Mục lục

- [📸 Hình ảnh giao diện](#-hình-ảnh-giao-diện)
- [📁 Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [🚀 Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
- [🔄 Hướng dẫn nâng cấp (Migration Guide)](#-hướng-dẫn-nâng-cấp-migration-guide)
- [🧰 Quản lý bằng CLI `dot`](#-quản-lý-bằng-cli-dot-rust)
- [🎨 Theme Engine & Shell Cache](#-theme-engine--shell-cache)
- [⌨️ Phím tắt & Tiện ích](#️-phím-tắt--tiện-ích)
- [🩺 Xử lý sự cố](#-xử-lý-sự-cố)
- [🧑‍💻 Phát triển & Phát hành](#-phát-triển--phát-hành)
- [☕ Ủng hộ / Donate](#-ủng-hộ--donate)
- [📜 Giấy phép](#-giấy-phép)

---

## 📁 Cấu trúc thư mục

```
k-dot/
├── .github/workflows/       # ⚙️ CI (test, lint) & Release (build + phát hành binary)
├── apps/                    # 📦 Cấu hình các ứng dụng (Được CLI 'dot' tự động quét và map)
│   ├── bat/                 # Xem nội dung tệp có highlight cú pháp
│   ├── nvim/                # Cấu hình Neovim IDE (NvChad)
│   ├── powershell/          # Profile & hàm tiện ích PowerShell 7
│   ├── scoop/               # Cấu hình trình quản lý gói Scoop
│   ├── shell/               # POSIX Shell profiles (.bashrc, .zshrc)
│   ├── starship/            # Prompt thanh trạng thái cross-shell
│   └── wezterm/             # Terminal emulator WezTerm
├── assets/                  # 🖼️ Ảnh minh hoạ cho README
├── cli/                     # 🦀 CLI quản lý viết bằng Rust ('dot' / 'k-dot')
├── themes/                  # 🎨 Single-source-of-truth Theme Engine
│   ├── theme.json           # Bảng màu cấu hình (mặc định: VS Code Dark Modern)
│   └── generated/           # Theme đã biên dịch & script cache shell tĩnh
├── install.ps1              # Script cài đặt tự động cho Windows
├── install.sh               # Script cài đặt tự động cho Linux/macOS
└── README.vi.md             # Tài liệu hướng dẫn
```

Mỗi thư mục trong `apps/` được `dot inject` liên kết tới `~/.config/<tên>`. Ngoại lệ là `shell/` và `powershell/`: hai thư mục này được nạp qua một dòng mà `dot inject` thêm vào profile của shell (`~/.bashrc`, `~/.zshrc`, `$PROFILE` của PowerShell).

---

## 🚀 Hướng dẫn cài đặt

### 1. Windows (PowerShell)

Mở **PowerShell** (Khuyến khích Run as Administrator nếu cài đặt toàn diện) và chạy:

```powershell
# ⚡ Cài đặt nhanh: Tự động tải binary dot release & gắn symlink cấu hình ngay lập tức
irm https://raw.githubusercontent.com/kachitaro/k-dot/main/install.ps1 | iex

# 🚀 Cài đặt máy mới toàn diện: Tự động cài Scoop, Neovim, WezTerm, Font, Node, Tools & ảo hoá
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/kachitaro/k-dot/main/install.ps1))) -Full
```

Các tuỳ chọn của `install.ps1`:

| Tuỳ chọn        | Tác dụng                                                                 |
| :-------------- | :----------------------------------------------------------------------- |
| `-Full`         | Cài thêm Scoop, các gói phần mềm, module PowerShell và tính năng Windows |
| `-SkipFeatures` | Dùng cùng `-Full`: không bật WSL / Hyper-V / Virtual Machine Platform    |
| `-ForceInstall` | Tải lại `dot.exe` và ghi đè cấu hình hiện có mà không sao lưu            |
| `-DotfilesDir`  | Dùng thư mục dotfiles tuỳ chọn (mặc định: `~\.dotfiles`)                 |

### 2. Linux / macOS

Mở **Terminal** và chạy:

```bash
# ⚡ Cài đặt nhanh: Tự động tải binary dot release & gắn symlink cấu hình ngay lập tức
curl -fsSL https://raw.githubusercontent.com/kachitaro/k-dot/main/install.sh | bash

# 🚀 Cài đặt máy mới toàn diện: Tự động cài package hệ thống (apt/brew/pacman), Starship & Tools
curl -fsSL https://raw.githubusercontent.com/kachitaro/k-dot/main/install.sh | bash -s -- --full
```

Binary dựng sẵn có cho Linux (x86_64, aarch64) và macOS (Apple Silicon, Intel). Trên nền tảng khác, script sẽ tự biên dịch CLI bằng Cargo nếu máy có Cargo.

### 3. Chạy trực tiếp từ repo đã clone

```bash
# Windows
.\install.ps1        # hoặc .\install.ps1 -Full

# Linux/macOS
./install.sh         # hoặc ./install.sh --full
```

> [!IMPORTANT]
> Sau khi cài toàn diện trên Windows, **khởi động lại máy** để áp dụng Hyper-V, WSL và font. Trên Linux/macOS, chạy `source ~/.bashrc` hoặc mở tab terminal mới.

### 4. Cài đè & gỡ cài đặt

| Thao tác                                           | Windows                       | Linux/macOS              |
| :------------------------------------------------- | :---------------------------- | :----------------------- |
| Cài đè, bỏ qua sao lưu                             | `.\install.ps1 -ForceInstall` | `./install.sh --force`   |
| Gỡ cài đặt (xoá symlink, khôi phục môi trường gốc) | `dot uninstall`               | `dot uninstall`          |

Nếu không dùng tuỳ chọn cài đè, file hoặc thư mục đang có sẽ được đổi tên thành `<tên>.bak_<timestamp>` trước khi bị thay bằng liên kết.

---

## 🔄 Hướng dẫn nâng cấp (Migration Guide)

Nếu bạn đã cài đặt dotfiles trước đó với cấu trúc thư mục cũ ở gốc repo, hãy thực hiện các bước sau để chuyển đổi an toàn sang cấu trúc `apps/` mới:

```bash
# 1. Gỡ bỏ toàn bộ symlink cũ đang trỏ vào gốc repo
dot eject

# 2. Kéo cập nhật mới nhất chứa cấu trúc thư mục apps/
git pull

# 3. (Nếu dùng binary CLI) Cập nhật binary dot lên bản mới
dot update

# 4. Tạo lại symlink đồng bộ theo cấu trúc apps/ mới
dot inject --force
```

> [!NOTE]
> Repo đã đổi tên từ `kachitaro/dotfiles` thành `kachitaro/k-dot`. GitHub vẫn tự chuyển hướng link cũ, nhưng bạn nên trỏ bản clone sang địa chỉ mới:
> `git remote set-url origin https://github.com/kachitaro/k-dot.git`

---

## 🧰 Quản lý bằng CLI `dot` (Rust)

Công cụ dòng lệnh quản lý (`k-dot` / `dot`) được viết hoàn toàn bằng **Rust** cho tốc độ khởi động siêu nhanh, xử lý đường dẫn / symlink an toàn và không phụ thuộc runtime bên ngoài.

```bash
dot init [path] [--force]        # Khởi tạo kho dotfiles độc lập (mặc định ~/.dotfiles) kèm theme.json mẫu
dot install [--force]            # Chạy script cài đặt của nền tảng (install.ps1 / install.sh)
dot update                       # Tự cập nhật CLI binary (dot) lên bản mới nhất từ GitHub Release (có kiểm tra SHA-256)
dot add <path>                   # Thu nạp một config vào thư mục apps/ trong kho (vd: dot add ~/.config/alacritty)
dot eject                        # Gỡ symlink, trả file thực về máy (hoạt động độc lập)
dot inject [--force]             # Gắn lại liên kết, thêm lại dòng nạp profile, tạo lại theme & cache shell
dot uninstall                    # Gỡ cài đặt hoàn toàn
dot theme reload                 # Biên dịch lại theme.json và tạo lại cache shell
dot theme path                   # In ra đường dẫn tuyệt đối của themes/generated (để script lấy path động)
dot --help                       # Hiển thị menu trợ giúp
```

CLI tìm thư mục dotfiles theo thứ tự: biến môi trường `DOTFILES_DIR` (do script cài đặt đặt sẵn), vị trí của file binary, thư mục hiện tại, rồi cuối cùng là `~/.dotfiles`.

Trên Windows, liên kết được tạo dưới dạng symlink nếu có thể (cần bật Developer Mode hoặc quyền admin). Nếu không được, thư mục sẽ dùng junction và file sẽ được copy.

### 🦀 Tự biên dịch CLI từ mã nguồn (Build from source)

Để tự biên dịch binary CLI:

```bash
cd cli
cargo build --release
```

#### Các lệnh build mẫu cho từng nền tảng (Cross-compilation):
- **Windows (MSVC)**: `cargo build --release --target x86_64-pc-windows-msvc`
- **Linux (x86_64)**: `cargo build --release --target x86_64-unknown-linux-gnu`
- **macOS (Apple Silicon)**: `cargo build --release --target aarch64-apple-darwin`

---

## 🎨 Theme Engine & Shell Cache

Toàn bộ màu sắc của Neovim, WezTerm, Starship, bat, Bash, Zsh và PowerShell được đồng bộ từ **một nguồn sự thật duy nhất**: `themes/theme.json`.

1. Sửa màu trong `themes/theme.json`.
2. Chạy `dot theme reload` (hoặc `dot inject`).
3. Rust Theme Engine biên dịch JSON ra:
   - `themes/generated/theme.lua` (WezTerm & Neovim)
   - `themes/generated/theme.sh` (Bash & Zsh)
   - `themes/generated/theme.ps1` (PowerShell)
   - `apps/starship/starship.toml` (Bảng màu Starship Prompt)
   - `apps/bat/config` (Theme của bat)
4. WezTerm và Neovim tự nạp lại màu mới. Mở tab shell mới để prompt nhận màu mới.

Theme mặc định hiện tại: **VS Code Dark Modern**.

### ⚡ Shell Cache (Khởi động nhanh)

Cùng các lệnh trên cũng tạo ra script khởi tạo đã biên dịch sẵn, để shell không phải chạy từng công cụ mỗi lần mở:

- `themes/generated/init.ps1` / `init.bash` / `init.zsh` chứa sẵn output khởi tạo của **Starship**, **zoxide** và (với Bash/Zsh) **fzf**.
- **fnm** cố ý **không** được cache: `fnm env` tạo một thư mục riêng cho từng phiên shell và in ra `PATH` hiện tại, nên nó phải chạy trực tiếp mỗi lần mở shell.
- Các file này chứa đường dẫn tuyệt đối của máy tạo ra chúng, nên được đưa vào `.gitignore`. Hãy chạy lại `dot theme reload` sau khi cài mới hoặc di chuyển các công cụ trên.

Trên PowerShell, module **PSFzf** chỉ được nạp ở lần bấm `Ctrl + F` đầu tiên thay vì lúc mở shell.

---

## ⌨️ Phím tắt & Tiện ích

### WezTerm

| Phím tắt            | Thao tác                                        |
| :------------------ | :---------------------------------------------- |
| `Ctrl + Shift + \|` | Chia màn hình trái / phải                       |
| `Ctrl + Shift + D`  | Chia màn hình trên / dưới                       |
| `Ctrl + Shift + P`  | Đã tắt (nhường phím cho shell / Neovim)         |

### Core Shell & Shell Tools

| Phím tắt / Lệnh        | Mô tả                                                                            |
| :--------------------- | :------------------------------------------------------------------------------- |
| `Ctrl + R`             | **FZF** tìm kiếm lịch sử lệnh (Bash/Zsh) / **PSReadLine** tìm ngược (PowerShell) |
| `Ctrl + T`             | *(Bash/Zsh)* **FZF** tìm tệp kèm xem trước                                       |
| `Alt + C`              | *(Bash/Zsh)* **FZF** nhảy vào thư mục con                                        |
| `Ctrl + F`             | *(PowerShell)* **PSFzf** tìm tệp                                                 |
| `z <thư_mục>` / `zi`   | **Zoxide** nhảy nhanh đến thư mục thường dùng (`zi` = chọn tương tác)            |
| `g`                    | Phím tắt nhanh cho `git`                                                         |
| `vi`, `vim`            | Phím tắt cho `nvim`                                                              |
| `ls`, `ll`, `la`, `lt` | **Eza** liệt kê tệp hiện đại (kèm icon, trạng thái git, cây thư mục)             |
| `cat <tệp>`, `b`       | **Bat** xem nội dung tệp có highlight cú pháp (`b` dùng trình phân trang)        |

### Tiện ích PowerShell

| Lệnh                   | Mô tả                                                                       |
| :--------------------- | :-------------------------------------------------------------------------- |
| `grep`, `find`         | Lệnh kiểu Linux dùng `rg` và `fd` (tự quay về cmdlet có sẵn nếu thiếu)      |
| `which`, `touch`       | Lệnh tiện ích kiểu Linux                                                    |
| `Get-SystemSizeReport` | Dung lượng `C:\Windows`, Program Files và `C:\Users` so với bản cài sạch    |
| `Get-AppSizeReport`    | Các ứng dụng đã cài, sắp xếp theo dung lượng (Program Files, AppData, Scoop) |

### Tiện ích Bash / Zsh

| Lệnh              | Mô tả                                                |
| :---------------- | :--------------------------------------------------- |
| `get_system_size` | Dung lượng ổ `/` và 10 thư mục lớn nhất trong `~`    |
| `cd..`, `cd...`   | Lùi lên một / hai cấp thư mục                        |

---

## 🩺 Xử lý sự cố

**Sửa profile PowerShell mà không thấy tác dụng / shell vẫn mở chậm.**
PowerShell nạp tối đa bốn file profile. Nếu một trong số đó vẫn nạp một bản `user_profile.ps1` cũ, profile của dotfiles sẽ coi như "đã nạp rồi" và dừng lại. Liệt kê và kiểm tra từng file:

```powershell
$PROFILE | Select-Object *
```

Mọi profile có nạp dotfiles đều phải trỏ tới `$env:DOTFILES_DIR\apps\powershell\user_profile.ps1`. Với `pwsh` cài qua Scoop, profile dùng chung cho mọi người dùng nằm ở `~\scoop\persist\pwsh\profile.ps1`.

**Mở shell mới thì mất Node hoặc công cụ khác khỏi `PATH`.**
Cache shell của bạn được tạo bởi một bản `dot` cũ, bản này ghi cứng `PATH` vào cache. Chạy `dot update`, rồi `dot theme reload`.

**Đo thời gian khởi động PowerShell:**

```powershell
Measure-Command { pwsh -NoLogo -Command exit }
```

---

## 🧑‍💻 Phát triển & Phát hành

Các nhánh:

```
feature/* ──PR──▶ develop ──PR──▶ release ──▶ GitHub Release (vX.Y.Z)
                                     └──PR──▶ main
```

- **CI** (`.github/workflows/ci.yml`) chạy `cargo check`, `cargo fmt --check`, `cargo clippy -D warnings` và `cargo test` trên Windows, Linux, macOS, kèm kiểm tra cú pháp mọi file `.ps1`. CI chạy khi push vào `main` / `develop` và khi mở PR vào `main`, `develop`, `release`.
- **Release** (`.github/workflows/release.yml`) chạy khi một lần push vào `release` (merge PR cũng tính) có thay đổi trong `cli/`, khi push tag `v*`, hoặc khi chạy tay. Thay đổi chỉ có tài liệu, script hay cấu hình vẫn đi qua `release` sang `main` mà không tạo binary mới; nếu vẫn muốn phát hành thì chạy workflow bằng tay.
  1. Chạy các test của CI.
  2. Chọn version: lấy version trong `cli/Cargo.toml`, tăng patch cho tới khi gặp tag chưa tồn tại. Version nhập tay không được trùng tag đã có.
  3. Build 5 binary và tạo GitHub Release kèm checksum SHA-256. Tag trỏ đúng commit đã build.
  4. Commit version mới (`Cargo.toml` + `Cargo.lock`) về cả `main` và `develop`.
- Sau khi phát hành, mở PR từ `release` vào `main` để `main` nhận phần code.

> [!WARNING]
> Đừng dùng nút **Resolve conflicts** của GitHub trên PR có nhánh nguồn là `release`: nút đó sẽ push một commit merge vào `release` và kích hoạt thêm một lần phát hành. Hãy giải quyết xung đột trên một nhánh riêng.

Chạy các bước kiểm tra giống CI trên máy trước khi mở PR:

```bash
cd cli
cargo fmt -- --check
cargo clippy --all-targets -- -D warnings
cargo test
```

---

## ☕ Ủng hộ / Donate

Nếu bạn thấy bộ dotfiles này hữu ích, hãy ủng hộ tác giả qua:

- **Ko-fi**: [ko-fi.com/anhtai2k](https://ko-fi.com/anhtai2k)
- **Star repo**: ⭐ Hãy thả 1 sao trên GitHub nhé!

---

## 📜 Giấy phép

Phát hành dưới **Giấy phép MIT**. Xem tệp `LICENSE` để biết thêm chi tiết.
