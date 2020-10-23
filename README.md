# DMA_Configuration



Configuration of AXI DMA in VHDL 


This design configures the DMA controller and implements a memory access pattern


The design resulted in a very complex state machine, Additional comments in "fsm_dma_config" module explains the technique and approach to solve the problem


The concept is derived from the ring buffer where images are stored in buffer and read in a very specific way which is termed as memory access pattern. 
According to the requirement of the project, only 4 pixels are read from every row.

The reading pattern is as follows
The first row of the first image is read, and second row of second image is read and so on with rest of images in buffer.
only 4 pixels are read in every reading iteration.



After all the rows are successfully read, the first element of buffer is over written and now the second element of buffer acts as first image and process repeats.
