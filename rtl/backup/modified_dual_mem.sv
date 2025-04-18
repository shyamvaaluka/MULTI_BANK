/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : modified_dual_mem.sv                                                                           //
//  Version           : 0.2                                                                                            //
//                                                                                                                     //
//  parmeters used    : DATA_WIDTH  : Width of the data                                                                //
//                      ADDR_WIDTH  : Width of the address                                                             //
//                      MEM_DEPTH   : Depth of the DP RAM                                                              //
//                      MEM_WIDTH   : Width of each location in DP RAM                                                 //
//                      WR_LATENCYA : Write latency of port-a                                                          //
//                      RD_LATENCYA : Read latency of port-a                                                           //
//                      WR_LATENCYB : Write latency of port-b                                                          //
//                      RD_LATENCYB : Read latency of port-b                                                           //
//                                                                                                                     //
//  File Description  : This module is a normal Dual-Port RAM that takes the delayed signals from the latency          //
//                      module and performs read and write operations in its internal memory                           //
//                      register.                                                                                      //  
//                                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module modified_dual_mem#( parameter DATA_WIDTH  = 8,
                           parameter ADDR_WIDTH  = $clog2(MEM_DEPTH),
                           parameter MEM_DEPTH   = 16,
                           parameter MEM_WIDTH   = 2 * DATA_WIDTH,
                           parameter WR_LATENCYA = 1,
                           parameter RD_LATENCYA = 1,
                           parameter WR_LATENCYB = 1,
                           parameter RD_LATENCYB = 1)( input                       clka,clkb,i_ena_wr,i_enb_wr,i_ena_rd,i_enb_rd,i_we_a,i_rd_a,i_we_b,i_rd_b,
                                                       input      [DATA_WIDTH-1:0] i_din_a,i_din_b,
                                                       input      [ADDR_WIDTH-1:0] i_addra_wr,i_addrb_wr,i_addra_rd,i_addrb_rd,
                                                       output reg [DATA_WIDTH-1:0] o_douta,o_doutb
                                                     );
  

  reg [MEM_WIDTH-1:0] mem [MEM_DEPTH-1:0];

  always@(posedge clka)
  begin
    if(i_ena_wr && i_we_a)
       mem[i_addra_wr] <= i_din_a;
  end

  always@(posedge clka)
  begin
    if(i_ena_rd && (~i_rd_a))
      o_douta <= mem[i_addra_rd];
  end

  always@(posedge clkb)
  begin
    if(i_enb_wr && i_we_b)
       mem[i_addrb_wr] <= i_din_b;
  end


  always@(posedge clkb)
  begin
    if(i_enb_rd && (~i_rd_b))
      o_doutb <= mem[i_addrb_rd];
  end

endmodule
