#!/usr/bin/env sh
# Read from Windows clipboard → output UTF-8 to stdout

powershell.exe -nologo -noprofile Get-Clipboard | sed 's/\r$//'

