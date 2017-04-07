# Home Config Manager (hcm) Advanced Topics

## What Happens After I Run `hcm install`

For each of the Config Module ([CM][CM]) (e.g. vim)

   1. `hcm` creates a tracking directory in `~/.hcm/modules/`
      * e.g. ~/.hcm/modules/vim/
   2. softlinks all the files (expect HCM\_MODULE) into the tracking directory.
      * `hcm` only softlinks files. For directory, it copies the directory structure and softlinks
        files inside those directories.
   3. softlinks all the files from tracking directory to HOME directory.

WHY?

   * Why softlink instead of copy?
      * So we could keep sync the config between the source.
         * e.g. no matter user modifies ~/.vimrc or ~/synced_config/vim/.vimrc, the change is
           tracked in the managed directory and take effect immediately.
   * Why softlink files instead of directories?
      * During the runtime, some app puts files other than config in directory.
         * TODO: example
   * Why link the files twice?
      * So when scanning the files in HOME dir, we could tell whether a file is managed by `hcm` by
        checking its source path.

### Option `--fast`

TBD: use directory last modified timestamp to reduce the num of files need scan.

## What's a Managed Configs Directory (MCD) and Config Module (CM)

### Managed Configs Directory (MCD)

A MCD is a directory contains a [*HCM\_MCD\_ROOT*](#hcm_mcd_root) file and [CM][CM]s.

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
    |       |- HCM_MODULE
    |       `- .bashrc
    `...

A CM could either in the root of MCD or sub-directories.

NOTE: `hcm` will report error for

   * Every directories
   * Files out side CM

    <Managed Configs Directory>/
    |- HCM_MCD_ROOT
    |- .bashrc         # <-- error: unmanaged files
    |- vim/
    |   |- HCM_MODULE
    |   `- .vimrc
    |- shells/
    |   |- zsh/
    |   |   `- .zshrc  # <-- error: unmanaged files
    |   `- bash/       # <-- error: empty dir
    `...

### Config Module (CM)

A CM is a directory contains a [HCM_MODULE](#hcm_module) file and home for configs.

NOTE:

   * Each CM should have **unique name** no matter which directory it belongs to. `hcm` don't care
     about the parent group directory names. So dir\_a/name/ will conflict with dir\_b/dir\_c/name/.
   * The softlink inside CM is treated as normal files. So it means the changes in the source file
     or source dir won't be tracked by `hcm`.

A CM is a mirror and subset of HOME dir. WIP.

## What's HCM\_MCD\_ROOT and HCM\_MODULE Files

### HCM\_MCD\_ROOT

For each of the Managed Configs Directory, `hcm` except to find a HCM\_MCD\_ROOT file in the root.
Otherwise `hcm` will refuse to continue.

WHY?

   * First, this prevents user accidentally execute `hcm` in unexpected directory, especially for
     huge directory if might take a long time for `hcm` to finish navigating.
   * Second, in the future version of `hcm`, the content of HCM\_MCD\_ROOT might be used as config.

NOTE: currently `hcm` ignore the content inside HCM\_MCD\_ROOT.

### HCM\_MODULE

For each of the Config Module directory, `hcm` except to find a HCM\_MODULE file in the root.
Otherwise `hcm` will refuse to continue.

NOTE: currently `hcm` ignore the content inside HCM\_MODULE.

[CM]: ADVANCED.md#configs-module-cm
