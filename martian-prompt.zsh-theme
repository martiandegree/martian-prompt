#!/bin/sh

## autoload vcs and colors
autoload -Uz vcs_info
autoload -U colors && colors

# enable only git 
zstyle ':vcs_info:*' enable git 

# setup a hook that runs before every prompt. 
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# add a function to check for untracked files in the directory.
# from https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
# 
+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[staged]+='!' # signify new files with a bang
    fi
}

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*:clean:*' check-for-untracked true
zstyle ':vcs_info:*:clean:*' check-head true
zstyle ':vcs_info:*:clean:*' headaheadstr ⇡
zstyle ':vcs_info:*:clean:*' headbehindstr ⇣
zstyle ':vcs_info:*' stagedstr +
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*:clean:*' untrackedstr '!'
zstyle ':vcs_info:git*+post-backend:*' hooks git-arrows
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
# zstyle ':vcs_info:git:*' formats " %r/%S %b %m%u%c "
# zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}(%{$fg[red]%}%m%u%c%{$fg[yellow]%}%{$fg[magenta]%} %b%{$fg[blue]%})"
zstyle ':vcs_info:git:*' formats $'%{\C-[[32m%}-[%{\C-[[34m%}%m%u%c%{\C-[[33m%}%{\C-[[32m%}%b%{\C-[[32m%}]'
zstyle ':vcs_info:git:*' actionformats $'%{\C-[[32m%}-[%{\C-[[34m%}%m%u%c%{\C-[[33m%}%{\C-[[32m%}%b%{\C-[[32m%}]-%{\C-[[32m%}[%{\C-[[36m%}%a%{\C-[[32m%}]'

# format our main prompt for hostname current folder, and permissions.
# PROMPT="%B%{$fg[blue]%}[%{$fg[white]%}%n%{$fg[red]%}@%{$fg[white]%}%m%{$fg[blue]%}] %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%}%c%{$reset_color%}"
# PROMPT="%{$fg[green]%}%n@%m %~ %{$reset_color%}%#> "
# PROMPT+="\$vcs_info_msg_0_ "
PROMPT='%F{%(#.blue.green)}╭─%{$fg[cyan]%}$CONDA_DEFAULT_ENV%{$fg[green]%}─%{$fg[cyan]%}`basename $(dirname $VIRTUAL_ENV 2>/dev/null) 2>/dev/null`%{$fg[green]%}─%{$fg[cyan]%}`basename "$VIRTUAL_ENV"`%{$fg[green]%}─(%B%F{%(#.red.blue)}%n%(#.💀.🔓)%m%b%F{%(#.blue.green)})-[%B%F{%(#.blue.white)}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]$vcs_info_msg_0_
%F{%(#.blue.green)}╰─%B%(#.%F{red}#.%F{blue}|>)%b%F{reset}'


# disables venv prompt mention
export VIRTUAL_ENV_DISABLE_PROMPT=1
