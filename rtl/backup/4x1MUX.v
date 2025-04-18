/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name        : 4x1MUX.v                                                                                        //
//  Version          : 0.2                                                                                             //
//                                                                                                                     //
//  parameters used  : DATA_WIDTH : Width of the data being routed                                                     //
//                     ADDR_1     : Value of the Nth bit of the top module address                                     //
//                     ADDR_2     : Value of N-1 bit of the top module address                                         //
//                                                                                                                     //
//  File Description : This multiplexer module routes all the output data from each bank(4 banks in                    //
//                     total) onto one single output channel. This is a latched mux where the                          //
//                     select lines control the data routing based on read latency parameter.                          //  
//                                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module MUX_4x1#(  parameter DATA_WIDTH  = 8,
                	parameter ADDR_1 = 5,
	                parameter ADDR_2 = 4
               )( input      [DATA_WIDTH-1:0]    i_i0,i_i1,i_i2,i_i3,
                	input      [ADDR_1-1:ADDR_2-1] i_sel,
	                output reg [DATA_WIDTH-1:0]    o_Y
                );

	always@(*)
	begin
		o_Y = 0;
		case(i_sel)
			2'b00 : o_Y = i_i0;
			2'b01 : o_Y = i_i1;
			2'b10 : o_Y = i_i2;
			2'b11 : o_Y = i_i3;
		endcase
	end

endmodule
