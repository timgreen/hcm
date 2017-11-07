# hcm (Home Config Manager)

[![Build Status](https://travis-ci.org/timgreen/hcm.svg?branch=master)](https://travis-ci.org/timgreen/hcm)

## What's hcm

hcm is a set of bash scripts that manages your home configs. I create it solve two main problems:

   * Easy the setup process on a brand new machine.
   * Keep syncing the configs between multiple machines.

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

Copy the example `config.yml` to `$HOME/.hcm/config.yml` and run `hcm install`.

for more information

   * check `hcm help`
   * [Config Format](docs/CONFIG.md)
   * [Advanced Topics](docs/ADVANCED.md)
   * [FAQ](docs/FAQ.md)


[installer_bin]: https://raw.githubusercontent.com/timgreen/hcm/master/install.sh
[installer_source]: https://github.com/timgreen/hcm/blob/master/install.sh
