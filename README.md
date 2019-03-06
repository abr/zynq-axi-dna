**put license/disclaimer here probably**

# What is this?

This is a method of reading the Device DNA from the PL for Zynq 7000 devices wrapped in an AXI interface for easy MMIO access on the PS.

This is built with Vivado 2018.3 and is based off the
[Xilinx AXI_DNA](https://www.xilinx.com/support/answers/71342.html)
core provided for the Ultrascale+ devices

## IP core
In the ``ip_repo`` folder you will find an IP core, ``zynq_AXI_DNA``
that reads the 57bit Device DNA from the PL of a Zynq 7000 device.
The core uses an AXI interface and will return a 64bit value
where the last 7 bits beyond the 57 DNA bits are tied to zero.



## PYNQ Example

This has been tested with the PYNQ-Z1 board.

### Build the project
In the ``pynq_dna`` you will find an example project for the PYNQ-Z1
that uses this ``zynq_AXI_DNA`` core in the design. To build the project run:

    ./build_DNA_extractor.sh

This will create a project directory, ``DNA_extractor``and create the Vivado
project. It will also generate the bitstream and save the output files in
the ``bin`` directory.

### Test it out

You can now copy ``DNA_extractor.bit`` and ``DNA_extractor.tcl`` from
the ``bin`` directory to the ``/home/xilinx`` directory of your PYNQ and
copy the ``DNA_test.ipynb`` notebook to the
``/home/xilinx/jupyter_notebooks`` directory.


In your browser open up the PYNQ jupyter server and open
the ``DNA_test`` notebook to see your Device DNA!
