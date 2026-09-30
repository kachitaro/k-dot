use anyhow::{Context, Result};
use owo_colors::OwoColorize;
use std::fs;
use std::path::PathBuf;

use crate::paths;
use crate::theme_engine;

const DEFAULT_THEME_JSON: &str = include_str!("../../../themes/theme.json");

pub fn execute(target_path: Option<PathBuf>, force: bool) -> Result<()> {
    let dotfiles_dir = match target_path {
        Some(p) => paths::strip_unc_prefix(if p.is_absolute() {
            p
        } else {
            std::env::current_dir()?.join(p)
        }),
        None => {
            let current = std::env::current_dir()?;
            let is_already_dotfiles = current
                .file_name()
                .map(|name| {
                    let s = name.to_string_lossy().to_lowercase();
                    s == "dotfiles" || s == ".dotfiles"
                })
                .unwrap_or(false);

            if is_already_dotfiles {
                paths::strip_unc_prefix(current)
            } else {
                paths::strip_unc_prefix(current.join("dotfiles"))
            }
        }
    };

    println!(
        "{}",
        format!("[*] Khởi tạo kho dotfiles tại: {}", dotfiles_dir.display()).cyan()
    );

    // 1. Tạo thư mục dotfiles nếu chưa tồn tại
    if !dotfiles_dir.exists() {
        fs::create_dir_all(&dotfiles_dir).with_context(|| {
            format!(
                "Không thể tạo thư mục dotfiles tại {}",
                dotfiles_dir.display()
            )
        })?;
        println!("  [+] Đã tạo thư mục: {}", dotfiles_dir.display());
    }

    // 2. Tạo thư mục apps và themes
    let apps_dir = dotfiles_dir.join("apps");
    if !apps_dir.exists() {
        fs::create_dir_all(&apps_dir)
            .with_context(|| format!("Không thể tạo thư mục {}", apps_dir.display()))?;
        println!("  [+] Đã tạo thư mục: {}", apps_dir.display());
    }

    let themes_dir = dotfiles_dir.join("themes");
    if !themes_dir.exists() {
        fs::create_dir_all(&themes_dir)
            .with_context(|| format!("Không thể tạo thư mục {}", themes_dir.display()))?;
    }

    let theme_json_path = themes_dir.join("theme.json");
    if !theme_json_path.exists() || force {
        fs::write(&theme_json_path, DEFAULT_THEME_JSON)
            .with_context(|| format!("Không thể tạo {}", theme_json_path.display()))?;
        println!("  [+] Đã tạo file mẫu theme: {}", theme_json_path.display());
    } else {
        println!("  [i] Đã có sẵn {}", theme_json_path.display());
    }

    // 3. Compile theme lần đầu
    println!("  [*] Đang biên dịch Theme Engine ban đầu...");
    let theme_data = theme_engine::generate_themes(&dotfiles_dir)?;
    println!(
        "  [+] Đã tạo theme '{}' tại: {}",
        theme_data.name,
        dotfiles_dir.join("themes").join("generated").display()
    );

    // 4. Thiết lập biến môi trường DOTFILES_DIR nếu trên Windows
    #[cfg(windows)]
    {
        let setx_status = std::process::Command::new("setx")
            .args(["DOTFILES_DIR", &dotfiles_dir.to_string_lossy()])
            .output();

        if let Ok(output) = setx_status
            && output.status.success()
        {
            println!("  [+] Đã tự động cấu hình biến môi trường DOTFILES_DIR.");
        }
    }

    println!("\n{}", "[+] KHỞI TẠO THÀNH CÔNG!".green().bold());
    println!("Bây giờ bạn có thể bắt đầu sử dụng các lệnh:");
    println!(
        "  * {} : Thu nạp một cấu hình vào kho dotfiles",
        "dot add <path>".yellow()
    );
    println!(
        "  * {} : Biên dịch lại khi bạn chỉnh sửa theme.json",
        "dot theme reload".yellow()
    );
    println!(
        "  * {} : In đường dẫn chứa theme đã biên dịch",
        "dot theme path".yellow()
    );

    #[cfg(unix)]
    {
        println!(
            "\n{}",
            "[i] Gợi ý cấu hình biến môi trường trên Linux/macOS:".bold()
        );
        println!("Thêm dòng sau vào ~/.bashrc hoặc ~/.zshrc:");
        println!("  export DOTFILES_DIR=\"{}\"", dotfiles_dir.display());
    }

    Ok(())
}
