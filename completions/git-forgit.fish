if test -n "$__FISH_FORGIT_ALIAS_NAME"

    # no filename completion
    complete -c git -xa "$__FISH_FORGIT_ALIAS_NAME" -d "Using fzf to empower your git workflow"

    # add git prefix for the completion command
    for completions_cmd in (forgit --complete | sed 's/-n "/-n "__fish_git_using_command '$__FISH_FORGIT_ALIAS_NAME'; /')
        notify-send "complete -c git $completions_cmd"
    end

end 
# set -l __forgit_commands_first_tokens_only (string replace -r " .*\$" "" $__forgit_commands)

# # no filename completion
# complete -c forgit -x
# complete -c forgit -l setup-alias -d "Setup forgit as git alias"
# complete -c forgit -l cleanup-alias -d "Clean forgit alias from git config"

# for cmd in $__forgit_commands
#     set -l try_split (string split ' ' $cmd)
#     if test (count $try_split) -gt 1
#         # is a subcommand
#         complete -c forgit -n "__fish_forgit_using_command $try_split[1]" -xa "$try_split[2]"
#         set -l num_subcmds (echo $__forgit_commands_first_tokens_only | grep -o -i $try_split[1] | wc -l)
#         complete -c forgit -n '__fish_forgit_needs_command' -xa $try_split[1] -d "Subcommands: $num_subcmds"
#     else
#         complete -c forgit -n '__fish_forgit_needs_command' -xa "$try_split[1]"
#     end
# end
