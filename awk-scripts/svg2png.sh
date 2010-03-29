#!/bin/bash

INFILE=$1
OUTFILE=${INFILE%%.svg}.png
inkscape --export-dpi=90 --export-area-canvas --export-background=white --export-png=$OUTFILE $INFILE

