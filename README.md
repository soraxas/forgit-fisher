<h1 align="center">forgit - fisher plugin</h1>
<p align="center">
    <em>Fisher plugin utility tool for using git interactively. Powered by <a href="https://github.com/wfxr/forgit">wfxr/forgit</a>.</em>
</p>

This tool is designed to [forgit](https://github.com/wfxr/forgit). 

For details, please checkout the upstream repository. This plugin had packaged the powerful **forgit** tool into a [fisher plugin](https://github.com/jorgebucaran/fisher
)

### Installation

*Make sure you have [`fzf`](https://github.com/junegunn/fzf) installed, as a dependency of `forgit`*

``` sh
fisher add soraxas/forgit-fisher
```

### Details

This plugin utilise the autoload function of `fish`, to speed up your shell's startup time, i.e. there is no need to perform
```sh
source (curl -s https://raw.githubusercontent.com/wfxr/forgit/master/forgit.plugin.fish | psub)
```
which is recommended by the upstream repo.

By default this plugin disable the keybindings, and instead provide a function interface for `forgit`:
```sh
$ forgit --help
Usage: forgit <COMMAND> [COMMAND ARGS]

COMMAND: add
         clean
         diff
         ignore
         ignore clean
         ignore get
         ignore list
         ignore update
         info
         inside_work_tree
         log
         reset head
         restore
         stash show
         warn

         --setup-alias <ALIAS>	Setup <ALIAS> as git's alias. 
         --cleanup-alias	Cleanup alias created by forgit in .gitconfig
         --complete		Provide completions for fish
         --setup-git-workaround	Setup git-subcommand completion workaround
```


### Advantage compared to the upstream repo

- **Speed**: function is only loaded on-demand
- **Completions**: provide fish completions
- **Function interface**: I was having a hard to to memorise all the short alias form `forgit`. This allows to access all its functionality in a unified interface.


### Tips

With this plugin, you can use the `--setup-git-workaround` flag to setup `forgit` as a git subcommand. It has the advantage to inherent git's environmental variables, e.g., it can with `yadm forgit <...>`.

Note that I alias my `git` into `g`, and with a git-alias in my `~/.gitconfig` of `forgit=fg`. With the `forgit` subcommand, you can run commands with
```sh
$ g fg add
$ g fg log
```

Note that this plugin also allows you to abbreviate your command if they can uniquely expand to one of the valid commands. I.e., instead of the above example, you can type
```sh
$ g fg a     # --> expand to git forgit add
$ g fg l     # --> expand to git forgit log
```
and it will still works. However, 
```sh
$ g fg i     # --> expand to git forgit (ignore|info|...)
$ g fg r     # --> expand to git forgit (reset|restore)
```
will not work because they are ambiguous. If you want `forgit info`, you will need to at least type
```sh
$ g fg inf   # --> expand to git forgit info

```