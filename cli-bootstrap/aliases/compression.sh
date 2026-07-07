#!/usr/bin/env zsh
# aliases/compression.sh — Archive and compression
# Main content in nginx.sh COMPRESSION section; extras here
alias lzma-compress='lzma -z'
alias lzma-decompress='lzma -d'
alias compress-dir='tar -czvf "$(basename $(pwd)).tar.gz" .'
alias extract-here='tar -xzvf'
