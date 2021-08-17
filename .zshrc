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

alias gs01="ssh amrit.krishnan@gpuserver01-mtl"
alias gs02="ssh amrit.krishnan@gpuserver02-mtl"
alias gs03="ssh amrit.krishnan@gpuserver03-mtl"
alias gs04="ssh amrit.krishnan@gpuserver04-mtl"
alias gs05="ssh amrit.krishnan@gpuserver05-mtl"
alias gs06="ssh amrit.krishnan@gpuserver06-mtl"
alias gs07="ssh amrit.krishnan@gpuserver07-mtl"
alias gs08="ssh amrit.krishnan@gpuserver08-mtl"
alias gs09="ssh amrit.krishnan@gpuserver09-mtl"
alias gs01-mun="ssh amrit.krishnan@gpuserver01-mun"
alias db01="ssh amrit.krishnan@dbserver01-mtl"
alias st02="ssh amrit.krishnan@storage02-mtl"
alias st01-mun="ssh amrit.krishnan@storage01-mun"
alias linear="ssh amrit.krishnan@linear"

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
