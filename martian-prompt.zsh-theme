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
zstyle ':vcs_info:*:git:*' get-revision true  # Enable fetching of revision info
# zstyle ':vcs_info:*:git:*' headahead 'yes'
# zstyle ':vcs_info:*:git:*' aheadstr '⇡'
# zstyle ':vcs_info:*:git:*' behindstr '⇡'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*:clean:*' untrackedstr '!'
zstyle ':vcs_info:git*+post-backend:*' hooks git-arrows
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

### Compare local changes to remote changes

### git: Show +N/-N when your local branch is ahead-of or behind remote HEAD.
# Make sure you have added misc to your 'formats':  %m
zstyle ':vcs_info:git*+set-message:*' hooks git-st
+vi-git-st() {
    local ahead behind
    local -a gitstatus

    # Exit early in case the worktree is on a detached HEAD
    git rev-parse ${hook_com[branch]}@{upstream} >/dev/null 2>&1 || return 0

    local -a ahead_and_behind=(
        $(git rev-list --left-right --count HEAD...${hook_com[branch]}@{upstream} 2>/dev/null)
    )

    ahead=${ahead_and_behind[1]}
    behind=${ahead_and_behind[2]}

    (( $ahead )) && gitstatus+=( "%{$fg[cyan]%}⇡${ahead}" )
    (( $behind )) && gitstatus+=( "%{$fg[magenta]%}⇣${behind}" )

    hook_com[misc]+="%{$fg[green]%}[${(j: :)gitstatus}%{$fg[green]%}]"
}

# zstyle ':vcs_info:git:*' formats " %r/%S %b %m%u%c "
# zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}(%{$fg[red]%}%m%u%c%{$fg[yellow]%}%{$fg[magenta]%} %b %{$fg[magenta]%} %M %{$fg[blue]%})"
# zstyle ':vcs_info:git:*' formats $'%{\C-[[32m%}-[%{\C-[[34m%}%m%u%c%{\C-[[33m%}%{\C-[[32m%}%b%{\C-[[32m%}]-[%{\C-[[34m%}%a %r]'
# zstyle ':vcs_info:git:*' actionformats $'%{\C-[[32m%}-[%{\C-[[34m%}%m%u%c%{\C-[[33m%}%{\C-[[32m%}%b%{\C-[[32m%}]-%{\C-[[32m%}[%{\C-[[36m%}%a%{\C-[[32m%}]'
zstyle ':vcs_info:git:*' formats "%{$fg[green]%}-%{$fg[green]%}[%{$fg[red]%}%u%c%{$fg[yellow]%}%{$fg[blue]%}%b%{$fg[green]%}]%m"

# Function to replace ~ with 🏠 in directory path
replace_home_icon() {
  local dir="$PWD"
  if [[ "$dir" == "$HOME/dev"* ]]; then
    echo "🛠️${dir#$HOME/dev}"
  elif [[ "$dir" == "$HOME"* ]]; then
    echo "🏠${dir#$HOME}"
  else
    echo "$dir"
  fi
}

# format our main prompt for hostname current folder, and permissions.
# PROMPT="%B%{$fg[blue]%}[%{$fg[white]%}%n%{$fg[red]%}@%{$fg[white]%}%m%{$fg[blue]%}] %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%}%c%{$reset_color%}"
# PROMPT="%{$fg[green]%}%n@%m %~ %{$reset_color%}%#> "
# PROMPT+="\$vcs_info_msg_0_ "
PROMPT='%F{%(#.blue.green)}╭─%{$fg[cyan]%}$CONDA_DEFAULT_ENV%{$fg[green]%}─%{$fg[cyan]%}`basename $(dirname $VIRTUAL_ENV 2>/dev/null) 2>/dev/null`%{$fg[green]%}─%{$fg[cyan]%}`basename "$VIRTUAL_ENV"`%{$fg[green]%}─(%B%F{%(#.red.blue)}%n%(#.💀.🔓)%m%b%F{%(#.blue.green)})-[%B%F{%(#.blue.white)}%(6~.%-1~/…/%4~.`replace_home_icon`)%b%F{%(#.blue.green)}]$vcs_info_msg_0_
%F{%(#.blue.green)}╰─%B%(#.%F{red}#.%F{blue}|>)%b%F{reset}'


# disables venv prompt mention
export VIRTUAL_ENV_DISABLE_PROMPT=1
