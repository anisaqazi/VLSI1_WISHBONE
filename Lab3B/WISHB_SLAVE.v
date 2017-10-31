//***********************************************************
//	Author: 	Anisa Qazi
//	Developed on:	8-Nov-2016
//	Module:		WISHBONE SLAVE module
//***********************************************************
module WISHB_SLAVE(	clk_i,
			rst_i,
			adr_i,
			dat_o,
			dat_i,
			we_i,
			stb_i,
			ack_o,
			cyc_i,
			mem_adr_o,
			dataBus,
			mem_r_o,
			mem_w_o,
			ssp_sel_o,
			ssp_w_o
		);

input		clk_i,
		rst_i,
		we_i,
		stb_i,
		cyc_i;
input	[25:0]	adr_i;
input	[31:0]	dat_i;

inout	[31:0]	dataBus;

output	[31:0]	dat_o;
output	[25:0]	mem_adr_o;
output		ack_o,
		mem_r_o,
		mem_w_o,
		ssp_sel_o,
		ssp_w_o;

wire		clk_i,
		rst_i,
		we_i,
		stb_i,
		cyc_i;
wire	[25:0]	adr_i;
wire	[31:0]	dat_i;

wire	[31:0]	dataBus;
reg	[31:0]	dataBus_out_reg;

reg	[31:0]	dat_o;
reg	[31:0]	dat_o_reg;
reg	[25:0]	mem_adr_o;
reg		ack_o;
reg		mem_r_o,
		mem_w_o;
reg		ssp_sel_o,
		ssp_w_o;

reg	[25:0]	mem_adr_o_reg;
reg	[1:0]	cycle_cnt;

assign dataBus=(ssp_w_o & ssp_sel_o)?dataBus_out_reg:32'hZZZZZZZZ;

always @(posedge clk_i)
begin
	if(~rst_i)
	begin
		dataBus_out_reg	<=	32'h0;
		mem_adr_o	<=	26'h0;
		mem_r_o		<=	1'b0;
		mem_w_o		<=	1'b0;
		ssp_sel_o	<=	1'b0;
		ssp_w_o		<=	1'b0;
		cycle_cnt<=	2'b00;
	end
	else
	begin
		cycle_cnt<=	cycle_cnt + 1'b1;
		
		dataBus_out_reg<=dat_i;
		mem_adr_o<=adr_i;
		if(adr_i[25:16]==10'b0)
		begin
			mem_r_o<=1'b1;
			mem_w_o<=1'b0;
			ssp_sel_o<=1'b0;
			ssp_w_o<=1'b0;
		end	
		else if(adr_i[25:16]==10'h001)
		begin
			mem_r_o<=1'b0;
			mem_w_o<=1'b0;
			if(cycle_cnt==2'b10)
			begin
				ssp_sel_o<=1'b1;
				ssp_w_o<=!adr_i[0];	
			end
		end
		
		if(ssp_w_o)
			ssp_w_o	<=1'b0;
		if(ssp_sel_o)
			ssp_sel_o<=1'b0;	
	end
end

always @(posedge clk_i)
begin
	if(~rst_i)
	begin
		dat_o		<=32'h00000000;
		dat_o_reg	<=32'h00000000;
	end
	else
	begin
		dat_o_reg<=dataBus;
		if(cyc_i & !we_i)
		begin
			if(mem_r_o)
				dat_o<=dat_o_reg;	
			else
				dat_o<=dataBus;
		end
				
	end
end

always @(negedge clk_i)
begin
	ack_o<=stb_i;
end

endmodule	
