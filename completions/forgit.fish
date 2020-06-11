#!/usr/bin/env fish

# no filename completion
complete -c forgit -x

for completions_cmd in (forgit --complete)
    # perform completions with forgit builtin command
    eval "complete -c forgit $completions_cmd"
end
