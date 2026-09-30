use anyhow::{Context, Result};
use owo_colors::OwoColorize;
use std::fs;
use std::path::Path;
use std::process::Command;

fn run_tool_init(tool_name: &str, program: &str, args: &[&str]) -> Option<String> {
    match Command::new(program).args(args).output() {
        Ok(output) if output.status.success() => {
            let stdout = String::from_utf8_lossy(&output.stdout).to_string();
            if stdout.trim().is_empty() {
                None
            } else {
                Some(stdout)
            }
        }
        Ok(output) => {
            let stderr = String::from_utf8_lossy(&output.stderr);
            eprintln!(
                "{}",
                format!(
                    "  [!] Công cụ '{}' trả về lỗi khi chạy '{} {}': {}",
                    tool_name,
                    program,
                    args.join(" "),
                    stderr.trim()
                )
                .yellow()
            );
            None
        }
        Err(e) => {
            eprintln!(
                "{}",
                format!(
                    "  [!] Bỏ qua '{}': không tìm thấy công cụ hoặc không thể khởi chạy ({}).",
                    tool_name, e
                )
                .yellow()
            );
            None
        }
    }
}

pub fn generate_zsh_cache(out_dir: &Path) -> Result<()> {
    let mut content = String::from(
        "# Auto-generated Zsh init cache by 'dot inject' / 'dot theme reload'\n# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'\n\n",
    );

    let tools: [(&str, &str, &[&str]); 5] = [
        ("zoxide", "zoxide", &["init", "zsh"]),
        ("atuin", "atuin", &["init", "zsh"]),
        ("fnm", "fnm", &["env", "--use-on-cd", "--shell", "zsh"]),
        ("fzf", "fzf", &["--zsh"]),
        ("starship", "starship", &["init", "zsh"]),
    ];

    for (name, prog, args) in &tools {
        if let Some(out) = run_tool_init(name, prog, args) {
            content.push_str(&format!("# --- {} init ---\n", name));
            content.push_str(&out);
            if !out.ends_with('\n') {
                content.push('\n');
            }
            content.push('\n');
        }
    }

    fs::write(out_dir.join("init.zsh"), content).with_context(|| "Không thể ghi tệp init.zsh")?;
    Ok(())
}

pub fn generate_bash_cache(out_dir: &Path) -> Result<()> {
    let mut content = String::from(
        "# Auto-generated Bash init cache by 'dot inject' / 'dot theme reload'\n# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'\n\n",
    );

    let tools: [(&str, &str, &[&str]); 5] = [
        ("zoxide", "zoxide", &["init", "bash"]),
        ("atuin", "atuin", &["init", "bash"]),
        ("fnm", "fnm", &["env", "--use-on-cd", "--shell", "bash"]),
        ("fzf", "fzf", &["--bash"]),
        ("starship", "starship", &["init", "bash"]),
    ];

    for (name, prog, args) in &tools {
        if let Some(out) = run_tool_init(name, prog, args) {
            content.push_str(&format!("# --- {} init ---\n", name));
            content.push_str(&out);
            if !out.ends_with('\n') {
                content.push('\n');
            }
            content.push('\n');
        }
    }

    fs::write(out_dir.join("init.bash"), content).with_context(|| "Không thể ghi tệp init.bash")?;
    Ok(())
}

pub fn generate_powershell_cache(out_dir: &Path) -> Result<()> {
    let header = String::from(
        "# Auto-generated PowerShell init cache by 'dot inject' / 'dot theme reload'\n# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'\n\n",
    );

    let tools: [(&str, &str, &[&str]); 4] = [
        ("starship", "starship", &["init", "powershell"]),
        (
            "fnm",
            "fnm",
            &["env", "--use-on-cd", "--shell", "powershell"],
        ),
        ("zoxide", "zoxide", &["init", "powershell"]),
        (
            "atuin",
            "atuin",
            &["init", "powershell", "--disable-up-arrow"],
        ),
    ];

    let mut using_statements = Vec::new();
    let mut body = String::new();

    for (name, prog, args) in &tools {
        if let Some(out) = run_tool_init(name, prog, args) {
            body.push_str(&format!("# --- {} init ---\n", name));
            for line in out.lines() {
                let trimmed = line.trim();
                if trimmed.starts_with("using namespace ") || trimmed.starts_with("using module ") {
                    if !using_statements.contains(&trimmed.to_string()) {
                        using_statements.push(trimmed.to_string());
                    }
                } else {
                    body.push_str(line);
                    body.push('\n');
                }
            }
            body.push('\n');
        }
    }

    let mut full_content = header;
    if !using_statements.is_empty() {
        for u in using_statements {
            full_content.push_str(&u);
            full_content.push('\n');
        }
        full_content.push('\n');
    }
    full_content.push_str(&body);

    fs::write(out_dir.join("init.ps1"), full_content)
        .with_context(|| "Không thể ghi tệp init.ps1")?;
    Ok(())
}

pub fn generate_shell_caches(dotfiles_dir: &Path) -> Result<()> {
    let out_dir = dotfiles_dir.join("themes").join("generated");
    fs::create_dir_all(&out_dir)
        .with_context(|| format!("Không thể tạo thư mục: {}", out_dir.display()))?;

    generate_zsh_cache(&out_dir)?;
    generate_bash_cache(&out_dir)?;
    generate_powershell_cache(&out_dir)?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_generate_shell_caches_creates_files() {
        let dir = tempdir().expect("Failed to create temp dir");
        let dotfiles_dir = dir.path();

        generate_shell_caches(dotfiles_dir).expect("Failed to generate shell caches");

        let gen_dir = dotfiles_dir.join("themes").join("generated");
        assert!(gen_dir.join("init.zsh").exists());
        assert!(gen_dir.join("init.bash").exists());
        assert!(gen_dir.join("init.ps1").exists());
    }
}
