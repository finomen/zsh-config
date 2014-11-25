#!/usr/bin/zsh 

ROOT_DIR="${ZDOTDIR-~}/.zshrc.d"

autoload -U colors zsh/terminfo # Used in the colour alias below
colors
setopt prompt_subst

for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$fg[${(L)color}]%}'
done
eval PR_NO_COLOR="%{$terminfo[sgr0]%}"
eval PR_BOLD="%{$terminfo[bold]%}"


git_init() {
	eval GIT_BRANCH=""
	
	eval GIT_DIRTY=""

	# check we are in git repo
	local CUR_DIR=$PWD
	while [ ! -d ${CUR_DIR}/.git ] && [ ! $CUR_DIR = "/" ]; do CUR_DIR=${CUR_DIR%/*}; done
	[[ ! -d ${CUR_DIR}/.git ]] && return

	# 'git repo for dotfiles' fix: show git status only in home dir and other git repos
	[[ $CUR_DIR == $HOME ]] && [[ $PWD != $HOME ]] && return

	# get git branch
	eval GIT_BRANCH=$(git symbolic-ref HEAD 2>/dev/null)
	[[ -z $GIT_BRANCH ]] && return
	eval GIT_BRANCH=${GIT_BRANCH#refs/heads/}

	# get git status
	eval GIT_STATUS=$"(git status --porcelain 2>/dev/null)"
	[[ -n $GIT_STATUS ]] && eval GIT_DIRTY=true	
}

precmd() {
	eval GIT_PROMPT=""

	git_init

	if [[ -n $GIT_DIRTY ]]
	then
		eval FLG_COLOR="${PR_RED}"
	else
		eval FLG_COLOR="${PR_GREEN}"
	fi

	[[ -n "$GIT_BRANCH" ]] && GIT_PROMPT="${FLG_COLOR}⚑${PR_WHITE}${GIT_BRANCH}${PR_NO_COLOR}"

	PROMPT=$'%B%{${PR_GREEN}%}%n%{${PR_BLUE}%}@%{${PR_GREEN}%}%m%{\e[0;36m%} %{${PR_WHITE}%}%~%{${PR_MAGENTA}%} ▶%{${PR_NO_COLOR}%} %b'

	RPROMPT=$'%F${GIT_PROMPT} %{${PR_CYAN}%}%*%f'
}


#source ${ROOT_DIR}/left