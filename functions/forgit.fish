set -x FORGIT_NO_ALIASES 1
# source but replace its functions within namespace
grep -P -v '^complet.*__fish_git_using_command.*(add|commit).*__fish_git_files' ~/git-repo/forgit/forgit.plugin.fish | sed 's/forgit::/__forgit::/' | source

# get all defined functions by forgit
set __forgit_commands (functions --all | string match -r "^__forgit::.*")

# remove forgit prefix for the list of subcommands
set __forgit_commands (string replace '__forgit::' '' $__forgit_commands)
# replace :: with space
set __forgit_commands (string replace --all '::' ' ' $__forgit_commands)

function forgit
    # try to merge arg 1 + 2 as it could be a sub command
    set -l try_merge (string join -- " " $argv[1..2])
    contains -- $try_merge $__forgit_commands
    and set -e argv[1]; and set argv[1] $try_merge

    if not contains -- $argv[1] $__forgit_commands
        printf "Usage: forgit <COMMAND> [ARGS]\n"
        printf "COMMAND: %s\n" $__forgit_commands[1]
        printf "         %s\n" $__forgit_commands[2..-1]
        return 1
    end

    set -l subfunc (string replace -- ' ' '::' $argv[1])
    # remove subfunc
    set -e argv[1]

    # $subfunc $argv
    __forgit::$subfunc $argv
end



