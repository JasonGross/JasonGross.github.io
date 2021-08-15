#!/usr/bin/env bash

git submodule foreach --recursive bash -c 'if [[ "$(pwd)" != */*"coq" ]] && [[ "$(pwd)" != *"/lob-paper" ]]; then echo "$(pwd)" && git pull origin master; fi'
