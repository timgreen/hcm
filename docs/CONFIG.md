# Main Config

The main config of hcm is `$HOME/.hcm/hcm.yml`.

Which could be a symlink, its actual path (`readlink`, only resolve one level) will be use as the base for the relative
paths mentioned in config.

> #### WHY use actual path as relative base?
>
> So we could keep and manage all the home config in one place (e.g. a git repo) and don't have to use absolute path in
> the config. When setup a brand new machine, we just need simply clone the configs and link the main config, then run
> the `hcm sync -f` and go for a coffee break.

## Main Config Format

```yaml
# Optional, specify the shell used to run the scripts, e.g. zsh or bash, defaults to bash.
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

The module config is the `module.yml` file under the root of each module directory. Everything is *optional* in the
module config. You just need a empty file if you only want to link dotfiles. (Empty file is requires in this case for
`hcm` to know it is a module directory.)

   * `after`

      A list of module need be installed before this one, absolute path or relative paths from current file, must
      already be mentioned in the main config.

   * `requires`

      A list of cmd required to install this module. Depends on the *shell* defined in the main config, `hcm` will

         * Use `type -t` for bash
         * Use `whence -w` for zsh
         * Use `which` for others

      to check existence of the cmd.

      NOTE, only bash and zsh will reflect up-to-date *.bashrc* or *.zshrc* settings.

For hooks, please check [Life Cycle][Life Cycle] for details.

```yaml
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
# Hook script to run after install.
post_install: |
  echo 'post install'
pre_uninstall: |
  echo 'pre uninstall'
# Hook script to run after uninstall.
post_uninstall: |
  echo 'post uninstall'

```

[Shell Skeleton]: TODO(timgreen)
[Life Cycle]: TODO(timgreen)
