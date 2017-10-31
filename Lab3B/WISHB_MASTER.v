//***********************************************************
//	Author: 	Anisa Qazi
//	Developed on:	8-Nov-2016
//	Module:		WISHBONE MASTER module
//***********************************************************
module WISHB_MASTER(	clk_i,
			rst_i,	
			mem_req,
			mwr_arm,
			memoryRead,
			memoryWrite,
			addressBus,
			dataBus,
			dat_i,
			ack_i,
			adr_o,
			dat_o,
			we_o,
			stb_o,
			cyc_o
		   );

input		clk_i,
		rst_i,	
		mem_req,
		mwr_arm,
		memoryRead,
		memoryWrite,
		ack_i;
input	[25:0]	addressBus;
input	[31:0]	dat_i;

inout	[31:0]	dataBus;


output	[25:0]	adr_o;
output	[31:0]	dat_o;
output		we_o,
		stb_o,
		cyc_o;

wire		clk_i,
		rst_i,	
		mem_req,
		mwr_arm,
		memoryRead,
		memoryWrite,
		ack_i;
wire	[25:0]	addressBus;
wire	[31:0]	dat_i;
reg	[31:0]	dat_i_reg;

wire	[31:0]	dataBus;

reg	[25:0]	adr_o;
reg	[31:0]	dat_o;
reg		we_o;
reg		cyc_o;
reg		read_data_cycle;

reg		stb_o;
reg	[1:0]	cycle_cnt;

assign	dataBus=(cyc_o	& (!memoryWrite))?dat_i:32'hZZZZZZZZ;

always @(posedge clk_i)
begin
	if(~rst_i)
	begin
		adr_o	<=	26'b0;
		dat_o	<=	32'b0;
		we_o	<=	1'b0;
		cyc_o	<=	1'b0;
		stb_o	<=	1'b0;
		cycle_cnt<=	2'b00;
		read_data_cycle	<= 1'b0;
	end
	else
	begin
		adr_o<=addressBus;
		dat_o	<=	dataBus;
		dat_i_reg <=	dat_i;
		
		cycle_cnt<=	cycle_cnt + 1'b1;
		
		if(memoryWrite)
			we_o	<=	1'b1;
		else
			we_o	<=	1'b0;

		if(ack_i)
			stb_o	<=	1'b0;
		else if((memoryRead|memoryWrite) && cycle_cnt ==2'b01)
			stb_o	<=	1'b1;
		if(cycle_cnt==2'b00)
			cyc_o	<=	memoryRead|memoryWrite|read_data_cycle;
	
		if(memoryRead|(read_data_cycle&&cycle_cnt!=0))
		begin
			read_data_cycle	<=	1'b1;
		end
		else
		begin
			read_data_cycle	<=1'b0;
		end

	end
end

endmodule
