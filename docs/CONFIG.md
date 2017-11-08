# Main Config

The main config of hcm is `$HOME/.hcm/config.yml`.

Which could be a symlink, its actual path (`readlink -f`) will be use as the base for the relative paths mentioned in config.

> #### WHY use actual path as base?
>
> So we could keep and manage all the home config in one place (e.g. a git repo) and don't have to use absolute path in
> the config. When setup a brand new machine, we just need simply clone the configs and link the main config, then run
> the `hcm install` and go for a coffee break.

## Main Config Format

```
# Optional, specify the shell used to run the scripts, bash | zsh, defaults to bash.
shell: zsh
# List of module path.
# There should be a file name "module.yml" in the root of the module directory.
modules:
  - /abs_path/module_a
  - ./relative_path/module_b
  - relative_path/dir/module_c
```

> #### WHY need to specify the shell?
>
> Module might need external tools (declared as `requires`, e.g. git or java) during installation. Different shell could
> have different $PATH settings. User should set the shell to their daily shell and write the script in that shell's
> schema.
>
> When module provides tools (declared as `provides`), will need to update shell's $PATH or make sure the new tool is
> installed in one of the $PATH. see [Shell Skeleton][Shell Skeleton] for more details.

## Module Config Format

Everything is *optional* in the module config. You just need a empty file if you only want to link dotfiles.

For hooks, please check [Life Cycle][Life Cycle] for details.

```
# List of external tools required.
# hcm will proceed to install this module iff all the requires command if avaiable in $PATH, check with `which`.
requires:
  - git
# List of module path.
# hcm will make sure all the listed modules is installed before install this module.
# the relative path is resolved based on this file.
after:
  - ../zsh_skeleton

# Hooks

# Hook script to run before install.
pre_install: |
  echo 'pre install'
# Override the install behaviour.
install: |
  echo 'No-op, dont link dotfiles'
# Hook script to run after install.
post_install: |
  echo 'post install'
# Hook script to run before update.
pre_update: |
  echo 'pre update'
# Override the update behaviour.
update: |
  echo 'No-op, dont update dotfiles'
# Hook script to run after update.
post_update: |
  echo 'post update'
pre_uninstall: |
  echo 'pre uninstall'
# Override the uninstall behaviour.
uninstall: |
  echo 'No-op, dont unlink dotfiles'
# Hook script to run after uninstall.
post_uninstall: |
  echo 'post uninstall'

```

[Shell Skeleton]: TODO(timgreen)
[Life Cycle]: TODO(timgreen)