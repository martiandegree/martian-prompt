#!/bin/zsh

## autoload vcs and colors
autoload -Uz vcs_info
autoload -U colors && colors

# enable only git 
zstyle ':vcs_info:*' enable git 

# setup a hook that runs before every prompt. 
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr '*'

# add a function to check for untracked files in the directory.
# from https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
### Display the existence of files not yet known to VCS

### git: Show marker (!) if there are untracked files in repository
# untracked files can only exist in the unstaged area
# Make sure you have added unstaged to your 'formats':  %u

+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep -q '^?? ' 2> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[unstaged]+='!'
    fi
}

### Compare local changes to remote changes
### git: Show +N/-N when your local branch is ahead-of or behind remote HEAD.
# Make sure you have added misc to your 'formats':  %m

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
    (( $behind )) && gitstatus+=( "%{$fg[yellow]%}⇣${behind}" )

    (( ${#gitstatus[@]} )) && hook_com[misc]+="%{$fg[green]%}[${(j: :)gitstatus}%{$fg[green]%}]"
}

# zstyle ':vcs_info:git*+set-message:*' hooks git-st
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-st
zstyle ':vcs_info:git:*' formats "%{$fg[green]%}-%{$fg[green]%}[%{$fg[red]%}%c%u%{$fg[yellow]%}%{$fg[blue]%}%b%{$fg[green]%}]%m"
zstyle ':vcs_info:git:*' actionformats "%{$fg[green]%}-%{$fg[green]%}[%{$fg[red]%}%c%u%{$fg[yellow]%}%{$fg[blue]%}%b%{$fg[green]%}]%{$fg[green]%}[%{$fg[magenta]%}%a%{$fg[green]%}]%m"

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
PROMPT='%F{%(#.blue.green)}╭─%{$fg[cyan]%}$CONDA_DEFAULT_ENV%{$fg[green]%}─%{$fg[cyan]%}`basename $(dirname $VIRTUAL_ENV 2>/dev/null) 2>/dev/null`%{$fg[green]%}─%{$fg[cyan]%}`basename "$VIRTUAL_ENV"`%{$fg[green]%}─(%B%F{%(#.red.blue)}%n%(#.💀.🔓)%m%b%F{%(#.blue.green)})-[%B%F{%(#.blue.white)}%(6~.%-1~/…/%4~.`replace_home_icon`)%b%F{%(#.blue.green)}]$vcs_info_msg_0_
%F{%(#.blue.green)}╰─%B%(#.%F{red}#.%F{blue}|>)%b%F{reset}'

# disables venv prompt mention
export VIRTUAL_ENV_DISABLE_PROMPT=1
