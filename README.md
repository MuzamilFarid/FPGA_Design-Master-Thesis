# DMA_Configuration



Configuration of AXI DMA in VHDL 


This design configures the DMA controller and implements a memory access pattern


The design resulted in a state machine in the module "fsm_dma_config", Additional comments in "fsm_dma_config" module explains the technique and approach to solve the problem


The concept is derived from the ring buffer where images are stored in buffer and read in a very specific way which is termed as memory access pattern. 
According to the requirement of the project, only 4 pixels are read from every row.

The reading pattern is as follows
The first row of the first image is read, and second row of second image is read and so on with rest of images in buffer.
only 4 pixels are read in every reading iteration.



After all the rows are successfully read, the first element of buffer is over written and now the second element of buffer acts as first image and process repeats.



Master_Thesis is the Pdf document describing this project in detail.




DMA_DRAM_v1_0 is the top level file instantiating Master and Slave AXI interfaces.




DMA_DRAM_v1_0_M_AXI contains the instantiation of state machine implementing memory access pattern





DMA_DRAM_v1_0_S_AXI contains instantiation of thrghpt_dma



thrghpt_dma contains the module which calculates the clock cycles to calculate writing and reading times and also to calculate the total time ring buffer will take





Ssource_v1_0_M_AXIS is the module which generates images with generic frame length for simulation purposes.





