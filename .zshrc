# Via https://tanguy.ortolo.eu/blog/article25/shrc
#
# Zsh always executes zshenv. Then, depending on the case:
# - run as a login shell, it executes zprofile;
# - run as an interactive, it executes zshrc;
# - run as a login shell, it executes zlogin.
#
# At the end of a login session, it executes zlogout, but in reverse order, the
# user-specific file first, then the system-wide one, constituting a chiasmus
# with the zlogin files.

# Thanks to https://github.com/elifarley/shellbase/blob/master/.zshrc
test -r ~/.shell-common && source ~/.shell-common
test -r ~/.shell-aliases && source ~/.shell-aliases

setopt appendhistory
setopt autocd
setopt correct_all
setopt extendedglob
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt interactive_comments
setopt pushd_ignore_dups

# EMACS mode
bindkey -e
# TODO: This might be neat: http://unix.stackexchange.com/a/47425
# TODO: Nice list of bindings: http://zshwiki.org/home/zle/bindkeys
# Make CTRL+Arrow skip words
# rxvt
bindkey "^[Od" backward-word
bindkey "^[Oc" forward-word
# xterm
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
# gnome-terminal
bindkey "^[OD" backward-word
bindkey "^[OC" forward-word

# Ignore interactive commands from history
export HISTORY_IGNORE="(ls|bg|fg|pwd|exit|cd ..)"

# FIXME: check first if they are available
export LC_ALL=en_US.UTF-8

is_linux () {
  [[ $('uname') == 'Linux' ]];
}

is_osx () {
  [[ $('uname') == 'Darwin' ]]
}

fpath=(/usr/share/zsh/vendor-completions/ $fpath)

if is_osx; then
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  if [[ ! -f '/usr/local/bin/brew' ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap homebrew/boneyard
  fi
elif is_linux; then
  export PATH=$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$BREW_PREFIX/share/python:$PATH
  if [[ ! -d $BREW_PREFIX ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/linuxbrew/go/install)"
    brew doctor
    mkdir -p $BREW_PREFIX/share/zsh/site-functions
    ln -s $BREW_PREFIX/Library/Contributions/brew_zsh_completion.zsh $BREW_PREFIX/share/zsh/site-functions/_brew
  fi

  export XDG_DATA_DIRS=$BREW_PREFIX/share:$XDG_DATA_DIRS
  export XML_CATALOG_FILES=$BREW_PREFIX/etc/xml/catalog
  export ANDROID_HOME=$BREW_PREFIX/opt/android-sdk
  export MONO_GAC_PREFIX=$BREW_PREFIX
  fpath=($BREW_PREFIX/share/zsh/site-functions $fpath)
fi

PROMPT_LEAN_TMUX=""
ENHANCD_COMMAND="ecd"

export ZPLUG_HOME=$BREW_PREFIX/opt/zplug

if [ -f $ZPLUG_HOME/init.zsh ]; then
  source $ZPLUG_HOME/init.zsh

  zplug "plugins/command-not-found", from:oh-my-zsh, ignore:oh-my-zsh.sh
  zplug "plugins/extract", from:oh-my-zsh, ignore:oh-my-zsh.sh
  zplug "plugins/pip", from:oh-my-zsh, ignore:oh-my-zsh.sh
  zplug "plugins/python", from:oh-my-zsh, ignore:oh-my-zsh.sh
  zplug "plugins/ssh-agent", from:oh-my-zsh, ignore:oh-my-zsh.sh
  # Load after ssh-agent
  zplug "plugins/gpg-agent", from:oh-my-zsh, ignore:oh-my-zsh.sh
  zplug "plugins/sudo", from:oh-my-zsh, ignore:oh-my-zsh.sh
  zplug "plugins/vagrant", from:oh-my-zsh, ignore:oh-my-zsh.sh
  zplug "plugins/virtualenv", from:oh-my-zsh, ignore:oh-my-zsh.sh

  zplug "b4b4r07/enhancd"
  zplug "caarlos0/zsh-mkc"
  zplug "joel-porquet/zsh-dircolors-solarized"
  zplug "marzocchi/zsh-notify", use:"notify.plugin.zsh"
  zplug "mrowa44/emojify", as:command
  zplug "oconnor663/zsh-sensible"
  zplug "rimraf/k"
  zplug "sharat87/autoenv"
  zplug "zlsun/solarized-man"
  zplug "zsh-users/zsh-completions"
  zplug "zsh-users/zsh-history-substring-search"
  zplug "zsh-users/zsh-syntax-highlighting", nice:19

  zplug "DoomHammer/gogh", use:"themes/solarized.dark.sh", at:"overall"

  if [[ $(brew ls --versions fzf|wc -l) -gt 0 ]]; then
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

if [[ ! -f $HOME/.zsh-dircolors.config ]]; then
  setupsolarized dircolors.256dark
fi

if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Teleconsole does not preserve TMUX env variable
if [[ -z "$TMUX" ]] && [[ -z "$TELEPORT_SESSION" ]]; then
  # Attempt to discover a detached session and attach it, else create a new
  # session
  CURRENT_USER=$(whoami)
  if tmux has-session -t $CURRENT_USER 2>/dev/null; then
    tmux attach-session -t $CURRENT_USER
  else
    tmux new-session -s $CURRENT_USER
  fi
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
