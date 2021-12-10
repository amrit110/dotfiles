# Path to your oh-my-zsh installation.
export ZSH="/Users/amritk/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(
    git
    zsh-autosuggestions
    tmux
    colored-man-pages
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# powerline-shell
function powerline_precmd() {
    PS1="$(powerline-shell --shell zsh $?)"
}

function install_powerline_precmd() {
  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "powerline_precmd" ]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ]; then
    install_powerline_precmd
fi

# vim keybindings
bindkey -v
bindkey jj vi-cmd-mode

# zsh keybindings
bindkey '^ ' autosuggest-accept

# custom aliases
alias python=python3
alias vim="nvim"
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

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/amritk/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/amritk/opt/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/Users/amritk/opt/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/Users/amritk/opt/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

export PATH="/usr/local/opt/bzip2/bin:$PATH"
