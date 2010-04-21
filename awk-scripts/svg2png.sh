#!/bin/bash

INFILE=$1
OUTFILE=${INFILE%%.svg}.png
inkscape --export-dpi=90 -C -e=$OUTFILE $INFILE

