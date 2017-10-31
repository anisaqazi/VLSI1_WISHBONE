//***********************************************************
//	Author: 	Anisa Qazi
//	Developed on:	5-Nov-2016
//	Module:		Generic FIFO block (To be used in 
//                      RxFIFO & TxFIFO blocks)
//***********************************************************
module fifo(	clk,
		reset_n,
		data_in,
		write,
		read,	
		fifo_full,
		fifo_empty,
		data_out);

input		clk;
input		reset_n;
input	[7:0]	data_in;
input		write;
input		read;

output		fifo_full;
output		fifo_empty;
output	[7:0]	data_out;

wire	clk;
wire	reset_n;
wire	[7:0]data_in;
wire	write;
wire	read;

wire		fifo_full;
reg    	[7:0]	data_out;
reg 	[7:0]	fifo_data[3:0];
reg 	[1:0]	rd_ptr;
reg 	[1:0]	wr_ptr;
reg 	[2:0]	data_count;	 
wire		fifo_empty;

always @(posedge clk)
begin
	//anisa if(~reset_n)
	//anisa	fifo_data 	<= {{8'b0}};
	//anisa else
		if(write && !fifo_full)
			fifo_data[wr_ptr] <= data_in; 
		
end

always @(posedge clk)
begin
	if(~reset_n)
		wr_ptr		<= 1'b0;
	else	
		if(write && !fifo_full)
	 		wr_ptr <= wr_ptr +1;	
end


always @(posedge clk  or negedge reset_n)
begin
	if(~reset_n)
		data_out<=8'hFF;
	else	
	begin
		if(read && !fifo_empty)
			data_out<=fifo_data[rd_ptr];  //0th position in this implementation
		else
			data_out<=data_out;
	end
end
	
always @(posedge clk)
begin
	if(~reset_n)
		rd_ptr 		<= 1'b0;
	else	
		if(read && !fifo_empty)
	 		rd_ptr <= rd_ptr +1;	
end


always @(posedge clk)
begin
	if(~reset_n)
		data_count 	<= 2'b0;
	else	
		if((write && !fifo_full) && (read && !fifo_empty))
			data_count <= data_count;
		else if(write && !fifo_full)
	 		data_count <= data_count + 1;	
		else if(read && !fifo_empty)
			data_count <= data_count - 1;
		else
			data_count <= data_count;
	
end
assign fifo_full = data_count[2];
assign fifo_empty = !(|data_count);

endmodule
