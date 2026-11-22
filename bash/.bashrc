#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
if command -v nvim >/dev/null 2>&1; then
  alias vi='nvim'
  alias vim='nvim'
  export EDITOR='nvim'
  export VISUAL='nvim'
fi
alias l='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
export MANPAGER='nvim +Man!'
PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"
eval "$(fzf --bash)"
eval "$(zoxide init --cmd cd bash)"
. "$HOME/.cargo/env"
# Start the SSH agent for this session
eval "$(ssh-agent -s)" > /dev/null
# Add your specific key (silencing errors if it's already there or missing)
ssh-add ~/.ssh/github_test 2>/dev/null
# Automatically kill the agent when the terminal session ends
trap "ssh-agent -k > /dev/null" EXIT
