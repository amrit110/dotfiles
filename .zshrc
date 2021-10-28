# Path to your oh-my-zsh installation.
export ZSH="/Users/amritk/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(git)

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

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
