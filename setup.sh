#!/usr/bin/env bash

# Dotfiles Setup Script
# This script sets up a complete development environment with:
# - Oh My Zsh + Powerlevel10k
# - pyenv for Python version management
# - Neovim with plugins
# - PowerShell (if requested)
# - Alacritty terminal configuration
# - All dotfiles from this repository

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
readonly LOG_FILE="$DOTFILES_DIR/setup.log"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

info() { log "INFO" "$@"; echo -e "${BLUE}ℹ ${*}${NC}"; }
success() { log "SUCCESS" "$@"; echo -e "${GREEN}✓ ${*}${NC}"; }
warning() { log "WARNING" "$@"; echo -e "${YELLOW}⚠ ${*}${NC}"; }
error() { log "ERROR" "$@"; echo -e "${RED}✗ ${*}${NC}"; }

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *) error "Unsupported platform: $(uname -s)"; exit 1 ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create backup directory
create_backup() {
    info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
}

# Backup existing config file
backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        local backup_path="$BACKUP_DIR/$(basename "$file")"
        info "Backing up $file to $backup_path"
        cp -r "$file" "$backup_path"
    fi
}

# Install package manager based on platform
install_package_manager() {
    local platform="$1"

    case "$platform" in
        macos)
            if ! command_exists brew; then
                info "Installing Homebrew..."
                NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                # Add Homebrew to PATH for Apple Silicon Macs
                if [[ -f "/opt/homebrew/bin/brew" ]]; then
                    export PATH="/opt/homebrew/bin:$PATH"
                fi
            else
                success "Homebrew already installed"
            fi
            ;;
        linux)
            # Clean up any broken Microsoft repository from previous failed attempts
            if command_exists apt-get && [[ -f /etc/apt/sources.list.d/microsoft-prod.list ]]; then
                if grep -q "microsoft-ubuntu-24.04-prod" /etc/apt/sources.list.d/microsoft-prod.list 2>/dev/null; then
                    info "Removing broken Microsoft repository configuration..."
                    sudo rm -f /etc/apt/sources.list.d/microsoft-prod.list
                fi
            fi

            # Update package lists
            if command_exists apt-get; then
                sudo apt-get update
            elif command_exists yum; then
                sudo yum update
            elif command_exists pacman; then
                sudo pacman -Sy
            fi
            ;;
    esac
}

# Install essential tools
install_essentials() {
    local platform="$1"
    
    info "Installing essential tools..."
    
    case "$platform" in
        macos)
            # Install via Homebrew
            local packages=(
                "git"
                "curl"
                "wget"
                "zsh"
                "tmux"
                "neovim"
                "ripgrep"
                "fd"
                "fzf"
                "font-meslo-lg-nerd-font"
            )
            
            for package in "${packages[@]}"; do
                if brew list "$package" &>/dev/null; then
                    success "$package already installed"
                else
                    info "Installing $package..."
                    brew install "$package"
                fi
            done
            
            # Handle alacritty separately as it's a cask
            if command_exists alacritty || [[ -d "/Applications/Alacritty.app" ]]; then
                success "alacritty already installed"
            else
                info "Installing alacritty..."
                brew install --cask alacritty
            fi
            ;;
        linux)
            # Determine package manager and install
            if command_exists apt-get; then
                local packages=(
                    "git"
                    "curl"
                    "wget"
                    "zsh"
                    "tmux"
                    "neovim"
                    "ripgrep"
                    "fd-find"
                    "fzf"
                    "build-essential"
                )
                
                for package in "${packages[@]}"; do
                    if dpkg -l | grep -q "^ii  $package "; then
                        success "$package already installed"
                    else
                        info "Installing $package..."
                        sudo apt-get install -y "$package"
                    fi
                done
                
                # Install Alacritty from snap if available and not already installed
                if command_exists snap && ! command_exists alacritty; then
                    info "Installing alacritty..."
                    sudo snap install alacritty --classic
                elif command_exists alacritty; then
                    success "alacritty already installed"
                fi
                
            elif command_exists yum; then
                sudo yum install -y git curl wget zsh tmux neovim ripgrep fd-find fzf
            elif command_exists pacman; then
                sudo pacman -S --needed git curl wget zsh tmux neovim ripgrep fd fzf alacritty
            fi
            ;;
    esac
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        success "Oh My Zsh already installed"
        return
    fi

    info "Installing Oh My Zsh..."
    export RUNZSH=no  # Don't run zsh after installation
    export CHSH=no    # Don't prompt to change shell
    export KEEP_ZSHRC=yes  # Keep existing .zshrc
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    
    if [[ -d "$p10k_dir" ]]; then
        success "Powerlevel10k already installed"
        return
    fi
    
    info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
}

# Install Zsh plugins
install_zsh_plugins() {
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    # zsh-autosuggestions
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    else
        success "zsh-autosuggestions already installed"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    else
        success "zsh-syntax-highlighting already installed"
    fi
}

# Install pyenv for Python version management
install_pyenv() {
    if command_exists pyenv; then
        success "pyenv already installed"
        return
    fi
    
    info "Installing pyenv..."
    local platform="$(detect_platform)"
    
    case "$platform" in
        macos)
            if command_exists brew; then
                brew install pyenv
            else
                # Install via pyenv installer
                curl https://pyenv.run | bash
            fi
            ;;
        linux)
            # Install dependencies first
            if command_exists apt-get; then
                sudo apt-get update
                sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
                    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                    libffi-dev liblzma-dev
            elif command_exists yum; then
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y zlib-devel bzip2 bzip2-devel readline-devel \
                    sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel \
                    findutils
            elif command_exists pacman; then
                sudo pacman -S --needed base-devel openssl zlib xz tk
            fi
            
            # Install pyenv via installer
            curl https://pyenv.run | bash
            ;;
    esac
    
    # Add pyenv to shell configuration
    local shell_config="$HOME/.zshrc"
    if [[ -f "$shell_config" ]]; then
        if ! grep -q 'export PYENV_ROOT=' "$shell_config"; then
            info "Adding pyenv configuration to $shell_config"
            {
                echo ""
                echo "# Pyenv configuration"
                echo 'export PYENV_ROOT="$HOME/.pyenv"'
                echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
                echo 'eval "$(pyenv init --path)"'
                echo 'eval "$(pyenv init -)"'
                echo '# pyenv-virtualenv plugin is deprecated, removed virtualenv-init'
            } >> "$shell_config"
        fi
    fi
    
    success "pyenv installed successfully"
    info "Restart your shell or run 'exec zsh' to use pyenv"
}

# Install Neovim dependencies
install_neovim_deps() {
    info "Installing Neovim dependencies..."
    
    # Install vim-plug if not present
    local plug_file="$HOME/.local/share/nvim/site/autoload/plug.vim"
    if [[ ! -f "$plug_file" ]]; then
        info "Installing vim-plug..."
        mkdir -p "$(dirname "$plug_file")"
        curl -fLo "$plug_file" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        success "vim-plug already installed"
    fi
    
    # Install Node.js for LSP servers (if not present)
    if ! command_exists node; then
        local platform="$(detect_platform)"
        case "$platform" in
            macos)
                if command_exists brew; then
                    brew install node
                fi
                ;;
            linux)
                if command_exists apt-get; then
                    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                elif command_exists yum; then
                    curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                    sudo yum install -y nodejs
                fi
                ;;
        esac
    fi
    
    # Install Python support for Neovim
    if command_exists python3; then
        local platform="$(detect_platform)"
        case "$platform" in
            linux)
                # Try system package manager first (handles PEP 668 externally-managed-environment)
                if command_exists apt-get; then
                    if ! dpkg -l | grep -q "^ii  python3-pynvim "; then
                        info "Installing python3-pynvim via apt..."
                        sudo apt-get install -y python3-pynvim 2>/dev/null || {
                            warning "Could not install python3-pynvim via apt, trying pip..."
                            python3 -m pip install --user --break-system-packages pynvim 2>/dev/null || \
                                warning "Could not install pynvim. Install manually if needed: pip install pynvim"
                        }
                    fi
                elif command_exists yum; then
                    sudo yum install -y python3-neovim 2>/dev/null || \
                        python3 -m pip install --user pynvim 2>/dev/null || \
                        warning "Could not install pynvim. Install manually if needed: pip install pynvim"
                elif command_exists pacman; then
                    sudo pacman -S --needed --noconfirm python-pynvim 2>/dev/null || \
                        python3 -m pip install --user pynvim 2>/dev/null || \
                        warning "Could not install pynvim. Install manually if needed: pip install pynvim"
                else
                    # Fallback to pip with break-system-packages
                    python3 -m pip install --user --break-system-packages pynvim 2>/dev/null || \
                        warning "Could not install pynvim. Install manually if needed: pip install pynvim"
                fi
                ;;
            macos)
                # On macOS, pip should work fine
                python3 -m pip install --user pynvim 2>/dev/null || \
                    warning "Could not install pynvim. Install manually if needed: pip install pynvim"
                ;;
        esac
    fi
}

# Install PowerShell (optional)
install_powershell() {
    if command_exists pwsh; then
        success "PowerShell already installed"
        return
    fi

    # Skip PowerShell installation by default in automated mode
    # Set INSTALL_POWERSHELL=1 environment variable to enable
    if [[ "${INSTALL_POWERSHELL:-0}" != "1" ]]; then
        info "Skipping PowerShell installation (set INSTALL_POWERSHELL=1 to install)"
        return
    fi

    local platform="$(detect_platform)"
    info "Installing PowerShell..."

    case "$platform" in
        macos)
            if command_exists brew; then
                brew install --cask powershell
            fi
            ;;
        linux)
            if command_exists apt-get; then
                # Ubuntu/Debian
                curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

                # Determine Ubuntu version and use appropriate repository
                local ubuntu_version=$(lsb_release -rs)
                local ubuntu_codename=$(lsb_release -cs)

                # Microsoft doesn't always have repos for the latest Ubuntu version immediately
                # Fall back to 22.04 (jammy) repo for newer versions
                if [[ "$ubuntu_version" == "24.04" ]] || [[ ! $(curl -s -o /dev/null -w "%{http_code}" "https://packages.microsoft.com/repos/microsoft-ubuntu-${ubuntu_version}-prod/dists/${ubuntu_codename}/Release") == "200" ]]; then
                    warning "Using Ubuntu 22.04 repository for PowerShell (24.04 not yet available)"
                    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-22.04-prod jammy main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
                else
                    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-${ubuntu_version}-prod ${ubuntu_codename} main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
                fi

                sudo apt-get update
                sudo apt-get install -y powershell
            fi
            ;;
    esac
}

# Copy dotfiles
copy_dotfiles() {
    info "Copying dotfiles..."
    
    # Copy each dotfile individually
    local files=(
        ".zshrc:$HOME/.zshrc"
        ".p10k.zsh:$HOME/.p10k.zsh"
        ".vimrc:$HOME/.vimrc"
        ".bashrc:$HOME/.bashrc"
        ".profile:$HOME/.profile"
        ".tmux.conf:$HOME/.tmux.conf"
        "alacritty.toml:$HOME/.config/alacritty/alacritty.toml"
        "nvim/.config/nvim/init.vim:$HOME/.config/nvim/init.vim"
        "gruvbox-dark.terminal:$HOME/.config/gruvbox-dark.terminal"
    )
    
    for file_mapping in "${files[@]}"; do
        local source_file="${file_mapping%%:*}"
        local dest_path="${file_mapping##*:}"
        local source_path="$DOTFILES_DIR/$source_file"
        
        if [[ -f "$source_path" ]]; then
            # Create destination directory if it doesn't exist
            mkdir -p "$(dirname "$dest_path")"
            
            # Backup existing file
            backup_file "$dest_path"
            
            # Copy file
            info "Copying $source_file -> $dest_path"
            cp "$source_path" "$dest_path"
        else
            warning "Source file not found: $source_path"
        fi
    done
}

# Install Neovim plugins
install_nvim_plugins() {
    if [[ ! -f "$HOME/.config/nvim/init.vim" ]]; then
        warning "Neovim config not found, skipping plugin installation"
        return
    fi
    
    info "Installing Neovim plugins..."
    nvim --headless +PlugInstall +qall
}

# Set Zsh as default shell
set_zsh_default() {
    if [[ "$SHELL" == *"zsh" ]]; then
        success "Zsh is already the default shell"
        return
    fi

    info "Setting Zsh as default shell..."

    # Add zsh to /etc/shells if it's not there
    local zsh_path
    zsh_path=$(which zsh)
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change default shell (may require password on some systems)
    # On macOS with admin privileges, this should work without password
    if chsh -s "$zsh_path" 2>/dev/null; then
        success "Default shell changed to Zsh (restart terminal to take effect)"
    else
        warning "Could not change default shell automatically. Run manually: chsh -s $zsh_path"
    fi
}

# Clean up sensitive information from config files
clean_sensitive_info() {
    info "Cleaning sensitive information from config files..."
    
    local zshrc_path="$HOME/.zshrc"
    if [[ -f "$zshrc_path" ]]; then
        # Remove GitHub token and other sensitive data
        sed -i.bak 's/export GITHUB_GIST_TOKEN=.*/# export GITHUB_GIST_TOKEN="your_token_here"/' "$zshrc_path"
        
        # Remove specific server aliases
        sed -i.bak '/alias.*ssh.*@.*vectorinstitute.ai/d' "$zshrc_path"
        sed -i.bak '/alias.*ssh.*@.*vws[0-9]/d' "$zshrc_path"
        
        success "Cleaned sensitive information from .zshrc"
    fi
}

# Post-installation instructions
show_post_install_info() {
    success "Setup completed successfully!"
    echo
    info "📋 Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Configure Powerlevel10k theme: p10k configure"
    echo "  3. Install additional Neovim language servers as needed"
    echo "  4. Update your GitHub token and other personal settings in ~/.zshrc"
    echo
    info "📁 Backup location: $BACKUP_DIR"
    info "📜 Setup log: $LOG_FILE"
    echo
    warning "⚠  Some changes require a terminal restart to take effect"
}

# Main execution
main() {
    local platform
    
    info "🚀 Starting dotfiles setup..."
    log "INFO" "Setup started by $(whoami) on $(hostname)"
    
    # Detect platform
    platform=$(detect_platform)
    info "Detected platform: $platform"
    
    # Create backup directory
    create_backup
    
    # Install package manager
    install_package_manager "$platform"
    
    # Install essential tools
    install_essentials "$platform"
    
    # Install Oh My Zsh and plugins
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    
    # Install pyenv for Python version management
    install_pyenv
    
    # Install Neovim dependencies
    install_neovim_deps
    
    # Install PowerShell (optional)
    install_powershell
    
    # Copy dotfiles
    copy_dotfiles
    
    # Clean sensitive information
    clean_sensitive_info
    
    # Install Neovim plugins
    install_nvim_plugins
    
    # Set Zsh as default shell
    set_zsh_default
    
    # Show post-installation info
    show_post_install_info
    
    log "INFO" "Setup completed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
