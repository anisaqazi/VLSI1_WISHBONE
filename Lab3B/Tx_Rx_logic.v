//********************************************************************
//	Author: 	Anisa Qazi
//	Developed on:	26-Oct-2016
//	Module:		Tx/Rx logic block (To be used in SSP module)
//********************************************************************
module Tx_Rx_logic(	PCLK,
			reset_n,
			Tx_logic_ready,
			Tx_logic_resp,
			Tx_Data,
			Tx_fifo_valid,
			Rx_fifo_ready,
			Rx_fifo_resp,
			Rx_Data,
			Rx_logic_valid,
			SSPOE_B,
			SSPTXD,
			SSPFSSOUT,
			SSPCLKOUT,
			SSPCLKIN,
			SSPFSSIN,
			SSPRXD);


input		PCLK,
		reset_n,
		Tx_fifo_valid,
		Rx_fifo_ready,
		Rx_fifo_resp,
		SSPCLKIN,
		SSPFSSIN,
		SSPRXD;

input	[7:0]	Tx_Data;

output		Tx_logic_ready,
		Tx_logic_resp,
		Rx_logic_valid,
		SSPOE_B,
		SSPTXD,
		SSPFSSOUT,
		SSPCLKOUT;

output	[7:0]	Rx_Data;

wire		PCLK,
		reset_n,
		Tx_fifo_valid,
		Rx_fifo_ready,
		Rx_fifo_resp,
		SSPCLKIN,
		SSPFSSIN,
		SSPRXD;

wire	[7:0]	Tx_Data;
wire		SSPTXD;
reg		Rx_logic_valid;
wire		capture_rx_data;
reg		capture_rx_data_delay;

reg		Tx_fifo_valid_sync;
reg		Tx_logic_ready,
		Tx_logic_resp,
		SSPOE_B,
		SSPFSSOUT_reg,
		SSPCLKOUT;
wire		SSPFSSOUT;

wire	[7:0]	Rx_Data;

reg 	[7:0]	tx_data_in_reg;
reg 	[7:0]	tx_data_in_reg_sync;
reg 	[2:0]	tx_count;

reg 	[7:0]	rx_data_in_reg;
reg 	[7:0]	rx_data_in_reg_captured;
reg 	[2:0]	rx_count;

reg [1:0] tx_state;
reg [1:0] tx_next_state;
parameter TX_IDLE=2'd0, TX_READY=2'd1, TX_RESP=2'd2, TX_WAIT=2'd3;

reg [1:0] tx_ser_state;
reg [1:0] tx_ser_next_state;
parameter TX_SER_IDLE=2'd0, TX_SER_TRANSFER=2'd1, TX_SER_LAST_TRANSFER=2'd2;

reg [1:0] rx_state;
reg [1:0] rx_next_state;
parameter RX_IDLE=2'd0, RX_VALID=2'd1, RX_RESP=2'd2;

reg [1:0] rx_ser_state;
reg [1:0] rx_ser_next_state;
parameter RX_SER_IDLE=2'd0, RX_SER_RECEIVE=2'd1, RX_SER_CAPTURE=2'd2, RX_SER_LAST_BIT=2'd3;


always @(posedge PCLK)
begin
	if(~reset_n)
		SSPCLKOUT	<= 1'b1;
	else
		SSPCLKOUT	<= ~SSPCLKOUT;
				
end


always @(posedge PCLK)
begin
	if(~reset_n)
	begin
		tx_state	<= 2'b0;
	end
	else	
		tx_state 	<= tx_next_state;
end


always @(*)  
begin	
	case(tx_state)
		TX_IDLE:
			 begin
				Tx_logic_resp	= 1'b0;
				Tx_logic_ready	= 1'b1;
				tx_next_state	= TX_READY;
			end

		TX_READY:if(Tx_fifo_valid)
			 begin
				tx_data_in_reg	= Tx_Data;
				tx_next_state	= TX_RESP;
			 end
		 	 else
			 begin
				tx_next_state= TX_READY;
			 end
				
		TX_RESP:
			begin	
				Tx_logic_ready	= 1'b0;
				Tx_logic_resp	= 1'b1;
				tx_next_state= TX_WAIT;
			end
		TX_WAIT:
			begin
				Tx_logic_resp	= 1'b0;
				if(tx_count==3'b110)  //check this count
					tx_next_state= TX_IDLE;
				else
					tx_next_state= TX_WAIT;
			end
		
	endcase
end

always @(posedge SSPCLKOUT)
begin
	if(~reset_n)
		Tx_fifo_valid_sync<='d0; //initial
	else
		Tx_fifo_valid_sync<=Tx_fifo_valid;
end

always @(negedge SSPCLKOUT)
begin
	if(~reset_n)
		SSPOE_B		= 1'b1;
	else
	begin
		if(SSPFSSOUT)
			SSPOE_B		= 1'b0;
		if(rx_count=='d0 && !SSPFSSOUT_reg)
			SSPOE_B		= 1'b1;
	end
	
end

always @(posedge SSPCLKOUT)
begin
	if(~reset_n)
		SSPFSSOUT_reg<='d0;
	else
		SSPFSSOUT_reg<=SSPFSSOUT;
end

always @(posedge SSPCLKOUT)
begin
	if(~reset_n)
	begin
		tx_ser_state	<= 2'b10;  //initial
	end
	else	
		tx_ser_state 	<= tx_ser_next_state;
end
assign SSPFSSOUT = Tx_fifo_valid_sync;
always @(posedge SSPCLKOUT)
begin
	if(~reset_n)
	begin
		tx_count	<= 'd0;  //initial
		tx_data_in_reg_sync	<='d0;  //initial;
	end
	else
	begin
		if(SSPFSSOUT)
			tx_data_in_reg_sync	<= tx_data_in_reg;	
		else if(tx_ser_next_state==TX_SER_TRANSFER)
		begin
			tx_count 	<= tx_count +1;
			tx_data_in_reg_sync	<= {tx_data_in_reg_sync[6:0],1'b0};
		end
		else if(tx_ser_next_state==TX_SER_LAST_TRANSFER)
		begin
			tx_count	<= 'd0;
			tx_data_in_reg_sync	<= {tx_data_in_reg_sync[6:0],1'b0};
		end
		else if(tx_ser_next_state==TX_SER_IDLE)
		begin
			tx_count	<= 'd0;
		end
	end
		
end

always @(*)  
begin	
	case(tx_ser_state)
		TX_SER_IDLE:	if(Tx_fifo_valid_sync)
				begin	
					tx_ser_next_state	= TX_SER_TRANSFER;
				end
				else
					tx_ser_next_state	= TX_SER_IDLE;
			
		TX_SER_TRANSFER:if(tx_count==3'b110)  //check count
					tx_ser_next_state	= TX_SER_LAST_TRANSFER;
				else
				begin
					tx_ser_next_state	= TX_SER_TRANSFER;
				end
	
		TX_SER_LAST_TRANSFER:
				if(Tx_fifo_valid_sync)
				begin	
					tx_ser_next_state	= TX_SER_TRANSFER;
				end
				else
					tx_ser_next_state	= TX_SER_LAST_TRANSFER;
			
	endcase
end


assign SSPTXD	= tx_data_in_reg_sync[7];


always @(posedge SSPCLKIN)
begin
	if(~reset_n)
		rx_ser_state	<= 2'b0;  //initial
	else	
		rx_ser_state 	<= rx_ser_next_state;
end

always @(posedge SSPCLKIN)
begin
	if(~reset_n)
	begin
		rx_data_in_reg 	<= 'd0;  //initial
		rx_count	<= 'd7;  //initial
	end
	else
	begin
		if(rx_ser_next_state==RX_SER_IDLE)
		begin
			rx_data_in_reg 	<= 'd0;
			rx_count	<= 'd7;
			rx_data_in_reg	<={rx_data_in_reg[6:0],SSPRXD};
		end
		else if(rx_ser_next_state==RX_SER_RECEIVE)
		begin
			rx_count 	<= rx_count+1;
			rx_data_in_reg	<={rx_data_in_reg[6:0],SSPRXD};
		end
		else if(rx_ser_next_state==RX_SER_CAPTURE)
		begin
			rx_count 	<= rx_count+1;
			rx_data_in_reg	<={rx_data_in_reg[6:0],SSPRXD};
		end
		else if(rx_ser_next_state==RX_SER_LAST_BIT)
		begin
			rx_count 	<= rx_count+1;
			rx_data_in_reg	<={rx_data_in_reg[6:0],SSPRXD};
		end
	end	
end

always @(*)
begin
	case(rx_ser_state)
		RX_SER_IDLE:	if(SSPFSSIN)
					rx_ser_next_state=RX_SER_RECEIVE;
				else
					rx_ser_next_state=RX_SER_IDLE;	
		RX_SER_RECEIVE:	if(rx_count==3'b110)
					rx_ser_next_state=RX_SER_CAPTURE;
				else
					rx_ser_next_state=RX_SER_RECEIVE;
	
		RX_SER_CAPTURE:
					if(SSPFSSIN)
						rx_ser_next_state=RX_SER_RECEIVE;
					else
						rx_ser_next_state=RX_SER_LAST_BIT;
		RX_SER_LAST_BIT:
				begin
					rx_ser_next_state=RX_SER_IDLE;
				end
				
	endcase
end

assign capture_rx_data = ((rx_ser_state=='d2)&&((rx_ser_next_state=='d1)||(rx_ser_next_state=='d3)));

always @(posedge SSPCLKIN)
begin
	if(~reset_n)
		capture_rx_data_delay<=0;  //initial
	else
		capture_rx_data_delay<=capture_rx_data;
	
end

always @(posedge capture_rx_data_delay)
begin
	if(~reset_n)
		rx_data_in_reg_captured <='d0; //initial
	else
		rx_data_in_reg_captured<=rx_data_in_reg;		
end

always @(posedge PCLK)
begin
	if(~reset_n)
	begin
		rx_state	<= 2'b0;
	end	
	else	
		rx_state 	<= rx_next_state;
end


always @(*)
begin	
	case(rx_state)
		RX_IDLE: if(capture_rx_data_delay)
			begin 
				rx_next_state=RX_VALID;
			end
			else
				rx_next_state=RX_IDLE;

		RX_VALID:
			 begin
				Rx_logic_valid=1'b1;
			
				if(Rx_fifo_ready)
			 	begin
					rx_next_state=RX_RESP;
				end
			 	else
					rx_next_state=RX_VALID;
			 end
				
		RX_RESP:	if(Rx_fifo_resp)
			begin
				Rx_logic_valid=1'b0;
				rx_next_state=RX_IDLE;
			end
			else
				rx_next_state=RX_RESP;
		
	endcase
end

assign Rx_Data = rx_data_in_reg_captured; 


endmodule
