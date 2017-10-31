//***********************************************************
//	Author: 	Anisa Qazi
//	Developed on:	5-Nov-2016
//	Module:		Top SSP module
//***********************************************************
module SSP(	PCLK,
		CLEAR_B,
		PSEL,
		PWRITE,
		PWDATA,
		PRDATA,
		SSPOE_B,
		SSPTXD,
		SSPFSSOUT,
		SSPCLKOUT,
		SSPFSSIN,
		SSPCLKIN,
		SSPRXD,
		SSPTXINTR,
		SSPRXINTR);

input		PCLK,
		CLEAR_B,
		PSEL,
		PWRITE,
		SSPFSSIN,
		SSPCLKIN,
		SSPRXD;
input	[7:0]	PWDATA;

output	[7:0]	PRDATA;
output		SSPOE_B,
		SSPTXD,
		SSPFSSOUT,
		SSPCLKOUT,
		SSPTXINTR,
		SSPRXINTR;
	
wire	[7:0]	PWDATA;
wire		PCLK,
		CLEAR_B,
		PSEL,
		PWRITE,
		SSPFSSIN,
		SSPCLKIN,
		SSPRXD;

wire	[7:0]	PRDATA;
wire		SSPOE_B,
		SSPTXD,
		SSPFSSOUT,
		SSPCLKOUT,
		SSPTXINTR,
		SSPRXINTR;

wire	[7:0]	Tx_Data;
wire	[7:0]	Rx_Data;
wire		Rx_fifo_ready;
wire		Rx_fifo_resp;
wire		Rx_logic_valid;
wire		Tx_logic_ready;
wire		Tx_logic_resp;
wire		Tx_fifo_valid;
	
RxFIFO  RxFIFO_inst(	.PCLK		(PCLK),
			.reset_n	(CLEAR_B),
			.PSEL		(PSEL),
	     		.PWRITE		(PWRITE),
			.PRDATA		(PRDATA),
			.Rx_fifo_ready	(Rx_fifo_ready),
			.Rx_fifo_resp	(Rx_fifo_resp),
			.SSPRXINTR	(SSPRXINTR),
			.Rx_Data	(Rx_Data),
			.Rx_logic_valid	(Rx_logic_valid)
		);

TxFIFO TxFIFO_inst(	.PCLK		(PCLK),
			.reset_n		(CLEAR_B),
			.PSEL		(PSEL),
	     		.PWRITE		(PWRITE),
			.PWDATA		(PWDATA),
			.Tx_logic_ready	(Tx_logic_ready),
			.Tx_logic_resp	(Tx_logic_resp),
			.SSPTXINTR	(SSPTXINTR),
			.Tx_Data	(Tx_Data),
			.Tx_fifo_valid	(Tx_fifo_valid)
		);

Tx_Rx_logic Tx_Rx_logic_inst(	.PCLK		(PCLK),
				.reset_n	(CLEAR_B),
				.Tx_logic_ready	(Tx_logic_ready),
				.Tx_logic_resp	(Tx_logic_resp),
				.Tx_Data	(Tx_Data),
				.Tx_fifo_valid	(Tx_fifo_valid),
				.Rx_fifo_ready	(Rx_fifo_ready),
				.Rx_fifo_resp	(Rx_fifo_resp),
				.Rx_Data	(Rx_Data),
				.Rx_logic_valid	(Rx_logic_valid),
				.SSPOE_B	(SSPOE_B),
				.SSPTXD		(SSPTXD),
				.SSPFSSOUT	(SSPFSSOUT),
				.SSPCLKOUT	(SSPCLKOUT),
				.SSPCLKIN	(SSPCLKIN),
				.SSPFSSIN	(SSPFSSIN),
				.SSPRXD		(SSPRXD)
			);


endmodule
