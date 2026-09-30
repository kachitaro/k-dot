use anyhow::{Context, Result, bail};
use std::process::Command;

use crate::paths;

pub fn execute(force: bool) -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;

    #[cfg(windows)]
    {
        let script_path = dotfiles_dir.join("install.ps1");
        if !script_path.exists() {
            bail!("Không tìm thấy script cài đặt: {}", script_path.display());
        }

        let ps_cmd = if Command::new("pwsh").arg("-v").output().is_ok() {
            "pwsh"
        } else {
            "powershell"
        };

        let mut cmd = Command::new(ps_cmd);
        cmd.arg("-ExecutionPolicy")
            .arg("Bypass")
            .arg("-File")
            .arg(&script_path)
            .arg("-Full");

        if force {
            cmd.arg("-ForceInstall");
        }

        let status = cmd
            .status()
            .with_context(|| format!("Không thể thực thi script cài đặt bằng {}", ps_cmd))?;

        if !status.success() {
            bail!(
                "Script cài đặt kết thúc với lỗi (exit code: {:?})",
                status.code()
            );
        }
    }

    #[cfg(unix)]
    {
        let script_path = dotfiles_dir.join("install.sh");
        if !script_path.exists() {
            bail!("Không tìm thấy script cài đặt: {}", script_path.display());
        }

        let mut cmd = Command::new("bash");
        cmd.arg(&script_path).arg("--full");

        if force {
            cmd.arg("--force");
        }

        let status = cmd
            .status()
            .with_context(|| "Không thể thực thi script cài đặt bằng bash")?;

        if !status.success() {
            bail!(
                "Script cài đặt kết thúc với lỗi (exit code: {:?})",
                status.code()
            );
        }
    }

    Ok(())
}
