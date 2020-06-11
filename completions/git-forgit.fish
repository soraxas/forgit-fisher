#!/usr/bin/env fish

if test -n "$__FISH_FORGIT_ALIAS_NAME"
    # no filename completion
    complete -c git -xa "$__FISH_FORGIT_ALIAS_NAME" -d "Using fzf to empower your git workflow"

    # add git prefix for the completion command, for `git forgit` alias
    for completions_cmd in (forgit --complete | sed 's/-n "/-n "__fish_git_using_command '$__FISH_FORGIT_ALIAS_NAME'; /')
        notify-send "complete -c git $completions_cmd"
    end

end 
