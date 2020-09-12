----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2020 04:12:47 PM
-- Design Name: 
-- Module Name: fsm_dma - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm_dma_config is
 
 generic (
    Base_DMA_addr : std_logic_vector := x"41e00000";
    Desired_DMA_Transfers : integer := 5;
    
    FIFO_depth : integer := 5;
    FIFO_width : integer := 32
    
    );
 
 
 
 
 Port (
 
 clk  : in std_logic;
 rst : in std_logic;
 -- Valid signal(single single for both master and slave for easier control scheme, Compliant with AXI )
 valid_w : in std_logic;
 -- Ready Signal for handshake
 ready_w  : in std_logic;
 -- Address Read valid signal for reading data from Slave(AXI DMA) registers
 
 valid_r  : in std_logic;
 ready_r  : in std_logic;
 Bvalid : in std_logic;

 start_write : out std_logic;
 start_read  : out std_logic;
 start_write_d   : out std_logic;
 
 
 start_trans : in std_logic;
 addrw  : out std_logic_vector(31 downto 0);
 dataw  : out std_logic_vector(31 downto 0);
 addrR : out std_logic_vector(31 downto 0);
 dataR  : in std_logic_vector(31 downto 0);
 Rvalid : in std_logic;
 last_transfer : out std_logic;
 mm2s_last_transfer : out std_logic;
 mm2s_v     : out std_logic;
 s2mm_v : out std_logic;
 wvalid : in std_logic;
 wready : in std_logic;
 Bready : in std_logic;
 frame_length : in std_logic_vector(31 downto 0)

 
  );
end fsm_dma_config;

 architecture Behavioral of fsm_dma_config is

type state_m is ( idle, dma_s, dram_addr, dma_length,dma_read,dma_status, mm2s_start, dram_sa, mm2s_length, stop_dma, mm2s_read,mm2s_status,mm2s_stop);

signal dma_state : state_m;


--signal DMEM_Addr : std_logic_vector(31 downto 0) := "00000000000100000000000000000000";
--signal MM2S_DMEM : std_logic_vector(31 downto 0) := "00000000000100000000000000000000";
--signal DMEM_Addr : std_logic_vector(31 downto 0) := "01000000000000000000000000000000";
signal DMEM_Addr : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal drcntr   : std_logic;
signal dsignal : integer := 0;
signal asignal  : std_logic := '0';
signal Next_Dram_Addr : integer := 0;
signal scntr   : integer := 0;
signal dram_alert : std_logic := '0';
signal cntrlstart : std_logic := '0';
signal cntrlread : std_logic := '0';
signal start_writing : std_logic;
signal recon       : std_logic := '0';
signal stopcore   : std_logic := '0';
signal countrec  : integer := 0;
signal start_reading : std_logic := '0';
signal rsignal    : std_logic := '0';
signal MM2S_DMEM  : std_logic_vector(31 downto 0) := (others => '0');
--signal MM2S_DMEM : std_logic_vector(31 downto 0) := "00000000000100000000000000000000";
signal Next_MM2S_Addr : integer := 0;
signal loop_signal    : std_logic := '0';
--signal s2mm_valid : std_logic := '0';
signal chck_signal   : std_logic := '0';
signal start_write_data : std_logic := '0';
signal start_writing_data : std_logic;
signal ctr       : integer := 0;
signal s2mm_valid : std_logic := '0';
signal length_signal : std_logic := '0';
signal lncntr        : std_logic := '0';
signal mm2s_valid    : std_logic := '0';
signal mm2s_ctr      : std_logic := '0';
signal Base_Data_Value : integer := 768;  
signal last_count : integer := 0;


constant dma_init_reg_addr : integer := 48;
constant dma_dram_reg_addr : integer := 72;
constant dma_length_reg_addr : integer := 88;
constant dma_mm2s_cntrl_reg_addr : integer := 0;
constant dma_mm2s_dram_reg_addr : integer := 24;
constant dma_mm2s_lngth_reg_addr : integer := 40;
constant dma_status_reg_addr : integer := 52;
constant dma_mm2s_status_reg_addr : integer := 4;


type FIFO is array (0 to FIFO_depth-1) of std_logic_vector(FIFO_width-1 downto 0);

signal FIFO_content : FIFO := (others => (others => '0'));

signal wr_ptr :  integer range 0 to FIFO_depth-1;

signal rd_ptr  : integer range 0 to FIFO_depth-1;
signal sec_rd_ptr  : integer range 0 to FIFO_depth-1;

signal empty_flag : std_logic := '0';
signal full_flag  : std_logic := '0';

signal count_pixels : integer := 0;
signal write_complete : std_logic := '0';
signal mm2s_recon : std_logic := '0';
signal mm2s_countrec : integer := 0;
signal mm2s_rsignal : std_logic := '0';
signal mm2s_stopcore : std_logic := '0';
signal Output_data : std_logic_vector(31 downto 0);
signal pixel_count : std_logic := '0';
signal cycles_complete : std_logic := '0';
signal mm2s_output_data : std_logic_vector(31 downto 0);
signal mm2s_offset : integer := 0;
signal fifo_count : integer := 0;
signal next_read_cycles : integer := 0;
signal cycle_counter    : integer := 0;
signal shift_image     : std_logic := '0';
signal mm2s_base_addr_cntrl    : std_logic := '0';
signal mm2s_dram_alert        : std_logic := '0';
signal mm2s_scntr     : integer := 0;
signal mm2s_dsignal  : integer := 0;
signal mm2s_asignal  : std_logic := '0';
signal recon_proc_ctrl  : std_logic := '0';
signal mm2s_recon_proc_ctrl : std_logic := '0';
signal off_mm2s_addr  : std_logic := '0';
signal wr_ptr_reg     : integer := 0;
signal mm2s_base_offset : integer := 0;
signal cycle_turn_off   : std_logic := '0';
signal mm2s_cycle_ctrl  : std_logic := '0';
signal Base_MM2S_Addr   : std_logic_vector(31 downto 0) := (others => '0');
signal mm2s_other_rows : std_logic := '0';
signal counter_number : integer := 0;
signal count_assert   : std_logic := '0';
signal Sec_base_MM2S_Addr : integer := 0;
signal sec_mm2s_offset    : integer := 0;
signal ctrl_shift     : std_logic := '0';
signal dram_fb_ctrl   : std_logic := '0';
signal mm2s_base_ctrl : std_logic := '0';
signal mm2s_sec_rsignal : std_logic := '0';
signal rd_counter       : integer :=0;
signal reverse_ptr_ctrl    : std_logic := '0';
signal new_image_trigger      : std_logic := '0';
signal Write_DMEM_Addr : integer := 0;
signal fb_shift_wr     : std_logic := '0';
signal shift_offset    : integer := 0;
signal add_shift_offset : integer := 0;
signal neg_rd_ctr       : integer := 4;
signal shift_counter   : integer := 0;
signal count_neg   : integer := 0;
signal shift_reverse  : std_logic := '0';
signal count_turnoff_neg : integer := 0;
signal mm2s_shift_other_rows : std_logic := '0';
signal rnd_counter   : std_logic := '0';
signal rnd_turnoff_counter  : std_logic := '0';
signal shift_assert  : std_logic := '0';
signal cycle_turn_shift_rise   : std_logic := '0';
signal shift_incrementer      : integer := 0;
signal add_cycle_turnoff_offset    : integer := 0;
signal add_shift_rise_offset      : integer := 0;
signal shift_incrementer_shift    : integer := 0;
signal cylce_shift_rise         : std_logic := '0';
signal end_buf_shift       : integer := 0;
signal end_buf_sig      : integer := 0;
signal end_buf_iter     : std_logic := '0';
signal end_buf_other_rows  : std_logic := '0';
signal cntrl_count_turnoff   : std_logic := '0';


begin


process(clk)

variable internal_shift_counter : integer := 0;  
variable internal_turnoff_counter : integer := 0;

begin
 if rising_edge(clk) then
   if(rst = '0') then
       dma_state <= idle;
       s2mm_valid <= '0';
      
      
     
    else
    
    case dma_state is 
      
     when idle =>
       
          if(start_trans = '1') then
               dma_state <= dma_s;
               else
               dma_state <= idle;
               addrw <= (others => '0');
               dataw <= (others=> '0');
               addrR <= (others => '0');
               
        end if;
        
     
   when dma_s =>
     cntrlstart <= '1';
     cntrlread <= '0';
      drcntr <= '1';
      lncntr <= '1';
      
   addrw <= std_logic_vector(to_unsigned(dma_init_reg_addr, 32));
   dataw <= "00000000000000000000000000000001";
             
     if(Bvalid = '1' and Bready = '1') then
     dma_state <= mm2s_start;
     s2mm_valid <= '1';
     else
     dma_state <= dma_s;
     end if;
     
     when mm2s_start => 

    cntrlstart <= '1';
    cntrlread <= '0';
    
    addrw <= std_logic_vector(to_unsigned(dma_mm2s_cntrl_reg_addr, 32));
     dataw <= "00000000000000000000000000000001";
     mm2s_base_addr_cntrl <= '1';
     
      
      if(Bvalid = '1' and Bready = '1') then     
      dma_state <= dram_addr;
     
      mm2s_valid <= '1';    
       cntrlstart <= '0';  
       pixel_count <= '1';
          
      else     
      dma_state <= mm2s_start;     
      end if;     
        
                
  when dram_addr =>
     cntrlstart <= '1';
      cntrlread <= '0';

   
 addrw <= std_logic_vector(to_unsigned(dma_dram_reg_addr, 32));
  
     
  if(fb_shift_wr = '1') then
      Write_DMEM_Addr <= Write_DMEM_Addr + 1024;
        dataw <= std_logic_vector(unsigned(DMEM_Addr) + Write_DMEM_Addr);
        fb_shift_wr <= '0';
     end if;
     
     
     
     if(drcntr = '1') then
      dataw <= DMEM_Addr;
       drcntr <= '0';

          end if;
  
 if(dram_alert = '1') then
     
   if(scntr = 1) then
     scntr <= 0;
       dram_alert <= '0';
       dataw <= DMEM_Addr;
       
       
     elsif(dsignal = 1) then
          dsignal <= 0;
         asignal <= '1';
         length_signal <= '1';
        else 
       Next_Dram_Addr <= to_integer(unsigned(frame_length)*4);
        dsignal <= dsignal + 1;
       
      if(asignal = '1') then
        DMEM_Addr <= std_logic_vector(to_unsigned((Next_Dram_Addr +4) , 32) + unsigned(DMEM_Addr));
        asignal <= '0';
       dsignal <= 0;
       scntr <= scntr + 1 ; 

       end if;
       
      end if;
     end if;
    
        if(Bvalid = '1' and Bready = '1') then
        dma_state <= dma_length;
        else
        dma_state <= dram_addr;
        end if;
                
    
    
    
           
       when dma_length =>
       
      cntrlstart <= '1';
      cntrlread <= '0';
     
      addrw <= std_logic_vector(to_unsigned(dma_length_reg_addr, 32));

      
      -- 1kb
      dataw<=  "00000000000000000000010000000000";
       Output_data <= "00000000000000000000010000000000";
       recon_proc_ctrl <= '1';
   
      if(Bvalid = '1' and Bready = '1') then
      dma_state <= dma_status;
       cntrlstart <= '0';
      else
      dma_state <= dma_length;
      end if;
   
   
   
   
   
       when dma_read =>
         
         cntrlstart <= '0';
         cntrlread <= '1';
       
          addrR <= std_logic_vector(to_unsigned(dma_init_reg_addr, 32)); 
               if(valid_r = '1' and ready_r = '1') then
        
             dma_state <= dma_status;
                      
              else
              dma_state <= dma_read;
              
          -- if(stopcore = '1' and recon = '1') then
                  
            -- dma_state <= dram_sa;
           --  cntrlread <= '0';
           --  recon_proc_ctrl <= '0';
                      
                  if(rsignal= '1') then
                      dma_state <= dram_sa;
                      recon_proc_ctrl <= '0';
                       --dram_alert <= '1';
                       cntrlread <= '0';
                      if(shift_image = '1') then
                      Sec_base_MM2S_Addr <=  Sec_base_MM2S_Addr + 1024;
                   
                          neg_rd_ctr <= neg_rd_ctr -1;
                           dram_fb_ctrl <= '1';
                          if(end_buf_sig = 5) then
                              Sec_base_MM2S_Addr <= 0;
                              end_buf_iter <= '1';
                              end if;
                    
                    
                         end if;        
                      else
                     dma_state <= dma_read;
                            end if;    
                    end if;
                      
       
       when dma_status =>
          cntrlstart <= '0';
             cntrlread <= '1';
       addrR <= std_logic_vector(to_unsigned(dma_status_reg_addr, 32)); 
             
        if(valid_r = '1' and ready_r = '1') then
        
        dma_state <= dma_read;
                 
         else
         dma_state <= dma_status;
         end if;

          
         when  dram_sa =>
         
                 cntrlstart <= '1';
                 cntrlread <= '0';
                 --counter_assert <= '0';
                 addrw <= std_logic_vector(to_unsigned(dma_mm2s_dram_reg_addr, 32));
                  
                  if(Bvalid = '1' and Bready = '1') then     
                  dma_state <= mm2s_length;     
                      
                  else     
                  dma_state <= dram_sa;     
                  end if;    
     
            
  
                 if(mm2s_base_addr_cntrl = '1' or mm2s_cycle_ctrl = '1' or dram_fb_ctrl = '1') then
                     dataw <= std_logic_vector(to_unsigned(Sec_base_MM2S_Addr,32) + mm2s_base_offset);
                     mm2s_base_addr_cntrl <= '0';
                     mm2s_cycle_ctrl <= '0';
                     dram_fb_ctrl <= '0';
                     mm2s_base_ctrl  <= '0';
                
                  end if;
                  
         
                      if(mm2s_dram_alert = '1') then
                      
                       
                    if(mm2s_scntr = 1) then
                      mm2s_scntr <= 0;
                        mm2s_dram_alert <= '0';
                        dataw <= MM2S_DMEM;
                        
                else
                      if( off_mm2s_addr = '1') then
                         
                          mm2s_asignal <= '1';
                          if(shift_image = '1') then
                          mm2s_offset <= sec_mm2s_offset;
                          elsif(cycle_turn_off = '1') then
                         -- add_cycle_turnoff_offset <= add_cycle_turnoff_offset +1024;
                          mm2s_offset <= sec_mm2s_offset;
                        
                          else
                          mm2s_offset <= 1024 + mm2s_offset;
                         
                          end if;
                          off_mm2s_addr <= '0';
                       
                       
                      end if; 
                      
                   
                  if(mm2s_asignal = '1' and mm2s_other_rows = '1') then
                      MM2S_DMEM <= std_logic_vector(to_unsigned(mm2s_offset + (rd_ptr*68) +16*counter_number,32));
                             mm2s_asignal <= '0';
                             mm2s_dsignal <= 0;
                             mm2s_scntr <= mm2s_scntr +1;
                              mm2s_other_rows <= '0';
                    elsif (mm2s_asignal = '1' and mm2s_shift_other_rows = '1') then
                             MM2S_DMEM <= std_logic_vector(to_unsigned(shift_offset + (rd_ptr*68) +16*counter_number,32));   
                               mm2s_asignal <= '0';
                               mm2s_dsignal <= 0;
                               mm2s_scntr <= mm2s_scntr +1;
                               mm2s_shift_other_rows <= '0';
                               
                       elsif(mm2s_asignal = '1' and shift_reverse = '1') then
                           MM2S_DMEM <= std_logic_vector(to_unsigned(shift_offset + (rd_ptr*68),32));
                            shift_reverse <= '0';
                            mm2s_asignal <= '0';
                             mm2s_dsignal <= 0;
                            mm2s_scntr <= mm2s_scntr + 1 ;
                            
                        elsif(mm2s_asignal = '1' and shift_assert = '1') then
                        
                      MM2S_DMEM <= std_logic_vector(to_unsigned(mm2s_offset + (rd_ptr*68),32));
                       mm2s_asignal <= '0';
                      mm2s_dsignal <= 0;
                      mm2s_scntr <= mm2s_scntr + 1 ;
                      shift_assert <= '0';    
                            
                     
                       elsif(mm2s_asignal = '1') then
                        MM2S_DMEM <= std_logic_vector(to_unsigned(mm2s_offset + (rd_ptr*68),32));
                         ctrl_shift <= '0'; 
                         mm2s_asignal <= '0';
                        mm2s_dsignal <= 0;
                        mm2s_scntr <= mm2s_scntr + 1 ;
                        
             
                       
                        end if;
                       end if;
                      end if; 
                  
                     
            when mm2s_length =>
            
                        cntrlstart <= '1';
                         cntrlread <= '0';
                         addrw <= std_logic_vector(to_unsigned(dma_mm2s_lngth_reg_addr, 32));
                          
                                -- 1Mb
                                
                                -- should change to 4 pixels 16 bytes.
                                
                                dataw <= "00000000000000000000000000010000";
                                mm2s_output_data <=   "00000000000000000000000000010000";
                             
                 
                             
                    
                          mm2s_recon_proc_ctrl <= '1';
                         
                         if(Bvalid = '1' and Bready = '1') then     
                         dma_state <= mm2s_status;     
                          cntrlstart <= '0';     
                         else     
                         dma_state <= mm2s_length;     
                         end if;     
                                      
           
                             
             when mm2s_read =>
             
                  cntrlstart <= '0';
                    cntrlread <= '1';
                    
                    off_mm2s_addr <= '1';
                   
                   addrR <= std_logic_vector(to_unsigned(dma_mm2s_cntrl_reg_addr, 32));
                     if(valid_r = '1' and ready_r = '1') then
                      
                         dma_state <= mm2s_status;
                        
                         
                     else
                         dma_state <= mm2s_read;
                     
                               if(cycles_complete = '1' and mm2s_rsignal = '1') then
                                              
                                         dma_state <= dram_sa;
                                         cntrlread <= '0';
                                         loop_signal <= '1';
                                          mm2s_base_offset <= mm2s_base_offset + 16;
                                          mm2s_cycle_ctrl <= '1';
                                          cycle_turn_off <= '1';
                                          mm2s_base_ctrl <= '1';
                                          mm2s_offset <= 0;
                                          shift_image <= '0';
                                          rnd_counter <= '0';
                                          rnd_turnoff_counter <= '0';    
                                          counter_number <= counter_number +1;
                                           mm2s_recon_proc_ctrl <= '0';
                                           sec_mm2s_offset <= 0;
                                           shift_offset <= 0;
                                           end_buf_iter <= '0';
                                           end_buf_other_rows <= '1';
                                           if(cntrl_count_turnoff = '1') then
                                           count_turnoff_neg <= 4;
                                           end if;
                                      
                                          
                                         if(counter_number = 4 and rd_ptr =4) then
                                         dma_state <= dram_addr;
                                         counter_number <= 0;
                                         shift_image <= '1';
                                         mm2s_offset <= 0;
                                         mm2s_other_rows <= '0';
                                         cycle_turn_off <= '0';
                                         mm2s_cycle_ctrl <= '1';
                                         sec_mm2s_offset <= 0;
                                         mm2s_base_offset <= 0;
                                         fb_shift_wr <= '1';
                                         count_turnoff_neg <= 0;
                                         count_neg <= 0;
                                         end_buf_other_rows <= '0';
                                         DMEM_Addr <= (others => '0');
                                    end if;   
                                    
                                  elsif(end_buf_iter = '1' and mm2s_rsignal = '1') then
                                  
                                         dma_state <= dram_sa;
                                         shift_offset <= shift_offset + 1024;
                                         mm2s_recon_proc_ctrl <= '0';
                                         mm2s_dram_alert <= '1';
                                         shift_reverse <= '1';  
                                
                                
                                  elsif(end_buf_sig = 5) then
                                          if( end_buf_other_rows = '1' and mm2s_rsignal = '1') then
                                           
                                          dma_state <= dram_sa;
                                          shift_offset <= shift_offset + 1024;
                                          mm2s_recon_proc_ctrl <= '0';
                                          mm2s_dram_alert <= '1';
                                          mm2s_shift_other_rows <= '1';
                                                 end if;
                                
                                
                                   elsif(shift_image = '1' and count_neg = neg_rd_ctr and mm2s_rsignal = '1') then
                                          dma_state <= dram_sa;
                                           
                                           shift_offset <= 0;
                                           shift_reverse <= '1';
                                            mm2s_dram_alert <= '1';
                                            count_neg <= 0;
                                           rnd_counter <= '1';
                                           shift_counter <= shift_counter +1;
                                            mm2s_recon_proc_ctrl <= '0';
                                            add_shift_rise_offset <= 0;
                                                if(neg_rd_ctr = 0) then
                                                    neg_rd_ctr <= 4;
                                                    count_turnoff_neg <= 4;
                                                    cntrl_count_turnoff <= '1';
                                                    end if;
                                            
                                             
                                         
                                         elsif(shift_image = '1' and rnd_counter='1' and mm2s_rsignal = '1') then
                                                   dma_state <= dram_sa;
                                                  shift_offset <= shift_offset + 1024;
                                                   mm2s_recon_proc_ctrl <= '0';
                                                   mm2s_dram_alert <= '1';
                                                   shift_reverse <= '1';
                                              
                                       
                                         
                                          elsif(shift_image = '1' and mm2s_rsignal = '1') then
                                            dma_state <= dram_sa;
                                            --sec_mm2s_offset <= sec_mm2s_offset + 1024;
                                            mm2s_recon_proc_ctrl <= '0';
                                            --count_neg <= count_neg+1;
                                            mm2s_dram_alert <= '1';
                                            shift_assert <= '1';
                                               if(cylce_shift_rise = '1') then
                                                     add_shift_rise_offset <= add_shift_rise_offset + 1024; 
                                                    count_neg <= count_neg + 1;
                                                     if(count_neg = neg_rd_ctr) then
                                                              add_shift_rise_offset <= 0;
                                                               sec_mm2s_offset <= 0;
                                                              
                                                         else
                                                                 sec_mm2s_offset <= shift_incrementer_shift + 1024 + add_shift_rise_offset;
                                                            end if;
                                                         end if;        
                                           
                                        elsif(cycle_turn_off = '1' and count_turnoff_neg = neg_rd_ctr and mm2s_rsignal = '1') then
                                         dma_state <= dram_sa;
                                          
                                          shift_offset <= 0;
                                          mm2s_shift_other_rows <= '1';
                                          mm2s_dram_alert <= '1';
                                          count_turnoff_neg <= 0;
                                          rnd_turnoff_counter <= '1';
                                          shift_counter <= shift_counter +1;
                                          mm2s_recon_proc_ctrl <= '0';
                                           add_cycle_turnoff_offset <= 0;
                                           sec_mm2s_offset <= 0;
                                           
                                               
                                        
                                        elsif(cycle_turn_off = '1' and rnd_turnoff_counter='1' and mm2s_rsignal = '1') then
                                             dma_state <= dram_sa;
                                                 shift_offset <= shift_offset + 1024;
                                                  mm2s_recon_proc_ctrl <= '0';
                                                  mm2s_dram_alert <= '1';
                                                   mm2s_shift_other_rows <= '1';
                                                  --shift_reverse <= '1';
                                                    
                                 
                            
                                          elsif(cycle_turn_off = '1' and mm2s_rsignal = '1') then
                                         
                                            dma_state <= dram_sa;
                                            mm2s_dram_alert <= '1';
                                            mm2s_other_rows <= '1';
                                            mm2s_recon_proc_ctrl <= '0';
                                            sec_mm2s_offset <= sec_mm2s_offset + 1024;
                                           
                                             if(cycle_turn_shift_rise = '1') then
                                              add_cycle_turnoff_offset <= add_cycle_turnoff_offset + 1024;
                                               count_turnoff_neg <= count_turnoff_neg + 1;
                                               
                                                if(count_turnoff_neg = neg_rd_ctr) then
                                                add_cycle_turnoff_offset <= 0;
                                                sec_mm2s_offset <= 0;
                                                else
                                                  
                                                 sec_mm2s_offset <= shift_incrementer + 1024 + add_cycle_turnoff_offset;
                                                 
                                              end if;
                                            
                                            
                                            end if;
                                         
                                      elsif(mm2s_rsignal= '1') then
                                                dma_state <= dram_addr;
                                                mm2s_dram_alert <= '1';
                                                cntrlread <= '0';
                                                mm2s_recon_proc_ctrl <= '0';
                                                dram_alert <= '1';
                                                          
                                               else
                                              dma_state <= mm2s_read;
                                                     end if;    
                                      end if;
                                
                                    
                                          
                                       
             when mm2s_status =>
             cntrlstart <= '0';
              cntrlread <= '1';
                  addrR <= std_logic_vector(to_unsigned(dma_mm2s_status_reg_addr, 32));
                  if(valid_r = '1' and ready_r = '1') then
                    dma_state <= mm2s_read;
                            
                    else
                    dma_state <= mm2s_status;
                    end if;
                    
         

            when mm2s_stop =>
             cntrlstart <= '1';
           cntrlread <= '0';
     
           mm2s_valid <= '0';
            addrw <= std_logic_vector(to_unsigned(dma_mm2s_cntrl_reg_addr, 32));
           dataw <= (others => '0');
           
           
                             if(Bvalid = '1' and Bready = '1') then     
                                   dma_state <= mm2s_stop;
                                   --last_transfer <= '0';     
                                      
                                   end if;     
   
               when others =>
               dma_state <= idle;
                  end case;
                  
                  end if;
                  end if;
                  
    
       end process;
       

   process(clk)
      begin
       if rising_edge(clk) then
  
      if(rst = '0') then
      
        recon <= '0';
        
        
       elsif(dataR = "00000000000000000001000000000010" and recon_proc_ctrl = '1') then
          
               recon <= '1';
               if(recon = '1') then
               countrec <= countrec + 1;
               rsignal <= '1';
        
             if(countrec = Desired_DMA_Transfers-1) then
               stopcore <= '1';
               countrec <= 0;
               
              
              -- last_transfer <= '1';
               --s2mm_v <= '0';
             
              end if;
            end if;
                
         else
         recon <= '0';               

         stopcore <= '0';
         rsignal <= '0';

   end if;
   end if;
     
          end process;         

    process(clk)
      begin
       if rising_edge(clk) then
  
      if(rst = '0') then
      
        mm2s_recon <= '0';
        
        
          elsif(dataR = "00000000000000000001000000000010" and mm2s_recon_proc_ctrl = '1') then
          
               mm2s_recon <= '1';
               
               if(mm2s_recon = '1') then
               mm2s_countrec <= mm2s_countrec + 1;
               mm2s_rsignal <= '1';
               mm2s_sec_rsignal <= '0';
               end if;
         
             if(rd_ptr = FIFO_depth-1 and mm2s_recon ='1') then
               mm2s_stopcore <= '1';
               mm2s_countrec <= 0;
               cycles_complete <= '1';
             end if;
              -- last_transfer <= '1';
               --s2mm_v <= '0';
         
     
                
         else
         mm2s_recon <= '0';      
         mm2s_stopcore <= '0';
         mm2s_rsignal <= '0';
         cycles_complete <= '0';
         mm2s_sec_rsignal <= '1';

   end if;
   
    
 --  if(reverse_ptr_ctrl = '1') then
 --    mm2s_countrec <= mm2s_countrec - 1;
 --    
 -- 
 -- 
  end if;
   
          end process;         



   process(clk)
   begin
   if rising_edge(clk) then
      if( rst= '0') then
           start_writing <= '0';
       elsif(cntrlstart = '1') then
            if(start_writing = '0' and Bvalid = '0' and valid_w = '0' and wvalid = '0') then
                 start_writing <= '1';
            else
              start_writing <= '0';
              end if;
         else
           start_writing <= '0';
         end if;
       end if;
         end process;              

   start_write <= start_writing;



   process(clk)
   begin
   if rising_edge(clk) then
      if( rst= '0') then
           start_reading <= '0';
       elsif(cntrlread = '1') then
            if( start_reading = '0' and Rvalid = '0' and valid_r = '0') then
                  start_reading <= '1';
            else
               start_reading <= '0';
         end if;
        else
         start_reading <= '0'; 
         end if;
       end if;
         end process;              

   start_read <=  start_reading;


 process(clk)
 begin
 if rising_edge(clk) then
    if (rst = '0') then
       s2mm_v <= '0';
       last_transfer <= '0';
     elsif(s2mm_valid = '1') then
        s2mm_v <= '1';
       else
       s2mm_v <= '0';
       end if;
    if(stopcore = '1') then
      last_transfer <= '1';
       mm2s_ctr <= '1';
      else
      last_transfer <= '0';
   
        end if;
       
    if(mm2s_ctr = '1') then
         last_transfer <= '0';
     end if;
              
         end if;
       
         end process;
                 
  process(clk)
          begin
          if rising_edge(clk) then
             if (rst = '0') then
                mm2s_v <= '0';
                mm2s_last_transfer <= '0';
              elsif(mm2s_valid = '1') then
                   mm2s_v <= '1';
                  else
                  mm2s_v <= '0';
                  end if;
                  if(mm2s_ctr = '1') then 
                if(mm2s_stopcore = '1') then
                 mm2s_last_transfer <= '1';
                 else
                 mm2s_last_transfer <= '0';
                 --s2mm_v <= '0';
                   end if;
                   end if;
                 end if;
                   end process;

  process(clk)
     begin
  
         if rising_edge(clk) then
            if(rst = '0') then
             wr_ptr <= 0;
            elsif(rsignal = '1') then
            wr_ptr <= wr_ptr +1;
            --FIFO_content(wr_ptr) <= Output_data;
            
            end if;
            
            if(wr_ptr = FIFO_depth-1 and rsignal = '1') then
            wr_ptr_reg <= wr_ptr;
            wr_ptr <= 0;
            
         --   if(shift_image <= '1') then
         --    wr_ptr <= wr_ptr +1;
         --   end if; 
          
          end if;
          end if;
        end process;
            
        
                


  process(wr_ptr, rd_ptr)
    begin
  
     if (wr_ptr > rd_ptr) then
          fifo_count <= wr_ptr-rd_ptr;
      else
            fifo_count <= (wr_ptr- rd_ptr) + FIFO_depth-1;
            end if;    
            end process;
-- Pixel counting process


    process(clk)
    begin
      if rising_edge(clk) then
        if (rst = '0') then
             -- count_pixels <= 0;
              
             
               elsif(mm2s_rsignal = '1') then
                      --count_pixels <= count_pixels + 1;
                      rd_ptr <= rd_ptr + 1;
                      
                      
                      
               elsif(dram_fb_ctrl = '1') then       
                    rd_ptr <= 0;  
               
            end if;
            
       
           
           if(rd_ptr = FIFO_depth-1 and mm2s_rsignal = '1') then
       
                rd_ptr <= 0;
                
                -- cycles_complete <= '1';
                 cycle_counter <= cycle_counter +1;
                 --mm2s_base_offset <= mm2s_base_offset + 16;
                
   
           end if;
  
            
           end if;
           
             
            end process;
                          

  
      
   process(shift_image)
    variable counter_end_entry : integer := 0;
   begin
    
        if falling_edge(shift_image) then
            cycle_turn_shift_rise <= '1';
            shift_incrementer <= shift_incrementer + 1024;
                counter_end_entry := counter_end_entry + 1;
                     if(counter_end_entry = 4) then
                             shift_incrementer <= 0;
                             counter_end_entry := 0;
                             end if;
            end if;
           
               
                end process; 


      
   process(shift_image)
  
   begin
    
        if rising_edge(shift_image) then
            cylce_shift_rise <= '1';
            shift_incrementer_shift <= shift_incrementer_shift + 1024;
            end_buf_sig <= end_buf_sig + 1;
            
        
            
            end if;
           
               
                end process; 























end Behavioral;