use anyhow::{Context, Result, bail};
use owo_colors::OwoColorize;
use sha2::{Digest, Sha256};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

const CURRENT_VERSION: &str = env!("CARGO_PKG_VERSION");
const REPO: &str = "kachitaro/dotfiles";

/// Tính SHA-256 hash dạng hex chuỗi thường từ mảng bytes
pub fn compute_sha256(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    format!("{:x}", hasher.finalize())
}

/// Tính SHA-256 hash của một tệp tin
pub fn compute_file_sha256(path: &Path) -> Result<String> {
    let bytes = fs::read(path)
        .with_context(|| format!("Không thể đọc tệp để tính checksum: {}", path.display()))?;
    Ok(compute_sha256(&bytes))
}

/// Kiểm tra xem mã băm SHA-256 thực tế có khớp với checksum kỳ vọng không.
/// Hỗ trợ cả định dạng hash thô, định dạng file .sha256 ("<hash>  <filename>")
/// và file SHA256SUMS.txt (nhiều dòng).
pub fn verify_checksum(actual_sha256: &str, expected_content: &str) -> bool {
    let actual_clean = actual_sha256.trim().to_lowercase();
    for line in expected_content.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        if let Some(hash) = line.split_whitespace().next()
            && hash.to_lowercase() == actual_clean
        {
            return true;
        }
    }
    false
}

pub fn execute() -> Result<()> {
    println!(
        "{}",
        format!(
            "[*] Đang kiểm tra và tải bản phát hành mới nhất từ GitHub ({}) ...",
            REPO
        )
        .cyan()
    );
    println!(
        "  Phiên bản hiện tại: {}",
        format!("v{}", CURRENT_VERSION).yellow()
    );

    // 1. Xác định vị trí file thực thi hiện tại hoặc ~/.local/bin
    let current_exe = env::current_exe().ok();
    let home_bin = dirs::home_dir().map(|h| {
        #[cfg(windows)]
        {
            h.join(".local").join("bin").join("dot.exe")
        }
        #[cfg(unix)]
        {
            h.join(".local").join("bin").join("dot")
        }
    });

    let target_dest = if let Some(ref exe) = current_exe {
        if exe.exists() {
            exe.clone()
        } else if let Some(ref h_bin) = home_bin {
            h_bin.clone()
        } else {
            exe.clone()
        }
    } else if let Some(ref h_bin) = home_bin {
        h_bin.clone()
    } else {
        PathBuf::from(if cfg!(windows) { "dot.exe" } else { "dot" })
    };

    if let Some(parent) = target_dest.parent() {
        let _ = fs::create_dir_all(parent);
    }

    // 2. Tải và giải nén bản release tương ứng với OS/Arch
    #[cfg(windows)]
    {
        let asset_name = "dot-x86_64-pc-windows-msvc.zip";
        let url = format!(
            "https://github.com/{}/releases/latest/download/{}",
            REPO, asset_name
        );
        let checksum_url = format!("{}.sha256", url);
        let sums_url = format!(
            "https://github.com/{}/releases/latest/download/SHA256SUMS.txt",
            REPO
        );

        let temp_dir = env::temp_dir().join("dot_update_extract");
        let temp_zip = env::temp_dir().join("dot_update.zip");
        let temp_sha = env::temp_dir().join("dot_update.zip.sha256");

        if temp_dir.exists() {
            let _ = fs::remove_dir_all(&temp_dir);
        }
        if temp_zip.exists() {
            let _ = fs::remove_file(&temp_zip);
        }
        if temp_sha.exists() {
            let _ = fs::remove_file(&temp_sha);
        }

        println!("  Đang tải: {}", url.dimmed());

        let ps_script = format!(
            r#"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
            Invoke-WebRequest -Uri "{url}" -OutFile "{zip}" -UseBasicParsing -TimeoutSec 30
            try {{
                Invoke-WebRequest -Uri "{sha_url}" -OutFile "{sha}" -UseBasicParsing -TimeoutSec 15
            }} catch {{
                Invoke-WebRequest -Uri "{sums_url}" -OutFile "{sha}" -UseBasicParsing -TimeoutSec 15
            }}
            Expand-Archive -Path "{zip}" -DestinationPath "{ext}" -Force
            "#,
            url = url,
            sha_url = checksum_url,
            sums_url = sums_url,
            zip = temp_zip.display(),
            sha = temp_sha.display(),
            ext = temp_dir.display()
        );

        let status = Command::new("powershell")
            .args(["-NoProfile", "-Command", &ps_script])
            .status()?;

        if !status.success() || !temp_dir.exists() {
            bail!("Không thể tải hoặc giải nén release từ GitHub. Vui lòng kiểm tra kết nối mạng.");
        }

        // Kiểm tra Checksum tính toàn vẹn của file tải về
        if temp_sha.exists() {
            let expected_checksum = fs::read_to_string(&temp_sha).unwrap_or_default();
            if !expected_checksum.trim().is_empty() {
                let actual_zip_sha = compute_file_sha256(&temp_zip)?;
                if !verify_checksum(&actual_zip_sha, &expected_checksum) {
                    let _ = fs::remove_file(&temp_zip);
                    let _ = fs::remove_file(&temp_sha);
                    let _ = fs::remove_dir_all(&temp_dir);
                    bail!(
                        "[-] Checksum không khớp — file tải về có thể bị hỏng hoặc bị can thiệp. Hủy cập nhật."
                    );
                }
                println!("  [+] Checksum SHA-256 hợp lệ: {}", actual_zip_sha.dimmed());
            }
        }

        // Tìm dot.exe đã giải nén
        let extracted_dot = find_extracted_binary(&temp_dir, "dot.exe")?;

        // Trên Windows, để ghi đè file .exe đang chạy, đổi tên file cũ trước
        let old_exe = target_dest.with_extension("exe.old");
        if target_dest.exists() {
            let _ = fs::remove_file(&old_exe);
            fs::rename(&target_dest, &old_exe).ok();
        }

        fs::copy(&extracted_dot, &target_dest)?;
        let _ = fs::remove_file(&old_exe);
        let _ = fs::remove_dir_all(&temp_dir);
        let _ = fs::remove_file(&temp_zip);
        let _ = fs::remove_file(&temp_sha);

        // Đồng bộ thêm vào ~/.local/bin/dot.exe nếu target_dest nằm ở chỗ khác
        if let Some(ref h_bin) = home_bin
            && h_bin != &target_dest
        {
            if let Some(p) = h_bin.parent() {
                let _ = fs::create_dir_all(p);
            }
            let _ = fs::copy(&target_dest, h_bin);
        }
    }

    #[cfg(unix)]
    {
        let os = std::env::consts::OS;
        let arch = std::env::consts::ARCH;

        let target_triple = match (os, arch) {
            ("linux", "x86_64") => "x86_64-unknown-linux-gnu",
            ("linux", "aarch64") => "aarch64-unknown-linux-gnu",
            ("macos", "aarch64") => "aarch64-apple-darwin",
            ("macos", "x86_64") => "x86_64-apple-darwin",
            _ => bail!(
                "Hệ điều hành hoặc kiến trúc chưa được hỗ trợ tự động: {}-{}",
                os,
                arch
            ),
        };

        let asset_name = format!("dot-{}.tar.gz", target_triple);
        let url = format!(
            "https://github.com/{}/releases/latest/download/{}",
            REPO, asset_name
        );
        let checksum_url = format!("{}.sha256", url);
        let sums_url = format!(
            "https://github.com/{}/releases/latest/download/SHA256SUMS.txt",
            REPO
        );

        let temp_dir = env::temp_dir().join("dot_update_extract");
        let temp_archive = env::temp_dir().join(&asset_name);
        let temp_sha = env::temp_dir().join(format!("{}.sha256", asset_name));
        let _ = fs::create_dir_all(&temp_dir);

        println!("  Đang tải: {}", url.dimmed());

        let cmd = format!(
            "curl -fsSL \"{}\" -o \"{}\" && (curl -fsSL \"{}\" -o \"{}\" || curl -fsSL \"{}\" -o \"{}\" || true) && tar -xzf \"{}\" -C \"{}\"",
            url,
            temp_archive.display(),
            checksum_url,
            temp_sha.display(),
            sums_url,
            temp_sha.display(),
            temp_archive.display(),
            temp_dir.display()
        );

        let status = Command::new("sh").arg("-c").arg(&cmd).status()?;
        if !status.success() {
            bail!("Không thể tải hoặc giải nén release từ GitHub. Vui lòng kiểm tra kết nối mạng.");
        }

        if temp_sha.exists() {
            let expected_checksum = fs::read_to_string(&temp_sha).unwrap_or_default();
            if !expected_checksum.trim().is_empty() {
                let actual_archive_sha = compute_file_sha256(&temp_archive)?;
                if !verify_checksum(&actual_archive_sha, &expected_checksum) {
                    let _ = fs::remove_file(&temp_archive);
                    let _ = fs::remove_file(&temp_sha);
                    let _ = fs::remove_dir_all(&temp_dir);
                    bail!(
                        "[-] Checksum không khớp — file tải về có thể bị hỏng hoặc bị can thiệp. Hủy cập nhật."
                    );
                }
                println!(
                    "  [+] Checksum SHA-256 hợp lệ: {}",
                    actual_archive_sha.dimmed()
                );
            }
        }

        let extracted_dot = find_extracted_binary(&temp_dir, "dot")?;

        fs::copy(&extracted_dot, &target_dest)?;
        let _ = Command::new("chmod").arg("+x").arg(&target_dest).status();
        let _ = fs::remove_dir_all(&temp_dir);
        let _ = fs::remove_file(&temp_archive);
        let _ = fs::remove_file(&temp_sha);

        if let Some(ref h_bin) = home_bin
            && h_bin != &target_dest
        {
            if let Some(p) = h_bin.parent() {
                let _ = fs::create_dir_all(p);
            }
            let _ = fs::copy(&target_dest, h_bin);
            let _ = Command::new("chmod").arg("+x").arg(h_bin).status();
        }
    }

    println!(
        "{}",
        format!(
            "  [+] Đã cập nhật binary 'dot' thành công tại: {}",
            target_dest.display()
        )
        .green()
    );
    println!("\n{}", "[+] Cập nhật CLI hoàn tất!".green().bold());

    Ok(())
}

fn find_extracted_binary(dir: &std::path::Path, bin_name: &str) -> Result<PathBuf> {
    if dir.is_dir() {
        for entry in fs::read_dir(dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.is_file() && path.file_name().map(|n| n == bin_name).unwrap_or(false) {
                return Ok(path);
            }
            if path.is_dir()
                && let Ok(found) = find_extracted_binary(&path, bin_name)
            {
                return Ok(found);
            }
        }
    }
    bail!(
        "Không tìm thấy binary '{}' trong file nén release.",
        bin_name
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_compute_sha256() {
        let hash = compute_sha256(b"hello world");
        assert_eq!(
            hash,
            "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"
        );
    }

    #[test]
    fn test_compute_file_sha256() {
        let dir = tempdir().unwrap();
        let file_path = dir.path().join("sample.txt");
        fs::write(&file_path, b"hello world").unwrap();

        let hash = compute_file_sha256(&file_path).unwrap();
        assert_eq!(
            hash,
            "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"
        );
    }

    #[test]
    fn test_verify_checksum_valid_cases() {
        let sample_hash = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9";

        // Raw single hash
        assert!(verify_checksum(sample_hash, sample_hash));
        assert!(verify_checksum(
            sample_hash,
            "B94D27B9934D3E08A52E52D7DA7DABFAC484EFE37A5380EE9088F7ACE2EFCDE9\n"
        ));

        // sha256sum single line format
        assert!(verify_checksum(
            sample_hash,
            "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9  dot.zip\n"
        ));

        // Multi-line SHA256SUMS.txt format
        let sums_content = format!(
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  empty.tar.gz\n{}  dot-x86_64.zip\n",
            sample_hash
        );
        assert!(verify_checksum(sample_hash, &sums_content));
    }

    #[test]
    fn test_verify_checksum_invalid_cases() {
        let sample_hash = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9";
        let wrong_hash = "0000000000000000000000000000000000000000000000000000000000000000";

        assert!(!verify_checksum(sample_hash, wrong_hash));
        assert!(!verify_checksum(
            sample_hash,
            "0000000000000000000000000000000000000000000000000000000000000000  dot.zip\n"
        ));
        assert!(!verify_checksum(sample_hash, ""));
    }
}
