set -x FORGIT_NO_ALIASES 1
# source but replace its functions within __ namespace
grep -P -v '^complet.*__fish_git_using_command.*(add|commit).*__fish_git_files' ~/git-repo/forgit/forgit.plugin.fish | sed 's/forgit::/__forgit::/' | source

# get all defined functions by forgit
set __forgit_commands (functions --all | string match -r "^__forgit::.*")

# remove forgit prefix for the list of subcommands
set __forgit_commands (string replace '__forgit::' '' $__forgit_commands)

# replace :: with space
set __forgit_commands (string replace --all '::' ' ' $__forgit_commands)


set __forgit_commands_options "setup-alias:Setup <ALIAS> as git's alias" \
                              "cleanup-alias:Cleanup alias created by forgit in .gitconfig" \
                              "complete:Provide completions for fish (no need to manual run)" \
                              "setup-git-workaround:Setup git-subcommand completion workaround"

function __fish_forgit_last_cmd_match
    set -l cmd (commandline -opc)
    if set -q $cmd[1]
        return 1
    end
    contains -- $cmd[-1] $argv
    and return 0
end

function __fish_forgit_needs_command
    # Figure out if the current invocation already has a command.    
    set -l cmd (commandline -opc)

    set -e cmd[1]
    or return 0

    test "$cmd[1]" = "$__FISH_FORGIT_ALIAS_NAME"
    and set -e cmd[1]
    
    test "$cmd[1]" = "forgit"
    and set -e cmd[1]

    if set -q cmd[1]
        echo $cmd[1]
        return 1
    end
    return 0
end

function forgit
    set -l __forgit_alias_main_pattern "!f() { fish -c 'forgit '\$@; }; f"
    
    ##### alias subcommand
    if test (count $argv) -ge 2
        if contains -- --setup-alias $argv
            # echo "Going to execute:"
            # echo -- git config --global alias.$argv[2] \"$__forgit_alias_pattern\"
            # alias for forgit
            if git config --list | grep -q alias.forgit
                echo "SKIPPING:"
                printf '\t%s\n' "Already has an alais named forgit." "Run --cleanup-alias to force cleanup."
            else
                git config --global alias.forgit "$__forgit_alias_main_pattern"
            end

            if test $argv[2] != "forgit"
                if git config --list | grep -q alias.$argv[2]
                    echo "SKIPPING:"
                    printf '\t%s\n' "Already has an alais named $argv[2]." "Run --cleanup-alias to force cleanup."
                else
                    git config --global alias.$argv[2] "forgit"
                end
            end
            set -xU __FISH_FORGIT_ALIAS_NAME "$argv[2]"
            return
        end

    ##### cleanup alias subcommand
    else if contains -- --cleanup-alias $argv
        # cleanup alias
        # git config --global alias.$argv[2] "!f() { fish -c \"forgit \"\$@; }; f"
        # echo $__forgit_alias_pattern
        # we need to replace the escaped double quote by escaping the backslash
        # in raw string that would be 3 \ , but here we need to escape the escape so we
        # will need 3 \ to represent a \ in terminal.

        # set -l __forgit_alias_main_sed_pattern "forgit\s*=\s*$__forgit_alias_main_pattern"
        set -l __forgit_alias_main_sed_pattern "^\s*forgit\s*="
        set -l __forgit_alias_alias_sed_pattern "[^=]*=\s*forgit\s*\$"

        # set -l escaped_alias_pattern (echo $__forgit_alias_pattern | sed 's/"/\\\"/g')
        # set -l escaped_alias_pattern (echo $escaped_alias_pattern | sed 's/"/\\\"/g')
        # set -l escaped_alias_pattern (echo $escaped_alias_pattern | sed 's/"/\\\"/g')
        # set -l escaped_alias_pattern (echo $escaped_alias_pattern | sed 's/"/\\\"/g')
        # set -l escaped_alias_pattern (echo $escaped_alias_pattern | sed 's/"/\\\"/g')
        # return
        
        for sed_cmd in "$__forgit_alias_main_sed_pattern" "$__forgit_alias_alias_sed_pattern"

            set -l sed_cmd "/"$sed_cmd"/d"


            printf "Going to execute:\n"
            printf "sed -i"
            printf " \"%s\"" $sed_cmd "$HOME/.gitconfig"
            printf "\n"
            
            sed -i "$sed_cmd" "$HOME/.gitconfig"
        end
        
        set -e __FISH_FORGIT_ALIAS_NAME
        return
    
    ##### completions subcommand
    else if contains -- --complete $argv
        # store all the first level commands

        # all commands
        echo -- "-n \"__fish_forgit_needs_command\" -xa \"$__forgit_commands\""

        # commands with subcommand
        set -l cmds_with_subcmd (string replace -f -r " .*\$" "" $__forgit_commands | sort | uniq --count \
                                | string replace -r '^\s+([0-9]+)\s+(.*)\s*' '$2\tSubcommands: $1' | string escape)
        echo -- "-n \"__fish_forgit_needs_command\" -xa \"$cmds_with_subcmd\""

        # add subcommand completions
        for subcommand in (string match "* *" $__forgit_commands)
            set -l split_cmd (string split ' ' $subcommand)
            echo -- "-n \"__fish_forgit_last_cmd_match $split_cmd[1]\" -xa \"$split_cmd[2]\""
        end

        # completions for options
        for cmd in $__forgit_commands_options
            printf -- "-n \"\" -l %s -d \"%s\"\n" (string split ':' $cmd)
        end 
        return
    
    ##### setup git-subcomand workaround
    else if contains -- --setup-git-workaround $argv

        # remove previous workaround file
        if test -e "$__FISH_FORGIT_GIT_COMPLETION_WORKAROUND_PATH"
            echo "Removing $__FISH_FORGIT_GIT_COMPLETION_WORKAROUND_PATH"
            command rm "$__FISH_FORGIT_GIT_COMPLETION_WORKAROUND_PATH"
            test $status -eq 0
            or echo "ERROR occured when removing workaround file"
        end

        # add a placeholder executable file in the first PATH folder
        set -l folder $PATH[1]
        set -l executable_path $folder/git-forgit

        touch $executable_path
        and echo -e '#!/usr/bin/env fish\nforgit $argv' > $executable_path
        and chmod +x $executable_path
        and set -xU __FISH_FORGIT_GIT_COMPLETION_WORKAROUND_PATH $executable_path

        return
    end

    # try to merge arg 1 + 2 as it could be a sub command
    set -l try_merge (string join -- " " $argv[1..2])
    contains -- $try_merge $__forgit_commands
    and set -e argv[1]; and set argv[1] $try_merge

    and contains -- $argv[1] $__forgit_commands
    set -l is_valid_cmd $status

    if test $is_valid_cmd -ne 0
        # if the provided command can uniquely expand to one of the available commands,
        # we will still allow the commands to work.
        # e.g., `forgit a` will be able to expand to `forgit add`
        if test -n "$argv[1]"
            # must be non-empty
            and set -l possible_cmd (string match "$argv[1]*" $__forgit_commands)
            if test (count $possible_cmd) -eq 1
                # found a non-ambigious command
                set argv[1] $possible_cmd[1]
                set is_valid_cmd 0
            else if test (count $possible_cmd) -gt 1
                echo "> Unable to expand '$argv[1]' to a valid command unambigiously"
                echo "> Matches:"
                printf "\t%s\n " $possible_cmd
                return 1
            end
        end
    end
    
    if test $is_valid_cmd -ne 0
        printf "Usage: forgit <COMMAND> [COMMAND ARGS]\n\n"
        printf "COMMAND: %s\n" $__forgit_commands[1]
        printf "         %s\n" $__forgit_commands[2..-1]
        printf "\n"
        printf "         --setup-alias <ALIAS>\t%s\n" "Setup <ALIAS> as git's alias. "
        printf "         --cleanup-alias\t%s\n" "Cleanup alias created by forgit in .gitconfig"
        printf "         --complete\t\t%s\n" "Provide completions for fish"
        printf "         --setup-git-workaround\t%s\n" "Setup git-subcommand completion workaround"
        return 1
    end

    set -l subfunc (string replace -- ' ' '::' $argv[1])
    # remove subfunc
    set -e argv[1]

    # $subfunc $argv
    __forgit::$subfunc $argv
end



