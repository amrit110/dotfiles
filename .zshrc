# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    tmux
    colored-man-pages
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# vim keybindings
bindkey -v
bindkey jj vi-cmd-mode

# zsh keybindings
bindkey '^ ' autosuggest-accept

# custom aliases
alias python=python3
alias vim="nvim -u ~/.config/nvim/init.vim"
alias tmux="TERM=screen-256color-bce tmux"
alias ls="ls -lhFG"

# funcs
function backup() {
    newname=$1.`date +%Y-%m-%d.%H.%M.bak`;
    mv $1 $newname;
    echo "Backed up $1 to $newname."
    cp -p $newname $1;
}

function dev_tmux() {
    tmux new -s dev -d;
    tmux rename-window -t 1 'Main';
    tmux split-window -v 'htop';
    tmux split-window -h -t 0;
    tmux a -t dev;
}

# python
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
alias pip=pip3

# github
export GITHUB_GIST_TOKEN="REDACTED_TOKEN"

# Vector Compute
alias vc="ssh amritk@v.vectorinstitute.ai"
alias qc="ssh amritk@q.vectorinstitute.ai"
alias mc="ssh amritk@m.vectorinstitute.ai"
alias vws71="ssh amritk@vws71"
alias vws9="ssh vws9@10.6.10.127"

# Add to PATH
export PATH="${HOME}/.local/bin:$PATH"
export PATH="${HOME}/.cargo/bin:$PATH"
export PATH="${HOME}/.local/share/nvim:${PATH}"
export PATH="/usr/local/cuda-11.5/bin:${PATH}"
export LD_LIBRARY_PATH="/usr/local/cuda-11.5/lib64:$LD_LIBRARY_PATH"
export LDFLAGS="-L/opt/homebrew/opt/openblas/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openblas/include"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# tmux
alias tmux="TERM=screen-256color-bce tmux"
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/amritkrishnan/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/amritkrishnan/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/amritkrishnan/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/amritkrishnan/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
