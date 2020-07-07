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

entity fsm_dma is
 
 generic (
    Base_DMA_addr : std_logic_vector := x"41e00000"
    
    );
 
 
 
 
 Port (
 
 clk  : in std_logic;
 rst : in std_logic;
 valid_w : in std_logic;
 ready_w  : in std_logic;
 valid_r  : in std_logic;
 ready_r  : in std_logic;
 Bvalid : in std_logic;

 start_write : out std_logic;
 start_read  : out std_logic;
 
 
 start_trans : in std_logic;
 addrw  : out std_logic_vector(31 downto 0);
 dataw  : out std_logic_vector(31 downto 0);
 addrR : out std_logic_vector(31 downto 0);
 dataR  : in std_logic_vector(31 downto 0);
 Rvalid : in std_logic
 
  );
end fsm_dma;

architecture Behavioral of fsm_dma is

type state_m is ( idle, dma_s, dram_addr, dma_length,dma_read,dma_status, dma_stop, mm2s_start, dram_sa, mm2s_length, stop_dma, mm2s_read,mm2s_status,mm2s_stop);

signal dma_state : state_m;


signal DMEM_Addr : std_logic_vector(31 downto 0) := (others => '0');
signal drcntr   : std_logic;
signal dsignal : integer := 0;
signal asignal  : std_logic := '0';
signal Next_Dram_Addr : integer := 0;
signal scntr   : integer := 0;
signal dram_alert : std_logic := '0';
signal cntrlstart : std_logic;
signal cntrlread : std_logic;
signal start_writing : std_logic;
signal recon       : std_logic := '0';
signal stopcore   : std_logic := '0';
signal countrec  : integer := 0;
signal start_reading : std_logic := '0';
signal rsignal    : std_logic := '0';
signal MM2S_DMEM  : std_logic_vector(31 downto 0) := (others => '0');
signal Next_MM2S_Addr : integer := 0;
signal loop_signal    : std_logic := '0';









constant dma_init_reg_addr : integer := 48;
constant dma_dram_reg_addr : integer := 72;
constant dma_length_reg_addr : integer := 88;
constant dma_mm2s_cntrl_reg_addr : integer := 0;
constant dma_mm2s_dram_reg_addr : integer := 24;
constant dma_mm2s_lngth_reg_addr : integer := 40;
constant dma_status_reg_addr : integer := 52;
constant dma_mm2s_status_reg_addr : integer := 4;


begin

process(clk)

begin
 if rising_edge(clk) then
   if(rst = '0') then
       dma_state <= idle;
     
    else
    
    case dma_state is 
      
     when idle =>
       
          if(start_trans = '1') then
               dma_state <= dma_s;
               else
               dma_state <= idle;
               addrw <= (others=> '0');
               dataw <= (others => '0');
               addrR <= (others => '0');
               
        end if;
        
     
    when dma_s =>
      cntrlstart <= '1';
      cntrlread <= '0';
      addrw <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_init_reg_addr, 32));
      dataw <= "00000000000000000000000000000001";
        drcntr <= '1';
      if(valid_w = '1' and ready_w = '1') then
           dma_state <= dram_addr;
           else
           dma_state <= dma_s;
           
        end if;
           
                 
   when dram_addr =>
       cntrlstart <= '1';
       cntrlread <= '0';
     
    addrw <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_dram_reg_addr, 32));
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
            else 
           Next_Dram_Addr <= 255*4;
            dsignal <= dsignal + 1;
           
          if(asignal = '1') then
            DMEM_Addr <= std_logic_vector(to_unsigned(Next_Dram_Addr , 32) + unsigned(DMEM_Addr));
            asignal <= '0';
           dsignal <= 0;
           scntr <= scntr + 1 ; 

           end if;
           
          end if;
         end if;
  
         
           
           
           
        
           
      if(valid_w = '1' and ready_w = '1') then
        dma_state <= dma_length;
         else
     dma_state <= dram_addr;
                  
               end if;
              
             
                    
       when dma_length =>
       
         cntrlstart <= '1';
           cntrlread <= '0';
           
     addrw <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_length_reg_addr, 32));
     dataw <= "00000000000000000000010000000000";
     
       if(valid_w = '1' and ready_w = '1') then
                     dma_state <= dma_read;
                     else
                     dma_state <= dma_length;
                     
                  end if;
       
       
       when dma_read =>
         
         cntrlstart <= '0';
         cntrlread <= '1';
         
            if(valid_r = '1' and ready_r = '1') then
            
              addrR <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_init_reg_addr, 32)); 
                           dma_state <= dma_status;
                           else
                           dma_state <= dma_read;
                           
                        end if;
       
       when dma_status =>
          cntrlstart <= '0';
             cntrlread <= '1';
             
        if(valid_r = '1' and ready_r = '1') then
        
               addrR <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_status_reg_addr, 32)); 
                 dma_state <= dma_read;
                 
         else
         dma_state <= dma_status;
         
         if(stopcore = '1' and recon = '1') then
                
           dma_state <= stop_dma;
                 
             elsif(rsignal= '1') then
                  dma_state <= dram_addr;
                  dram_alert <= '1';
                            
                 else
                dma_state <= dma_status;
                       end if;    
               end if;
                 
               

       when stop_dma =>
               
                 cntrlstart <= '1';
                   cntrlread <= '0';
                   
             addrw <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_init_reg_addr, 32));
             dataw <= "00000000000000000000000000000000";
               if(valid_w = '1' and ready_w = '1') then
                             dma_state <= mm2s_start;
                             else
                             dma_state <= stop_dma;
                             
                          end if;
        
        when mm2s_start => 
        
               cntrlstart <= '1';
               cntrlread <= '0';
               
               addrw <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_mm2s_cntrl_reg_addr, 32));
                dataw <= "00000000000000000000000000000001";
                drcntr <= '1';
                if(valid_w = '1' and ready_w = '1') then
                      dma_state <= dram_sa;
                else
                       dma_state <= mm2s_start;
                 end if;
          
         when  dram_sa =>
         
                 cntrlstart <= '1';
                 cntrlread <= '0';
                 addrw <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_mm2s_dram_reg_addr, 32));
                
                  if(valid_w = '1' and ready_w = '1') then
                      dma_state <= mm2s_length;
                  else
                      dma_state <= dram_sa;
                  end if;
                
               
                 if(drcntr = '1') then
                     dataw <= MM2S_DMEM;
                     drcntr <= '0';
                  end if;
                  
                      if(dram_alert = '1') then
                      
                    if(scntr = 1) then
                      scntr <= 0;
                        dram_alert <= '0';
                        dataw <= MM2S_DMEM;
                        
                      elsif(dsignal = 1) then
                           dsignal <= 0;
                          asignal <= '1';
                         else 
                        Next_MM2S_Addr <= 255*4;
                         dsignal <= dsignal + 1;
                        
                       if(asignal = '1') then
                         MM2S_DMEM <= std_logic_vector(to_unsigned(Next_MM2S_Addr , 32) + unsigned(MM2S_DMEM));
                         asignal <= '0';
                        dsignal <= 0;
                        scntr <= scntr + 1 ; 
             
                        end if;
                        
                       end if;
                      end if; 
                  
                     
            when mm2s_length =>
            
                        cntrlstart <= '1';
                         cntrlread <= '0';
                         addrw <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_mm2s_lngth_reg_addr, 32));
                        dataw <= "00000000000000000000010000000000";
                        
                          if(valid_w = '1' and ready_w = '1') then
                              dma_state <= mm2s_read;
                          else
                              dma_state <= mm2s_length;
                          end if;
                             
             when mm2s_read =>
             
                  cntrlstart <= '0';
                    cntrlread <= '1';
                   
                     if(valid_r = '1' and ready_r = '1') then
                      addrR <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_mm2s_cntrl_reg_addr, 32));
                         dma_state <= mm2s_status;
                     else
                         dma_state <= mm2s_read;
                     end if;        
                                       
             when mm2s_status =>
             cntrlstart <= '0';
              cntrlread <= '1';
             
                  if(valid_r = '1' and ready_r = '1') then
                   
                          addrR <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_mm2s_status_reg_addr, 32)); 
                            dma_state <= mm2s_read;
                            
                    else
                    dma_state <= mm2s_status;
                    
                    if(stopcore = '1' and recon = '1') then
                           
                      dma_state <= mm2s_stop;
                      loop_signal <= '1';
                            
                        elsif(rsignal= '1') then
                             dma_state <= dram_sa;
                             dram_alert <= '1';
                                       
                            else
                           dma_state <= mm2s_status;
                                  end if;    
                          end if;

            when mm2s_stop =>
             cntrlstart <= '1';
           cntrlread <= '0';
            addrw <= std_logic_vector(unsigned(Base_DMA_Addr) + to_unsigned(dma_mm2s_cntrl_reg_addr, 32));
           dataw <= (others => '0');
                         
           if(valid_w = '1' and ready_w = '1') then  
             dma_state <= mm2s_stop;
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
        
       elsif(dataR = "00000000000000000001000000000010") then
          
               recon <= '1';
               if(recon = '1') then
               countrec <= countrec + 1;
               rsignal <= '1';
        
             if(countrec = 4) then
               stopcore <= '1';
               countrec <= 0;
             
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
      if( rst= '0') then
           start_writing <= '0';
       elsif(cntrlstart = '1') then
            if(start_writing = '0' and Bvalid = '0' and valid_w = '0') then
                 start_writing <= '1';
            else
              start_writing <= '0';
         end if;
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
         end if;
       end if;
         end process;              

   start_read <=  start_reading;











end Behavioral;
