/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : sel_latency.sv                                                                                 //
//  Version           : 0.2                                                                                            //
//                                                                                                                     //
//  parameters used   : READ_LATENCYA : Read latency of port-a                                                         //
//                      READ_LATENCYB : Read latency of port-b                                                         //
//                      ADDR_WIDTH1   : Nth bit of address from the top module                                         //
//                      ADDR_WIDTH2   : N-1 bit of address from the top module                                         //                      
//                                                                                                                     //
//  File Description  : This is the select latency module that delays the select lines of the                          //
//                      data_routing 4x1 output mulitplexer by read_latency. Based on                                  //
//                      this latency the mux routes data from each bank onto single channel by read                    //  
//                      latency parameter.                                                                             //                                                                          
//                                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module sel_latency#(  parameter READ_LATENCYA = 2,
	                    parameter READ_LATENCYB = 2,
	                    parameter ADDR_WIDTH1   = 2,
	                    parameter ADDR_WIDTH2   = 1
                   )( input clka,clkb,
	                    input      [ADDR_WIDTH1-1:ADDR_WIDTH2-1] i_sel_in_a,i_sel_in_b,
	                    output reg [ADDR_WIDTH1-1:ADDR_WIDTH2-1] o_sel_out_a,o_sel_out_b
                    );

	reg [ADDR_WIDTH1-1:ADDR_WIDTH2-1] latched1;
  reg [ADDR_WIDTH1-1:ADDR_WIDTH2-1] latched2;

	reg [1:0] temp  [READ_LATENCYA-2:0];
	reg [1:0] temp1 [READ_LATENCYB-2:0];

  always@(posedge clka)
	begin
		latched1 <= i_sel_in_a;
		if(READ_LATENCYA == 1)
			o_sel_out_a <= i_sel_in_a;
		else if(READ_LATENCYA == 2)
			o_sel_out_a <= latched1;
		else
		begin
			temp [READ_LATENCYA - 2] <= latched1;
			for(int i = READ_LATENCYA-3 ; i >= 1 ; i = i - 1)
				temp[i] <= temp[i + 1];
			o_sel_out_a <= temp[1];
		end
	end


	always@(posedge clkb)
	begin
		latched2 <= i_sel_in_b;
		if(READ_LATENCYB == 1)
			o_sel_out_b <= i_sel_in_b;
		else if(READ_LATENCYB == 2)
			o_sel_out_b <= latched2;
		else
		begin
			temp1 [READ_LATENCYB-2] <= latched2;
			for(int i = READ_LATENCYB-3 ; i >= 1 ; i = i - 1)
				temp1[i] <= temp1[i + 1];
			o_sel_out_b  <= temp1[1];
		end
	end
endmodule
