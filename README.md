# DMA_Configuration
Configuration of AXI DMA in VHDL 
This design configures the DMA controller and implements a memory access pattern
The design resulted in a very complex state machine, Additional comments in fsm_dma_config module explains the technique and approach to solve the problem
The concept is derived from the ring buffer where images are stored in buffer and read ina very specific way which is termed as memory access pattern. 
