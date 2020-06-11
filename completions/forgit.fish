
# no filename completion
complete -c forgit -x

for completions_cmd in (forgit --complete)
    eval "complete -c forgit $completions_cmd"
end