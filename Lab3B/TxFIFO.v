//***********************************************************
//	Author: 	Anisa Qazi
//	Developed on:	26-Oct-2016
//	Module:		Tx FIFO (To be used in SSP module)
//***********************************************************
module TxFIFO(	PCLK,
		reset_n,
		PSEL,
	     	PWRITE,
		PWDATA,
		Tx_logic_ready,
		Tx_logic_resp,
		SSPTXINTR,
		Tx_Data,
		Tx_fifo_valid);

input		PCLK,
		reset_n,
		PSEL,
		PWRITE,
		Tx_logic_ready,
		Tx_logic_resp;
input	[7:0]	PWDATA;
output 		SSPTXINTR,
		Tx_fifo_valid;
output	[7:0]	Tx_Data;

wire		PCLK,
		reset_n,
		PSEL,
		PWRITE,
		Tx_logic_ready,
		Tx_logic_resp,
		SSPTXINTR;

reg		fifo_read;

wire	[7:0]	PWDATA;

wire	[7:0]	Tx_Data;
wire		fifo_empty;

reg		Tx_fifo_valid;

reg [1:0] state;
reg [1:0] next_state;
parameter IDLE=2'd0, VALID=2'd1, RESP=2'd2;

fifo fifo_inst(	.clk		(PCLK),
		.reset_n	(reset_n),
		.data_in	(PWDATA),
		.write		(PWRITE & PSEL),
		.read		(fifo_read),	
		.fifo_full	(SSPTXINTR),
		.fifo_empty	(fifo_empty),
		.data_out	(Tx_Data)
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
		IDLE: 	
		     begin
			fifo_read=1;
			Tx_fifo_valid=1'b0;
			if(!fifo_empty)
				next_state=VALID;
			else
				next_state=IDLE;
		     end

		VALID:	
		      begin	
				fifo_read=0;
			if(Tx_logic_ready)
			begin
				Tx_fifo_valid=1'b1;
				next_state=RESP;
			end
			else
				next_state=VALID;
		      end
				
		RESP:	if(Tx_logic_resp)
			begin
				Tx_fifo_valid=1'b0;
				next_state=IDLE;
			end
			else
				next_state=RESP;
		
	endcase
end

endmodule	
