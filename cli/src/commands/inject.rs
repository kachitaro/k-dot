use anyhow::Result;
use owo_colors::OwoColorize;
use std::fs;
use std::path::{Path, PathBuf};

use crate::linker::create_safe_link;
use crate::paths;
use crate::shell_cache;
use crate::theme_engine;

pub fn execute(force: bool) -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    println!(
        "{}",
        "[*] Đang đồng bộ và liên kết (inject) cấu hình vào hệ thống...".cyan()
    );

    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
    let targets = paths::discover_app_targets(&dotfiles_dir);

    for target in targets {
        if target.src.exists() {
            create_safe_link(&target.dest, &target.src, target.is_dir, force)?;
        }
    }

    #[cfg(windows)]
    {
        // Re-inject PowerShell profile loading
        inject_powershell_profiles(&dotfiles_dir, &home_dir)?;
    }

    #[cfg(unix)]
    {
        // Re-inject shell profiles
        inject_unix_shell_profiles(&dotfiles_dir, &home_dir)?;
    }

    // Compile theme files to ensure themes/generated/ is up-to-date
    if let Err(e) = theme_engine::generate_themes(&dotfiles_dir) {
        eprintln!(
            "{}",
            format!("  [!] Không thể biên dịch Theme: {}", e).yellow()
        );
    }

    // Sinh file cache khởi động shell (init.zsh, init.bash, init.ps1)
    if let Err(e) = shell_cache::generate_shell_caches(&dotfiles_dir) {
        eprintln!(
            "{}",
            format!("  [!] Không thể tạo cache khởi động Shell: {}", e).yellow()
        );
    }

    println!(
        "\n{}",
        "[+] Quá trình INJECT hoàn tất! Hệ thống đã được liên kết lại với Dotfiles.".green()
    );

    Ok(())
}

#[cfg(windows)]
fn inject_powershell_profiles(dotfiles_dir: &Path, home_dir: &Path) -> Result<()> {
    println!("{}", "\n[*] Nạp cấu hình vào PowerShell Profile...".cyan());

    let doc_dir = dirs::document_dir().unwrap_or_else(|| home_dir.join("Documents"));
    let target_profiles = [
        doc_dir
            .join("PowerShell")
            .join("Microsoft.PowerShell_profile.ps1"),
        doc_dir
            .join("WindowsPowerShell")
            .join("Microsoft.PowerShell_profile.ps1"),
        home_dir
            .join("Documents")
            .join("PowerShell")
            .join("Microsoft.PowerShell_profile.ps1"),
        home_dir
            .join("Documents")
            .join("WindowsPowerShell")
            .join("Microsoft.PowerShell_profile.ps1"),
    ];

    let source_line = format!(
        "\r\n# Load dotfiles user profile\r\n. \"{}\\apps\\powershell\\user_profile.ps1\"\r\n",
        dotfiles_dir.display()
    );

    for profile in target_profiles {
        if let Some(parent) = profile.parent() {
            let _ = fs::create_dir_all(parent);
        }

        let existing = if profile.is_file() {
            fs::read_to_string(&profile).unwrap_or_default()
        } else {
            String::new()
        };

        if !existing.contains("user_profile.ps1") {
            let mut new_content = existing;
            new_content.push_str(&source_line);
            fs::write(&profile, new_content)?;
            println!(
                "{}",
                format!("  [+] Đã nạp dotfiles vào: {}", profile.display()).green()
            );
        } else {
            println!(
                "{}",
                format!(
                    "  [+] Profile đã được cấu hình trước đó: {}",
                    profile.display()
                )
                .green()
            );
        }
    }

    Ok(())
}

#[cfg(unix)]
fn inject_unix_shell_profiles(dotfiles_dir: &Path, home_dir: &Path) -> Result<()> {
    println!("{}", "\n[*] Nạp cấu hình vào Shell Profiles...".cyan());

    let bash_line = format!(
        "\n# Load dotfiles config\n[ -f \"{}/apps/shell/.bashrc\" ] && source \"{}/apps/shell/.bashrc\"\n",
        dotfiles_dir.display(),
        dotfiles_dir.display()
    );

    let zsh_line = format!(
        "\n# Load dotfiles config\n[ -f \"{}/apps/shell/.zshrc\" ] && source \"{}/apps/shell/.zshrc\"\n",
        dotfiles_dir.display(),
        dotfiles_dir.display()
    );

    let bashrc = home_dir.join(".bashrc");
    let existing_bash = fs::read_to_string(&bashrc).unwrap_or_default();
    if existing_bash.contains("dotfiles/shell/.bashrc") {
        let new_content =
            existing_bash.replace("dotfiles/shell/.bashrc", "dotfiles/apps/shell/.bashrc");
        fs::write(&bashrc, new_content)?;
        println!("{}", "  [+] Đã cập nhật dotfiles trong ~/.bashrc".green());
    } else if !existing_bash.contains("apps/shell/.bashrc") {
        let mut new_content = existing_bash;
        new_content.push_str(&bash_line);
        fs::write(&bashrc, new_content)?;
        println!("{}", "  [+] Đã nạp dotfiles vào ~/.bashrc".green());
    }

    let zshrc = home_dir.join(".zshrc");
    let existing_zsh = fs::read_to_string(&zshrc).unwrap_or_default();
    if existing_zsh.contains("dotfiles/shell/.zshrc") {
        let new_content =
            existing_zsh.replace("dotfiles/shell/.zshrc", "dotfiles/apps/shell/.zshrc");
        fs::write(&zshrc, new_content)?;
        println!("{}", "  [+] Đã cập nhật dotfiles trong ~/.zshrc".green());
    } else if !existing_zsh.contains("apps/shell/.zshrc") {
        let mut new_content = existing_zsh;
        new_content.push_str(&zsh_line);
        fs::write(&zshrc, new_content)?;
        println!("{}", "  [+] Đã nạp dotfiles vào ~/.zshrc".green());
    }

    // PowerShell on Linux
    let pwsh_profile_dir = home_dir.join(".config").join("powershell");
    let pwsh_profile = pwsh_profile_dir.join("Microsoft.PowerShell_profile.ps1");
    let pwsh_line = format!(
        "\n# Load dotfiles config\n. \"{}/apps/powershell/user_profile.ps1\"\n",
        dotfiles_dir.display()
    );

    let _ = fs::create_dir_all(&pwsh_profile_dir);
    let existing_pwsh = fs::read_to_string(&pwsh_profile).unwrap_or_default();
    if !existing_pwsh.contains("user_profile.ps1") {
        let mut new_content = existing_pwsh;
        new_content.push_str(&pwsh_line);
        fs::write(&pwsh_profile, new_content)?;
        println!("{}", "  [+] Đã nạp dotfiles vào PowerShell profile".green());
    }

    Ok(())
}
