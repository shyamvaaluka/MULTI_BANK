/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name        : Decoder_enable_lines.v                                                                          //
//  Version          : 0.2                                                                                             //
//                                                                                                                     //
//  parameters used  : SELECT_ADDR1 : Value of the Nth bit of the address from the top module                          //
//                     SELECT_ADDR2 : Value of N-1 bit of the address from the top module                              //
//                                                                                                                     //
//  File Description : This is a 2x4 selection decoder module that selects a certain bank at a time                    //
//                     based on the first two bits of the input address given from the top module.                     //
//                                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module Decoder_enable_lines#( parameter SELECT_ADDR1 = 6,
                              parameter SELECT_ADDR2 = 5
                            )(  input      [SELECT_ADDR1-1:SELECT_ADDR2-1] i_I,
                                output reg [3:0]                           o_y
                             );

  always@(*)
  begin
  	case(i_I)
  		2'b00 : o_y = 4'b1000;
  		2'b01 : o_y = 4'b0100;
  		2'b10 : o_y = 4'b0010;
  		2'b11 : o_y = 4'b0001;
  		default : o_y = 4'b0000;
  	endcase
  end


endmodule
