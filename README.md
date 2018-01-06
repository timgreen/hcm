# hcm (Home Config Manager)

[![Build Status](https://travis-ci.org/timgreen/hcm.svg?branch=master)](https://travis-ci.org/timgreen/hcm)

## What's hcm

hcm is a set of bash scripts that manages your home configs. I create it solve two main problems:

   * Easy the setup process on a brand new machine.
   * Keep syncing the configs between multiple machines.

## Requirements

Commands/tools should already available in most of systems.

   * coreutils, for tools like
      * [readlink](https://linux.die.net/man/1/readlink)
      * [tsort](https://en.wikipedia.org/wiki/Tsort)
      * nl
   * bash
   * find
   * curl
   * grep
   * jq
   * tput

Tools might need installation.

   * [yq](https://yq.readthedocs.io/)

      when `docker` is available, `hcm` will fallback to use image [evns/yq](https://hub.docker.com/r/evns/yq/) if `yq` cannot be found.
   * md5sum
   * rsync, optional, `hcm` will fallback to use `rm` & `cp` if `rsync` cannot be found.

## Install

### Install Script
Easiest way is to use the [installer][installer_bin] (recommended).

    $ curl -sLo- https://raw.githubusercontent.com/timgreen/hcm/master/install.sh | bash

If you want to see what’s inside it, [access it directly][installer_bin] or
[check it out on the repository][installer_source].

### Source Code
Or manually clone this repo and run hcm in the root directory.

    $ git clone https://github.com/timgreen/hcm.git
    $ cd hcm
    $ ./install.sh

## Quick Start

Copy the example `hcm.yml` to `$HOME/.hcm/hcm.yml` and run `hcm sync -f`.

for more information

   * check `hcm help`
   * [Config Format](docs/CONFIG.md)
   * [Advanced Topics](docs/ADVANCED.md)
   * [FAQ](docs/FAQ.md)


[installer_bin]: https://raw.githubusercontent.com/timgreen/hcm/master/install.sh
[installer_source]: https://github.com/timgreen/hcm/blob/master/install.sh
