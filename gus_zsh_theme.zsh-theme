function conda_info {
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        echo "%{$fg[green]%} ‹${CONDA_DEFAULT_ENV}›%{$reset_color%}"
    fi
}

PROMPT="${FG[237]}\${(l.\${COLUMNS}..·.)}%{$reset_color%}"
# content around '' is updated every time, but around "" is not
PROMPT+='
%{$fg_bold[cyan]%}·%{$reset_color%} %{$fg[magenta]%}%c%{$reset_color%}$(git_prompt_info)$(conda_info)
%(?:%{$fg_bold[green]%}↪ :%{$fg_bold[red]%}↪ )%{$reset_color%}'

# magenta
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

# Enable command search with Up and Down arrow key
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search   # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# Enable transient prompt
zle-line-init() {
    emulate -L zsh

    [[ $CONTEXT == start ]] || return 0

    while true; do
        zle .recursive-edit
        local -i ret=$?
        [[ $ret == 0 && $KEYS == $'\4' ]] || break
        [[ -o ignore_eof ]] || exit 0
    done

    local saved_prompt=$PROMPT
    local saved_rprompt=$RPROMPT
    PROMPT='%(?:%{$fg[green]%}⑆ :%{$fg_bold[red]%}⑆ )%{$reset_color%}'
    RPROMPT=''
    zle .reset-prompt
    PROMPT=$saved_prompt
    RPROMPT=$saved_rprompt

    if ((ret)); then
        zle .send-break
    else
        zle .accept-line
    fi
    return ret
}

zle -N zle-line-init
