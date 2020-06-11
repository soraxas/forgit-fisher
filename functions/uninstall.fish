test -n "$__FISH_FORGIT_GIT_COMPLETION_WORKAROUND_PATH"
and command rm "$__FISH_FORGIT_GIT_COMPLETION_WORKAROUND_PATH"
and set -e __FISH_FORGIT_GIT_COMPLETION_WORKAROUND_PATH


# the follow is just a copy of the defined forgit --cleanup-alias function
# fisher unisntall had already removed the `forgit` references, so we can no
# longer reference the function
if test -n "$__FISH_FORGIT_ALIAS_NAME"
    set -l __forgit_alias_main_sed_pattern "^\s*forgit\s*="
    set -l __forgit_alias_alias_sed_pattern "[^=]*=\s*forgit\s*\$"

    for sed_cmd in "$__forgit_alias_main_sed_pattern" "$__forgit_alias_alias_sed_pattern"

        set -l sed_cmd "/"$sed_cmd"/d"

        printf "Going to execute:\n"
        printf "sed -i"
        printf " \"%s\"" $sed_cmd "$HOME/.gitconfig"
        printf "\n"

        sed -i "$sed_cmd" "$HOME/.gitconfig"
    end

    set -e __FISH_FORGIT_ALIAS_NAME
end