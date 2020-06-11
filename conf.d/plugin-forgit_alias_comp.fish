#!/usr/bin/env fish

if test -n "$__FISH_FORGIT_ALIAS_NAME"

    function __fish_forgit_no_subcommand
        test (count (commandline -opc)) -le 2
    end

    # add git prefix for the completion command, for `git forgit` alias
    # remove the needs command, as we are already using subcommand for git alias
    for completions_cmd in (forgit --complete \
    # | sed 's/-n "/-n "__fish_git_using_command forgit; /' \
    # | sed 's/-n "/-n "__fish_git_using_command forgit; /' \
    | string replace -- '-n "' '-n "__fish_git_using_command forgit; ' \
    | string replace -- '__fish_forgit_needs_command "' '__fish_forgit_no_subcommand' \
    )
    
        # echo "complete -c git $completions_cmd"
        eval "complete -c git $completions_cmd"
    end

end 
