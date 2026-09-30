use anyhow::Result;
use owo_colors::OwoColorize;
use std::fs;
use std::path::{Path, PathBuf};

use crate::linker::{is_symlink, remove_symlink};
use crate::paths;

pub fn execute() -> Result<()> {
    println!("{}", "Bắt đầu gỡ cài đặt (Uninstall) Dotfiles...".red());
    println!("{}", "Xóa các symlink cấu hình...".cyan());

    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
    let dotfiles_dir = paths::resolve_dotfiles_dir().unwrap_or_else(|_| home_dir.join(".dotfiles"));
    let targets = paths::discover_app_targets(&dotfiles_dir);

    for target in targets {
        if is_symlink(&target.dest) {
            let _ = remove_symlink(&target.dest, target.is_dir);
            println!("{}", format!("  Đã xóa: {}", target.dest.display()).green());
        }
    }

    #[cfg(windows)]
    {
        // Clean PowerShell profile scripts
        clean_powershell_profiles(&home_dir)?;
    }

    #[cfg(unix)]
    {
        // Clean shell profiles
        clean_unix_shell_profiles(&home_dir)?;
    }

    println!(
        "\n{}",
        "Hoàn tất gỡ cài đặt! Các file gốc/backup (.bak_*) của bạn vẫn được giữ nguyên.".green()
    );

    Ok(())
}

#[cfg(windows)]
fn clean_powershell_profiles(home_dir: &Path) -> Result<()> {
    println!("{}", "Gỡ cấu hình khỏi PowerShell Profile...".cyan());

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
                    format!("  Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                );
            }
        }
    }

    Ok(())
}

#[cfg(unix)]
fn clean_unix_shell_profiles(home_dir: &Path) -> Result<()> {
    println!("{}", "Gỡ bỏ cấu hình dotfiles khỏi shell profile...".cyan());

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
                    format!("  Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                );
            }
        }
    }

    Ok(())
}
