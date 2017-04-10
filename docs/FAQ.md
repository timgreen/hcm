# Home Config Manager (hcm) FAQ

## What's the Recommended Practise When Using `hcm`?

I recommend to use one [MCD] to manage all the configs for a machine.

WHY?

   * `hcm` support softlinked directories and group directories, so we could *import* config module from
     other place and organize them nicely.
   * Easy to re-install change after sync (e.g. git pull)

### Sample Directory Structure

    <Managed Configs Directory>/
    |- HCM_MCD_ROOT
    |- vim/
    |   |- HCM_MODULE
    |   `- .vimrc
    |- shells/
    |   |- zsh/
    |   |   |- HCM_MODULE
    |   |   `- .zshrc
    |   `- bash/
    |       |- HCN_MODULE
    |       `- .bashrc
    `...

## What if I Need Different [CM] Sets for Different Machines?

One way to archive it by using softlink.

   * Put all CMs under a directory.
   * Create MCD for each machine.
   * Softlink needed CMs into each MCD.

Example:

    <root>
    | cm_pool/
    | |- vim/
    | |   |- HCM_MODULE
    | |   `- .vimrc
    | |- shells/
    | |   |- zsh/
    | |   |   |- HCM_MODULE
    | |   |   `- .zshrc
    | |   `- bash/
    | |       |- HCM_MODULE
    | |       `- .bashrc
    | `...
    |-for_machine_a/
    | |- HCM_MCD_ROOT
    | |- vim # softlink
    | |- shells # softlink
    | `...
    |
    |-for_machine_b/
    | |- HCM_MCD_ROOT
    | |- shells/
    | |   `- zsh #softlink
    | `...



[MCD]: ADVANCED.md#managed-configs-directory-mcd
[CM]: ADVANCED.md#config-module-cm

