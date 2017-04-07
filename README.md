# Home Config Manager (hcm)

## What's hcm

hcm is a set of bash scripts that manages your home configs. Two main goals:

   * Easy the setup process on a brand new machine.
   * Keep syncing the configs between multiple machines.

## Install

### Install Script
Easiest way is to use the [installer](TODO(timgreen): insert source link) (recommended).

    $ curl -sLo- installer_bin_url | bash

If you want to see what’s inside it, [access it directly](TODO(timgreen): link) or [check it out on the repository](TODO(timgreen): link).

### Source Code
Or manually clone this repo and run hcm in the root directory.

    $ git clone https://github.com/timgreen/hcm.git
    $ cd hcm
    $ ./hcm install <dir>

## How to use

Simply run `hcm install` in your [managed configs directory](ADVANCED.md#managed-configs-directory-mcd).

for more information

   * check `hcm help`
   * [Advanced Topics](ADVANCED.md)
   * [FAQ](FAQ.md)
