# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob nomatch
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename $HOME'/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

export EDITOR=vi
export USE_EDITOR=$EDITOR
export VISUAL=$EDITOR
# FIXME: check first if they are available
export LC_ALL=en_US.UTF-8

is_linux () {
  [[ $('uname') == 'Linux' ]];
}

is_osx () {
  [[ $('uname') == 'Darwin' ]]
}

if is_osx; then
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  if [[ ! -f '/usr/local/bin/brew' ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap homebrew/boneyard
  fi
elif is_linux; then
  local BREW_PREFIX=$HOME/.linuxbrew
  export PATH=$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$BREW_PREFIX/share/python:$PATH
  if [[ ! -d $BREW_PREFIX ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/linuxbrew/go/install)"
    brew doctor
  fi

  export PYTHONPATH=$BREW_PREFIX/lib/python2.7/site-packages:$PYTHONPATH
  export XDG_DATA_DIRS=$BREW_PREFIX/share:$XDG_DATA_DIRS
  export FPATH=$BREW_PREFIX/share/zsh/site-functions:$FPATH
fi

PROMPT_LEAN_TMUX=""

my_zgen() {
  DISABLE_AUTO_UPDATE="true"
  # FIXME: allow installation with several open shells

  if [[ ! -f ~/.zgen.zsh ]]; then
    curl -L https://raw.githubusercontent.com/tarjoilija/zgen/master/zgen.zsh > ~/.zgen.zsh
  fi

  source ~/.zgen.zsh

  if ! zgen saved; then
    echo "Creating zgen save"

    zgen oh-my-zsh

    zgen oh-my-zsh plugins/brew
    zgen oh-my-zsh plugins/chruby
    zgen oh-my-zsh plugins/command-not-found
    zgen oh-my-zsh plugins/docker
    zgen oh-my-zsh plugins/extract
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/golang
    zgen oh-my-zsh plugins/pip
    zgen oh-my-zsh plugins/python
    zgen oh-my-zsh plugins/ssh-agent
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/tmuxinator
    zgen oh-my-zsh plugins/vagrant
    zgen oh-my-zsh plugins/virtualenv

    zgen load caarlos0/zsh-mkc
    zgen load felixr/docker-zsh-completion
    zgen load joel-porquet/zsh-dircolors-solarized
    zgen load marzocchi/zsh-notify
    zgen load oconnor663/zsh-sensible
    zgen load rimraf/k
    zgen load sharat87/autoenv
    zgen load zlsun/solarized-man
    zgen load zsh-users/zsh-completions

    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-history-substring-search

    if [[ `brew ls --versions fzf|wc -l` -gt 0 ]]; then
      zgen load $(brew --prefix fzf)/shell
    fi

    zgen load miekg/lean

    zgen save
  fi
}

my_zplug() {
  if [ ! -d ~/.zplug ]; then
    printf "Install zplug? [y/N]: "
    if read -q; then
      echo;
      git clone https://github.com/b4b4r07/zplug ~/.zplug
      source ~/.zplug/zplug
      # manage zplug by itself
      zplug update --self
    fi
  fi

  if [ -f ~/.zplug/zplug ]; then
    source ~/.zplug/zplug

    # Make sure you use double quotes
    zplug "b4b4r07/zplug"

    zplug "plugins/brew", from:oh-my-zsh
    zplug "plugins/chruby", from:oh-my-zsh
    zplug "plugins/command-not-found", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/docker", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/extract", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/git", from:oh-my-zsh
    zplug "plugins/golang", from:oh-my-zsh
    zplug "plugins/pip", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/python", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/ssh-agent", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/sudo", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/tmuxinator", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/vagrant", from:oh-my-zsh, ignore:oh-my-zsh.sh
    zplug "plugins/virtualenv", from:oh-my-zsh, ignore:oh-my-zsh.sh

    zplug "caarlos0/zsh-mkc"
    zplug "joel-porquet/zsh-dircolors-solarized"
    zplug "marzocchi/zsh-notify"
    zplug "oconnor663/zsh-sensible"
    zplug "rimraf/k"
    zplug "sharat87/autoenv"
    zplug "zlsun/solarized-man"
    zplug "zsh-users/zsh-completions"

    zplug "zsh-users/zsh-syntax-highlighting", nice:19
    zplug "zsh-users/zsh-history-substring-search"

    if [[ `brew ls --versions fzf|wc -l` -gt 0 ]]; then
      zplug "$(brew --prefix fzf)/shell", from:local
    fi

    zplug "miekg/lean"

    # Install plugins if there are plugins that have not been installed
    if ! zplug check --verbose; then
      printf "Install zsh plugins? [y/N]: "
      if read -q; then
        echo; zplug install
      fi
    fi

    # Then, source plugins and add commands to $PATH
    zplug load # --verbose
  fi
}

case $ZSH_PLUGIN_MANAGER in
  zplug)
    my_zplug
    ;;
  zgen|*)
    my_zgen
    ;;
esac

if [[ ! -f $HOME/.zsh-dircolors.config ]]; then
  setupsolarized dircolors.256dark
fi

setopt interactivecomments
setopt CORRECT
unsetopt nomatch

if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
if [[ `tmux -V |cut -d ' ' -f2` -ge 2.1 ]]; then
  alias tmux='tmux -2 -f ~/.config/tmux/tmux-2.1.conf'
else
  alias tmux='tmux -2 -f ~/.config/tmux/tmux-2.0.conf'
fi

# TMUX
if [[ -z $TMUX ]]; then
  # Attempt to discover a detached session and attach it, else create a new session
  CURRENT_USER=$(whoami)
  if tmux has-session -t $CURRENT_USER 2>/dev/null; then
    tmux attach-session -t $CURRENT_USER
  else
    tmux new-session -s $CURRENT_USER
  fi
fi

if which exa >/dev/null 2>&1; then
  alias ls='exa'
elif which ls++ >/dev/null 2>&1; then
  alias ls='ls++'
else
  alias ls='ls --color=auto'
fi

if which nvim >/dev/null 2>&1; then
  alias vim='nvim'
fi

alias ll='ls -l'
if which vim >/dev/null 2>&1; then
  alias vi='vim'
fi

if [[ ! -z $TMUX ]]; then
  alias fzf='fzf-tmux'
fi

if [[ -x `which ag` ]]; then
  export FZF_DEFAULT_COMMAND='ag -l -g ""'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
export FZF_DEFAULT_OPTS="--extended-exact"

# v - open files in ~/.viminfo and ~/.nviminfo
v() {
  local files
  files=$(grep --no-filename '^>' ~/.viminfo ~/.nviminfo | cut -c3- |
          while read line; do
            [ -f "${line/\~/$HOME}" ] && echo "$line"
          done | fzf -d -m -q "$*" -1) && vim ${files//\~/$HOME}
}
