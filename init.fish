# because there is no way to add autoload completion for git <CUSTOM> commands,
# we will need to load it on shell start.
# However, we only load it if git alias is defined, and there is only
# minimial string mainpulation involved to minimise computational cost

if test -n "$__FISH_FORGIT_ALIAS_NAME"

    function __fish_forgit_has_no_subcommand
        test (count (commandline -opc)) -le 2
    end

    # add completion commands for git alias
    eval (printf 'complete -c git %s;\n ' (forgit --complete \
        | string replace -- '-n "' '-n "__fish_git_using_command forgit; ' \
        | string replace -- '__fish_forgit_needs_command "' '__fish_forgit_has_no_subcommand' \
    ))

end