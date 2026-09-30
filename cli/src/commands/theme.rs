use anyhow::Result;
use owo_colors::OwoColorize;

use crate::paths;
use crate::shell_cache;
use crate::theme_engine;

pub fn reload() -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    println!("{}", "Đang tải lại giao diện (Theme Engine)...".cyan());

    let theme_data = theme_engine::generate_themes(&dotfiles_dir)?;

    // Sinh lại cache khởi động shell
    if let Err(e) = shell_cache::generate_shell_caches(&dotfiles_dir) {
        eprintln!(
            "{}",
            format!("  [!] Không thể tạo cache khởi động Shell: {}", e).yellow()
        );
    }

    let _sh_path = dotfiles_dir
        .join("themes")
        .join("generated")
        .join("theme.sh");

    println!(
        "{}",
        format!(
            "Theme '{}' compiled! (WezTerm & Neovim reload automatically)",
            theme_data.name
        )
        .green()
    );

    #[cfg(windows)]
    {
        println!(
            "{}",
            "Note: Khởi động lại terminal hoặc mở tab mới để biến môi trường áp dụng cho prompt."
                .yellow()
        );
    }

    #[cfg(unix)]
    {
        println!(
            "{}",
            format!(
                "Note: Để apply màu mới vào Shell hiện tại, chạy thủ công: source {} (hoặc mở terminal mới)",
                _sh_path.display()
            )
            .yellow()
        );
    }

    Ok(())
}

pub fn print_path() -> Result<()> {
    let path = paths::theme_generated_dir()?;
    // Print plain absolute path without extra text so Neovim/WezTerm/scripts can directly eval/dofile it
    println!("{}", path.display());
    Ok(())
}
