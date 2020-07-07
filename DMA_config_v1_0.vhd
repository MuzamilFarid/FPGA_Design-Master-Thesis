library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DMA_config_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Master Bus Interface M_AXI
		C_M_AXI_START_DATA_VALUE	: std_logic_vector	:= x"AA000000";
		C_M_AXI_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"41E00000";
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 32;
		C_M_AXI_TRANSACTIONS_NUM	: integer	:= 4
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Master Bus Interface M_AXI
		m_axi_init_axi_txn	: in std_logic;
		m_axi_error	: out std_logic;
		m_axi_txn_done	: out std_logic;
		m_axi_aclk	: in std_logic;
		m_axi_aresetn	: in std_logic;
		m_axi_awaddr	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		m_axi_awprot	: out std_logic_vector(2 downto 0);
		m_axi_awvalid	: out std_logic;
		m_axi_awready	: in std_logic;
		m_axi_wdata	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		m_axi_wstrb	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		m_axi_wvalid	: out std_logic;
		m_axi_wready	: in std_logic;
		m_axi_bresp	: in std_logic_vector(1 downto 0);
		m_axi_bvalid	: in std_logic;
		m_axi_bready	: out std_logic;
		m_axi_araddr	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		m_axi_arprot	: out std_logic_vector(2 downto 0);
		m_axi_arvalid	: out std_logic;
		m_axi_arready	: in std_logic;
		m_axi_rdata	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		m_axi_rresp	: in std_logic_vector(1 downto 0);
		m_axi_rvalid	: in std_logic;
		m_axi_rready	: out std_logic;
		start_trans     : in std_logic
	);
end DMA_config_v1_0;

architecture arch_imp of DMA_config_v1_0 is

	-- component declaration
	component DMA_config_v1_0_M_AXI is
		generic (
		C_M_START_DATA_VALUE	: std_logic_vector	:= x"AA000000";
		C_M_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"41E00000";
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 32;
		C_M_TRANSACTIONS_NUM	: integer	:= 4
		);
		port (
		INIT_AXI_TXN	: in std_logic;
		ERROR	: out std_logic;
		TXN_DONE	: out std_logic;
		M_AXI_ACLK	: in std_logic;
		M_AXI_ARESETN	: in std_logic;
		M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		M_AXI_AWVALID	: out std_logic;
		M_AXI_AWREADY	: in std_logic;
		M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		M_AXI_WVALID	: out std_logic;
		M_AXI_WREADY	: in std_logic;
		M_AXI_BRESP	: in std_logic_vector(1 downto 0);
		M_AXI_BVALID	: in std_logic;
		M_AXI_BREADY	: out std_logic;
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		M_AXI_ARVALID	: out std_logic;
		M_AXI_ARREADY	: in std_logic;
		M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_RRESP	: in std_logic_vector(1 downto 0);
		M_AXI_RVALID	: in std_logic;
		M_AXI_RREADY	: out std_logic;
		start_trans : in std_logic
		);
	end component DMA_config_v1_0_M_AXI;

begin

-- Instantiation of Axi Bus Interface M_AXI
DMA_config_v1_0_M_AXI_inst : DMA_config_v1_0_M_AXI
	generic map (
		C_M_START_DATA_VALUE	=> C_M_AXI_START_DATA_VALUE,
		C_M_TARGET_SLAVE_BASE_ADDR	=> C_M_AXI_TARGET_SLAVE_BASE_ADDR,
		C_M_AXI_ADDR_WIDTH	=> C_M_AXI_ADDR_WIDTH,
		C_M_AXI_DATA_WIDTH	=> C_M_AXI_DATA_WIDTH,
		C_M_TRANSACTIONS_NUM	=> C_M_AXI_TRANSACTIONS_NUM
	)
	port map (
		INIT_AXI_TXN	=> m_axi_init_axi_txn,
		ERROR	=> m_axi_error,
		TXN_DONE	=> m_axi_txn_done,
		M_AXI_ACLK	=> m_axi_aclk,
		M_AXI_ARESETN	=> m_axi_aresetn,
		M_AXI_AWADDR	=> m_axi_awaddr,
		M_AXI_AWPROT	=> m_axi_awprot,
		M_AXI_AWVALID	=> m_axi_awvalid,
		M_AXI_AWREADY	=> m_axi_awready,
		M_AXI_WDATA	=> m_axi_wdata,
		M_AXI_WSTRB	=> m_axi_wstrb,
		M_AXI_WVALID	=> m_axi_wvalid,
		M_AXI_WREADY	=> m_axi_wready,
		M_AXI_BRESP	=> m_axi_bresp,
		M_AXI_BVALID	=> m_axi_bvalid,
		M_AXI_BREADY	=> m_axi_bready,
		M_AXI_ARADDR	=> m_axi_araddr,
		M_AXI_ARPROT	=> m_axi_arprot,
		M_AXI_ARVALID	=> m_axi_arvalid,
		M_AXI_ARREADY	=> m_axi_arready,
		M_AXI_RDATA	=> m_axi_rdata,
		M_AXI_RRESP	=> m_axi_rresp,
		M_AXI_RVALID	=> m_axi_rvalid,
		M_AXI_RREADY	=> m_axi_rready,
		start_trans => start_trans
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
