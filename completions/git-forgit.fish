# completion file for git-subcommand workaround

function __fish_forgit_has_no_subcommand
    test (count (commandline -opc)) -le 2
end

# add completion commands for git alias
eval (printf 'complete -c git %s;\n ' (forgit --complete \
    | string replace -- '-n "' '-n "__fish_git_using_command forgit; ' \
    | string replace -- '__fish_forgit_needs_command "' '__fish_forgit_has_no_subcommand' \
))
