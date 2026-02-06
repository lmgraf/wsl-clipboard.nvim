#!/bin/bash
# Read UTF-8 from stdin -> write UTF-16LE to Windows clipboard

iconv -f UTF-8 -t UTF-16LE | clip.exe

