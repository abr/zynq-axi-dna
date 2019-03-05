**put license/disclaimer here probably**

# What is this?

In the ``ip_repo`` folder you will find an IP core, ``zynq_AXI_DNA``
that reads the 57bit Device DNA from the PL of a Zynq 7000 device.
The core uses an AXI interface and will return a 64bit value
where the last 7 bits beyond the 57 DNA bits are tied to zero.

*This work is based off the
[Xilinx AXI_DNA](https://www.xilinx.com/support/answers/71342.html)
core provided for the Ultrascale+ devices*

In the ``pynq_dna`` you will find an example project for the PYNQ-Z1
that uses this ``zynq_AXI_DNA`` core in the design.
