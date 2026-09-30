use anyhow::Result;
use owo_colors::OwoColorize;
use std::fs;
use std::path::{Path, PathBuf};

use crate::linker::{copy_dir_all, is_symlink, remove_symlink};
use crate::paths;

pub fn execute() -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    println!(
        "{}",
        "[*] Đang phục hồi (eject) cấu hình về máy thực...".cyan()
    );

    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
    let targets = paths::discover_app_targets(&dotfiles_dir);

    for target in targets {
        restore_app_if_symlinked(&target.src, &target.dest, target.is_dir, &target.name)?;
    }

    #[cfg(windows)]
    {
        clean_powershell_profiles(&home_dir)?;
    }

    #[cfg(unix)]
    {
        clean_unix_shell_profiles(&home_dir)?;
    }

    println!(
        "\n{}",
        "[+] Quá trình EJECT hoàn tất! Máy bạn đã độc lập.".green()
    );
    println!(
        "{}",
        format!(
            "Giờ bạn có thể xóa an toàn thư mục: {}",
            dotfiles_dir.display()
        )
        .yellow()
    );

    Ok(())
}

fn restore_app_if_symlinked(src: &Path, dest: &Path, is_dir: bool, name: &str) -> Result<()> {
    if is_symlink(dest) {
        remove_symlink(dest, is_dir)?;
        if src.exists() {
            if is_dir {
                copy_dir_all(src, dest)?;
            } else {
                fs::copy(src, dest)?;
            }
            println!(
                "{}",
                format!("  [+] Đã phục hồi: {} -> {}", name, dest.display()).green()
            );
        }
    }
    Ok(())
}

#[cfg(windows)]
fn clean_powershell_profiles(home_dir: &Path) -> Result<()> {
    println!("{}", "\n[*] Gỡ cấu hình khỏi PowerShell Profile...".cyan());

    let doc_dir = dirs::document_dir().unwrap_or_else(|| home_dir.join("Documents"));
    let candidate_profiles = [
        doc_dir
            .join("PowerShell")
            .join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("PowerShell").join("profile.ps1"),
        doc_dir
            .join("WindowsPowerShell")
            .join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("WindowsPowerShell").join("profile.ps1"),
        home_dir
            .join("Documents")
            .join("PowerShell")
            .join("Microsoft.PowerShell_profile.ps1"),
        home_dir
            .join("Documents")
            .join("WindowsPowerShell")
            .join("Microsoft.PowerShell_profile.ps1"),
    ];

    for profile in candidate_profiles {
        if profile.is_file()
            && let Ok(content) = fs::read_to_string(&profile)
        {
            let cleaned_lines: Vec<&str> = content
                .lines()
                .filter(|line| {
                    !line.contains("# Load dotfiles user profile")
                        && !line.contains("user_profile.ps1")
                })
                .collect();
            let new_content = cleaned_lines.join("\r\n");
            if new_content != content {
                fs::write(&profile, new_content)?;
                println!(
                    "{}",
                    format!("  [+] Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                );
            }
        }
    }

    Ok(())
}

#[cfg(unix)]
fn clean_unix_shell_profiles(home_dir: &Path) -> Result<()> {
    println!(
        "{}",
        "\n[*] Gỡ bỏ dòng load dotfiles khỏi shell profile...".cyan()
    );

    let shell_profiles = [
        home_dir.join(".bashrc"),
        home_dir.join(".zshrc"),
        home_dir
            .join(".config")
            .join("powershell")
            .join("Microsoft.PowerShell_profile.ps1"),
    ];

    for profile in shell_profiles {
        if let Ok(content) = fs::read_to_string(&profile) {
            let cleaned_lines: Vec<&str> = content
                .lines()
                .filter(|line| {
                    !line.contains("# Load dotfiles config")
                        && !line.contains("shell/.bashrc")
                        && !line.contains("shell/.zshrc")
                        && !line.contains("user_profile.ps1")
                })
                .collect();
            let new_content = cleaned_lines.join("\n");
            if new_content != content {
                fs::write(&profile, new_content)?;
                println!(
                    "{}",
                    format!("  [+] Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                );
            }
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::linker::create_safe_link;
    use tempfile::tempdir;

    #[test]
    fn test_restore_app_if_symlinked_dir() {
        let temp = tempdir().unwrap();
        let src_dir = temp.path().join("apps").join("nvim");
        let config_dir = temp.path().join(".config");
        let dest_dir = config_dir.join("nvim");

        fs::create_dir_all(&src_dir).unwrap();
        fs::write(src_dir.join("init.lua"), "print('hello nvim')").unwrap();

        // Create symlink
        create_safe_link(&dest_dir, &src_dir, true, false).unwrap();

        // Eject / restore
        restore_app_if_symlinked(&src_dir, &dest_dir, true, "nvim").unwrap();

        // Check that dest_dir still exists and contains the file
        assert!(dest_dir.exists());
        assert!(dest_dir.join("init.lua").exists());
        let content = fs::read_to_string(dest_dir.join("init.lua")).unwrap();
        assert_eq!(content, "print('hello nvim')");
        // And is no longer a symlink
        assert!(!is_symlink(&dest_dir));
    }
}
