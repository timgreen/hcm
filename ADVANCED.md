# Home Config Manager (hcm) Advanced Topics

## What Happens After I Run `hcm install`

For each of the Config Module ([CM][CM]) (e.g. vim)

   1. `hcm` creates a tracking directory in `~/.hcm/modules/`
      * e.g. ~/.hcm/modules/vim/
   2. softlinks all the files (expect MODULE) into the tracking directory.
      * `hcm` only softlinks files. For directory, it copies the directory structure and softlinks
        files inside those directories.
   3. softlinks all the files from tracking directory to HOME directory.

WHY?

   * Why softlink instead of copy?
      * TBD
   * Why softlink files instead of directories?
      * TBD
   * Why link the files twice?
      * So when scanning the files in HOME dir, we could tell whether a file is managed by hcm by
        checking its source path.

### Option `--fast`

TBD: use directory last modified timestamp to reduce the num of files need scan.

## What's a Managed Configs Directory (MCD) and Config Module (CM)

### Managed Configs Directory (MCD)

TBD

### Config Module (CM)

TBD

NOTE:

   * Each CM should have **unique name** no matter which directory it belongs to. `hcm` don't care
     about the parent group directory names.
   * The softlink inside CM is treated as normal files. So it means the changes in the source file
     or source dir won't be tracked by `hcm`.

## What's HCM\_MCD\_ROOT and MODULE Files

### HCM\_MCD\_ROOT

For each of the Managed Configs Directory, hcm except to find a HCM\_MCD\_ROOT file in the root.
Otherwise hcm will refuse to continue.

WHY?

   * First, this provents user accidently execute hcm in unexpected directory, especially for huge
     directory if might take a long time for hcm to finish navigating.
   * Second, in the future version of hcm, the content of HCM\_MCD\_ROOT might be used as config.

### MODULE

TBD

[CM]: ADVANCED.md#configs-module-cm
