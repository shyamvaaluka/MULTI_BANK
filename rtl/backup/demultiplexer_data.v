/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : demultiplexer_data.v                                                                           //
//  Version           : 0.2                                                                                            //
//                                                                                                                     //
//  parameters used   : DATA_WIDTH         : Width of the data                                                         //
//                      SELECT_DATA_WIDTH1 : Nth bit of address from the top module                                    //
//                      SELECT_DATA_WIDTH2 : N-1 bit of the address from the top module                                //
//                                                                                                                     //
//  File Description  : This demultiplexer data module routes data to the corresponding bank based                     //
//                      on the bank selected by the selection decoder module.                                          //
//                                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module demultiplexer_data#( parameter DATA_WIDTH         = 8,
                            parameter SELECT_DATA_WIDTH1 = 2,
                            parameter SELECT_DATA_WIDTH2 = 1
                          )(  input      [DATA_WIDTH-1:0]                            i_data,
                              input      [SELECT_DATA_WIDTH1-1:SELECT_DATA_WIDTH2-1] i_sel,
                              output reg [DATA_WIDTH-1:0]                            o_y0,o_y1,o_y2,o_y3
                           );
  
  always@(*)
  begin
    o_y0 = 0;
    o_y1 = 0;
    o_y2 = 0;
    o_y3 = 0;
    case(i_sel)
  		2'b00 : o_y0 = i_data;
  		2'b01 : o_y1 = i_data;
  		2'b10 : o_y2 = i_data;
  		2'b11 : o_y3 = i_data;
    endcase
  end


endmodule

