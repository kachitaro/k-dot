use anyhow::{Context, Result, bail};
use owo_colors::OwoColorize;
use std::fs;
use std::path::PathBuf;

use crate::linker::{copy_dir_all, create_safe_link, is_symlink};
use crate::paths;

pub fn execute(path: PathBuf) -> Result<()> {
    if !path.exists() {
        bail!("[-] Đường dẫn không tồn tại: {}", path.display());
    }

    if is_symlink(&path) {
        bail!("[-] Đường dẫn này đã là symlink (đã được quản lý rồi)!");
    }

    let canonical_path = paths::strip_unc_prefix(
        path.canonicalize()
            .with_context(|| format!("Không thể chuẩn hóa đường dẫn: {}", path.display()))?,
    );

    let is_dir = canonical_path.is_dir();
    let basename = canonical_path
        .file_name()
        .ok_or_else(|| anyhow::anyhow!("Đường dẫn không hợp lệ: {}", canonical_path.display()))?;

    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    let apps_dir = dotfiles_dir.join("apps");
    fs::create_dir_all(&apps_dir)
        .with_context(|| format!("Không thể tạo thư mục: {}", apps_dir.display()))?;
    let dotfiles_dest = apps_dir.join(basename);

    if dotfiles_dest.exists() {
        bail!(
            "[-] Thư mục/tệp đích đã tồn tại trong dotfiles: {}",
            dotfiles_dest.display()
        );
    }

    let basename_str = basename.to_string_lossy();
    println!(
        "{}",
        format!(
            "[*] Đang thu nạp '{}' vào apps/ trong kho dotfiles...",
            basename_str
        )
        .cyan()
    );

    // Try rename/move first. If cross-device move fails, copy and delete.
    if fs::rename(&canonical_path, &dotfiles_dest).is_err() {
        if is_dir {
            copy_dir_all(&canonical_path, &dotfiles_dest)?;
            fs::remove_dir_all(&canonical_path)?;
        } else {
            fs::copy(&canonical_path, &dotfiles_dest)?;
            fs::remove_file(&canonical_path)?;
        }
    }

    create_safe_link(&canonical_path, &dotfiles_dest, is_dir, false)?;

    println!("{}", "  [+] Thu nạp thành công!".green());
    println!(
        "{}",
        format!(
            "[+] Thư mục \"apps/{}\" đã được tích hợp và sẽ tự động đồng bộ (Auto-Discover) trong các lần chạy sau!",
            basename_str
        )
        .cyan()
    );

    Ok(())
}
