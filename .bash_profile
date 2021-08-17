
# Funcs
function backup() {
    newname=$1.'date +%Y-%m-%d.%H%M.bak';
    mv $1 $newname;
    echo "Backed up $1 to $newname.";
    cp -p $newname $1;
}


# Vars
export BASH_CONF="bash_profile"
export GITHUB_TOKEN="637a5bcdff7fbdbe0f34c81c2a531a8b0db398eb"


# Execs
[[ -s ~/.bashrc ]] && source ~/.bashrc
