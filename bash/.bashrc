#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vi=nvim
alias vim=nvim
alias cd=z
export MANPAGER='nvim +Man!'
export EDITOR="nvim -u NONE -n" visudo
export VISUAL="nvim -u NONE -n" visudo
PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"
eval "$(zoxide init --cmd cd bash)"
eval "$(fzf --bash)"
. "$HOME/.cargo/env"
# Start the SSH agent for this session
eval "$(ssh-agent -s)" > /dev/null
# Add your specific key (silencing errors if it's already there or missing)
ssh-add ~/.ssh/github_test 2>/dev/null
# Automatically kill the agent when the terminal session ends
trap "ssh-agent -k > /dev/null" EXIT