#!/usr/bin/env bash

git submodule foreach --recursive bash -c 'if [[ "$(pwd)" != *"/coq" ]]; then echo "$(pwd)" && git pull origin master; fi'
