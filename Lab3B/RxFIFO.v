//***********************************************************
//	Author: 	Anisa Qazi
//	Developed on:	26-Oct-2016
//	Module:		Rx FIFO (To be used in SSP module)
//***********************************************************
module RxFIFO(	PCLK,
		reset_n,
		PSEL,
	     	PWRITE,
		PRDATA,
		Rx_fifo_ready,
		Rx_fifo_resp,
		SSPRXINTR,
		Rx_Data,
		Rx_logic_valid);

input		PCLK;
input		reset_n;
input		PSEL;
input		PWRITE;
input	[7:0]	Rx_Data;
input		Rx_logic_valid;

output 		SSPRXINTR;
output	[7:0]	PRDATA;
output		Rx_fifo_ready;
output		Rx_fifo_resp;
	

wire		PCLK,
		reset_n,
		PSEL,
		PWRITE,
		Rx_logic_valid,
 		SSPRXINTR;
reg		fifo_write;

wire	[7:0]	Rx_Data;
wire		fifo_empty;
wire	[7:0]	PRDATA;
reg		Rx_fifo_ready,
		Rx_fifo_resp;

reg [1:0] state;
reg [1:0] next_state;
parameter IDLE=2'd0, READY=2'd1, RESP=2'd2;

fifo fifo_inst(	.clk		(PCLK),
		.reset_n	(reset_n),
		.data_in	(Rx_Data),
		.write		(fifo_write),
		.read		(!PWRITE & PSEL),	
		.fifo_full	(SSPRXINTR),
		.fifo_empty	(fifo_empty),
		.data_out	(PRDATA)
	    );

always @(posedge PCLK or negedge reset_n)
begin
	if(~reset_n)
		state	<= 2'b0;
	else	
		state 	<= next_state;

end

always @(*)
begin	
	case(state)
		IDLE: 	if(!SSPRXINTR)//fifo_full
			begin 
				Rx_fifo_ready=1'b1;
				Rx_fifo_resp=1'b0;
				fifo_write= 1'b0;
				next_state=READY;
			end
			else
				next_state=IDLE;

		READY:	if(Rx_logic_valid)
				next_state=RESP;
			else
				next_state=READY;
				
		RESP:
		begin	
			Rx_fifo_ready	= 1'b0;
			Rx_fifo_resp	= 1'b1;
			fifo_write	= 1'b1;
			next_state	= IDLE;
		end
		
	endcase
end

endmodule	
