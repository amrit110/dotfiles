# Dotfiles

Personal development environment configuration files for macOS and Linux.

## What's Included

- **Shell Configuration**: Zsh with Oh My Zsh and Powerlevel10k theme
- **Terminal**: Alacritty configuration with Gruvbox color scheme
- **Editor**: Neovim configuration with plugins
- **Python**: pyenv for Python version management
- **Development Tools**: Essential CLI tools (ripgrep, fd, fzf, tmux)

## Quick Setup

Run the automated setup script:

```bash
git clone git@github.com:amrit110/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The setup script will:
- Install package managers (Homebrew on macOS)
- Install essential development tools
- Configure Zsh with Oh My Zsh and plugins
- Set up Neovim with vim-plug
- Install Python development environment with pyenv
- Copy configuration files (with backups)
- Optionally install PowerShell

## Manual Installation

Individual configuration files can be copied manually:

- `alacritty.toml` → `~/.config/alacritty/alacritty.toml`
- `nvim/` → `~/.config/nvim/`
- `gruvbox-dark.terminal` → Terminal color scheme

## Post-Setup

After running the setup:

1. Restart your terminal or run `exec zsh`
2. Configure Powerlevel10k: `p10k configure`
3. Install Neovim language servers as needed
4. Update personal settings in `~/.zshrc`

## Supported Platforms

- macOS (tested)
- Ubuntu/Debian Linux
- RHEL/CentOS Linux
- Arch Linux

## Backup

The setup script automatically creates backups in `~/.dotfiles-backup-<timestamp>` before making changes.
