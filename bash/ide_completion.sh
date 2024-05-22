#!/usr/bin/env bash
_ide()
{
    local cur prev words cword curdir
    _init_completion || return

    case $prev in
        ide)
            curdir=$(pwd)
            cd "$HOME/projects/" 2>/dev/null && _filedir -d
            cd "$curdir"    
            ;;
    esac
} && complete -F _ide ide
