#!/bin/bash

# USAGE ./build_DNA_extractor.sh


## Make output directory
if [ ! -d "../bin" ]; then
    mkdir ../bin
fi

## Run Vivado
echo "=============="
echo "Running Vivado"
echo "=============="
vivado -nojournal -nolog -mode tcl -source PYNQ_DNA.tcl
