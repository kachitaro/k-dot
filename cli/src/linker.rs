use anyhow::{Context, Result};
use owo_colors::OwoColorize;
use std::fs;
use std::io;
use std::path::Path;
use std::time::{SystemTime, UNIX_EPOCH};

/// Check whether a path exists and is a symlink or reparse point.
pub fn is_symlink(path: &Path) -> bool {
    fs::symlink_metadata(path)
        .map(|m| m.file_type().is_symlink())
        .unwrap_or(false)
}

/// Recursively copy a directory and all of its contents.
pub fn copy_dir_all(src: &Path, dst: &Path) -> io::Result<()> {
    fs::create_dir_all(dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let file_type = entry.file_type()?;
        let dst_path = dst.join(entry.file_name());
        if file_type.is_dir() {
            copy_dir_all(&entry.path(), &dst_path)?;
        } else {
            fs::copy(entry.path(), dst_path)?;
        }
    }
    Ok(())
}

/// Remove a symlink safely across platforms.
pub fn remove_symlink(path: &Path, is_dir: bool) -> io::Result<()> {
    #[cfg(windows)]
    {
        if is_dir {
            // Windows directory symlinks/junctions must be removed via remove_dir
            if fs::remove_dir(path).is_ok() {
                return Ok(());
            }
        }
    }
    let _ = is_dir;
    fs::remove_file(path)
}

fn get_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

/// Create a safe symlink from `link` pointing to `target`.
///
/// 1. If `target` does not exist -> warns and skips without error.
/// 2. If `link` already is a symlink -> removes it and recreates.
/// 3. If `link` is a real file/dir -> backups to `<link>.bak_<timestamp>` (or deletes if `force` is true).
/// 4. Creates symlink (Windows: symlink_file/symlink_dir, Unix: symlink).
/// 5. Windows fallback: if symlink creation fails (insufficient privileges / Dev Mode disabled),
///    falls back to copying files/directories.
pub fn create_safe_link(link: &Path, target: &Path, is_dir: bool, force: bool) -> Result<()> {
    if !target.exists() {
        eprintln!(
            "{}",
            format!("  [!] Target không tồn tại: {}", target.display()).yellow()
        );
        return Ok(());
    }

    if let Some(parent) = link.parent()
        && !parent.exists()
    {
        fs::create_dir_all(parent)
            .with_context(|| format!("Không thể tạo thư mục cha: {}", parent.display()))?;
    }

    let link_exists_or_symlink = fs::symlink_metadata(link).is_ok();

    if link_exists_or_symlink {
        if is_symlink(link) {
            remove_symlink(link, is_dir)
                .with_context(|| format!("Không thể gỡ symlink cũ: {}", link.display()))?;
        } else {
            // Real file or directory
            if force {
                if is_dir && link.is_dir() {
                    fs::remove_dir_all(link)
                        .with_context(|| format!("Không thể xóa thư mục cũ: {}", link.display()))?;
                } else {
                    fs::remove_file(link)
                        .with_context(|| format!("Không thể xóa file cũ: {}", link.display()))?;
                }
                println!(
                    "{}",
                    format!(
                        "  [!] Đã xóa (ghi đè) file/thư mục hiện tại: {}",
                        link.display()
                    )
                    .yellow()
                );
            } else {
                let timestamp = get_timestamp();
                let backup_path = format!("{}.bak_{}", link.display(), timestamp);
                fs::rename(link, &backup_path).with_context(|| {
                    format!(
                        "Không thể sao lưu file/thư mục hiện tại sang: {}",
                        backup_path
                    )
                })?;
                println!(
                    "{}",
                    format!(
                        "  [!] Đã sao lưu file/thư mục hiện tại sang: {}",
                        backup_path
                    )
                    .yellow()
                );
            }
        }
    }

    #[cfg(unix)]
    {
        std::os::unix::fs::symlink(target, link).with_context(|| {
            format!(
                "Lỗi khi tạo symlink {} -> {}",
                link.display(),
                target.display()
            )
        })?;
        println!(
            "{}",
            format!("  [+] Linked: {} -> {}", link.display(), target.display()).green()
        );
    }

    #[cfg(windows)]
    {
        let symlink_result = if is_dir {
            std::os::windows::fs::symlink_dir(target, link)
        } else {
            std::os::windows::fs::symlink_file(target, link)
        };

        match symlink_result {
            Ok(_) => {
                println!(
                    "{}",
                    format!("  [+] Linked: {} -> {}", link.display(), target.display()).green()
                );
            }
            Err(e) => {
                let junction_created = if is_dir {
                    let status = std::process::Command::new("cmd")
                        .args([
                            "/C",
                            "mklink",
                            "/J",
                            &link.to_string_lossy(),
                            &target.to_string_lossy(),
                        ])
                        .output();
                    matches!(status, Ok(out) if out.status.success())
                } else {
                    false
                };

                if junction_created {
                    println!(
                        "{}",
                        format!("  [+] Junction: {} -> {}", link.display(), target.display())
                            .green()
                    );
                } else {
                    println!(
                        "{}",
                        format!(
                            "  [!] Không thể tạo Symlink/Junction ({}). Tiến hành copy file/thư mục thay thế...",
                            e
                        )
                        .yellow()
                    );
                    if is_dir {
                        copy_dir_all(target, link).with_context(|| {
                            format!(
                                "Không thể copy thư mục fallback {} -> {}",
                                target.display(),
                                link.display()
                            )
                        })?;
                    } else {
                        fs::copy(target, link).with_context(|| {
                            format!(
                                "Không thể copy file fallback {} -> {}",
                                target.display(),
                                link.display()
                            )
                        })?;
                    }
                    println!(
                        "{}",
                        format!("  [+] Copied: {} -> {}", link.display(), target.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_create_safe_link_file_backup_and_overwrite() {
        let temp = tempdir().unwrap();
        let target_file = temp.path().join("source.txt");
        let link_file = temp.path().join("dest.txt");

        fs::write(&target_file, "hello world").unwrap();
        fs::write(&link_file, "original content").unwrap();

        // Safe link without force should backup original
        create_safe_link(&link_file, &target_file, false, false).unwrap();

        // dest.txt exists
        assert!(link_file.exists());

        // A backup file dest.txt.bak_* exists
        let mut backups = Vec::new();
        for entry in fs::read_dir(temp.path()).unwrap() {
            let entry = entry.unwrap();
            let name = entry.file_name().to_string_lossy().to_string();
            if name.starts_with("dest.txt.bak_") {
                backups.push(name);
            }
        }
        assert_eq!(backups.len(), 1);

        // Re-linking existing symlink should recreate without extra backups
        create_safe_link(&link_file, &target_file, false, false).unwrap();
        assert!(link_file.exists());
    }

    #[test]
    fn test_create_safe_link_nonexistent_target_skips() {
        let temp = tempdir().unwrap();
        let target_file = temp.path().join("missing.txt");
        let link_file = temp.path().join("dest.txt");

        // Should return Ok without creating link
        create_safe_link(&link_file, &target_file, false, false).unwrap();
        assert!(!link_file.exists());
    }

    #[test]
    fn test_create_safe_link_dir_force() {
        let temp = tempdir().unwrap();
        let target_dir = temp.path().join("source_dir");
        let link_dir = temp.path().join("dest_dir");

        fs::create_dir_all(&target_dir).unwrap();
        fs::write(target_dir.join("file.txt"), "hello").unwrap();

        fs::create_dir_all(&link_dir).unwrap();
        fs::write(link_dir.join("old.txt"), "old").unwrap();

        // Safe link with force = true should delete existing real directory without backup
        create_safe_link(&link_dir, &target_dir, true, true).unwrap();
        assert!(link_dir.exists());

        let mut backups = Vec::new();
        for entry in fs::read_dir(temp.path()).unwrap() {
            let entry = entry.unwrap();
            let name = entry.file_name().to_string_lossy().to_string();
            if name.starts_with("dest_dir.bak_") {
                backups.push(name);
            }
        }
        assert_eq!(backups.len(), 0);
    }
}
