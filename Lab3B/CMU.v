//***********************************************************
//	Author: 	Anisa Qazi
//	Developed on:	8-Nov-2016
//	Module:		Clock management module
//***********************************************************
module CMU(	clk_i,
		clear_i,
		ssp_intr_i,
		clk_o,
		clear_o,
		phi1,
		phi2);


input		clk_i,
		clear_i;
input	[1:0]	ssp_intr_i;

output		clk_o,
		clear_o,
		phi1,
		phi2;

wire		clk_i,
		clear_i;
wire	[1:0]	ssp_intr_i;

wire		clk_o,
		clear_o;
wire		phi1,
		phi2;
reg		phi1_int,
		phi2_int;
reg	[1:0]	cnt;

assign	clk_o=clk_i;
assign 	clear_o=clear_i;

always @(posedge clk_i)
begin
	if(~clear_i)
	begin
		cnt<=2'b00;
		phi1_int<=1'b0;	
		phi2_int<=1'b0;	
	end
	else
	begin
		cnt<=cnt+1;
		if(cnt==2'b00)
			phi1_int<=1'b1;
		else
			phi1_int<=1'b0;

		if(cnt==2'b10)
			phi2_int<=1'b1;
		else
			phi2_int<=1'b0;
	
	end
end

assign	phi1 = phi1_int & !ssp_intr_i[1];
assign	phi2 = phi2_int & !ssp_intr_i[1];


endmodule

