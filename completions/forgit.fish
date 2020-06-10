function __fish_forgit_needs_command
    # Figure out if the current invocation already has a command.    
    set -l cmd (commandline -opc)
    set -e cmd[1]
    or return 0
    if set -q cmd[1]
        echo $cmd[1]
        return 1
    end
    return 0
end

function __fish_forgit_using_command
    set -l cmd (__fish_forgit_needs_command)
    test -z "$cmd"
    and return 1
    # must be of length 1 (+function name)
    test (count (commandline -opc)) -eq 2
    or return 1
    contains -- $cmd $argv
    and return 0
end


set -l __forgit_commands_first_tokens_only (string replace -r " .*\$" "" $__forgit_commands)

# no filename completion
complete -c forgit -x

for cmd in $__forgit_commands
    set -l try_split (string split ' ' $cmd)
    if test (count $try_split) -gt 1
        # is a subcommand
        complete -c forgit -n "__fish_forgit_using_command $try_split[1]" -xa "$try_split[2]"
        set -l num_subcmds (echo $__forgit_commands_first_tokens_only | grep -o -i $try_split[1] | wc -l)
        complete -c forgit -n '__fish_forgit_needs_command' -xa $try_split[1] -d "Subcommands: $num_subcmds"
    else
        complete -c forgit -n '__fish_forgit_needs_command' -xa "$try_split[1]"
    end
end
