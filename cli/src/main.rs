#![allow(dead_code)]

use anyhow::Result;

use clap::{Parser, Subcommand};
use std::path::PathBuf;

mod commands;
mod linker;
mod paths;
mod shell_cache;
mod theme_engine;

#[derive(Parser, Debug)]
#[command(name = "dot", about = "Kachitaro Dotfiles CLI", version)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    /// Run the installation script.
    Install {
        /// Overwrite existing configs
        #[arg(short, long)]
        force: bool,
    },
    /// Remove dotfiles symlinks and configurations.
    Uninstall,
    /// Adopt a new config folder into dotfiles.
    Add {
        /// Path to target config folder or file to adopt
        path: PathBuf,
    },
    /// Restore real files to your system (unlink).
    Eject,
    /// Re-link dotfiles symlinks and configurations into the system (re-sync).
    Inject {
        /// Force overwrite without backup
        #[arg(short, long)]
        force: bool,
    },
    /// Initialize a standalone dotfiles workspace.
    Init {
        /// Custom destination path for dotfiles directory (defaults to ~/.dotfiles)
        path: Option<PathBuf>,
        /// Overwrite existing default templates if already present
        #[arg(short, long)]
        force: bool,
    },
    /// Self-update dot binary to the latest version from GitHub Release.
    Update,
    /// Theme engine and configuration management.
    Theme {
        #[command(subcommand)]
        action: ThemeCommands,
    },
}

#[derive(Subcommand, Debug)]
pub enum ThemeCommands {
    /// Recompile theme.json and apply dynamically.
    Reload,
    /// Print absolute path of themes/generated/ directory.
    Path,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Init { path, force } => commands::init::execute(path, force)?,
        Commands::Install { force } => commands::install::execute(force)?,
        Commands::Uninstall => commands::uninstall::execute()?,
        Commands::Update => commands::update::execute()?,
        Commands::Add { path } => commands::add::execute(path)?,
        Commands::Eject => commands::eject::execute()?,
        Commands::Inject { force } => commands::inject::execute(force)?,
        Commands::Theme { action } => match action {
            ThemeCommands::Reload => commands::theme::reload()?,
            ThemeCommands::Path => commands::theme::print_path()?,
        },
    }

    Ok(())
}
