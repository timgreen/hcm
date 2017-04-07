#!/bin/bash

usage() {
  cat << EOF
usage: hcm <command> [<args>]

Available commands:

   install    Install config module(s) in HOME directory
   help       Show this doc

See 'hcm help <command>' to read about a specific subcommand.
EOF
}

usage
