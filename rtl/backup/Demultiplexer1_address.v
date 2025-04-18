/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name        : Demultiplexer1_address.v                                                                        //
//  Version          : 0.2                                                                                             //
//                                                                                                                     // 
//  parameters used  : ADDR_WIDTH    : N-2 bit of the address from the top module                                      //
//                     SELECT_WIDTH1 : Nth bit of the address from the top module                                      //
//                     SELECT_WIDTH2 : N-1 bit of the address from the top module                                      //
//                                                                                                                     // 
//  File Description : This demultiplexer module converts the input address of the top module to                       //
//                     its corresponding memory bank address which is in the range of that bank                        //
//                     depth.                                                                                          //  
//                                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module Demultiplexer1_address#( parameter ADDR_WIDTH    = 4,
                                parameter SELECT_WIDTH1 = 2,
                                parameter SELECT_WIDTH2 = 1
                              )(  input      [ADDR_WIDTH-3:0]                  i_address,
                                  input      [SELECT_WIDTH1-1:SELECT_WIDTH2-1] i_sel,
                                  output reg [ADDR_WIDTH-3:0]                  o_y0,o_y1,o_y2,o_y3
                               );

  always@(*)
  begin
    o_y0 = 0;
    o_y1 = 0;
    o_y2 = 0;
    o_y3 = 0;
    case(i_sel)
  		2'b00 : o_y0 = i_address;
  		2'b01 : o_y1 = i_address;
  		2'b10 : o_y2 = i_address;
  		2'b11 : o_y3 = i_address;
    endcase
  end


endmodule
