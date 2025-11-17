#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim=nvim
export MANPAGER='nvim +Man!'
PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"
eval "$(zoxide init --cmd cd bash)"
eval "$(fzf --bash)"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_test > /dev/null 2>&1
