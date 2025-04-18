/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : latency_module.sv                                                                              //
//  Version           : 0.2                                                                                            //
//                                                                                                                     //
//  parameters used   : DATA_WIDTH  : Width of the data                                                                //
//                      ADDR_WIDTH  : Width of the address                                                             //
//                      MEM_DEPTH   : Depth of the DP RAM                                                              //
//                      MEM_WIDTH   : Width of each location in DP RAM                                                 //
//                      WR_LATENCYA : Write latency of port-a                                                          //
//                      RD_LATENCYA : Read latency of port-a                                                           //
//                      WR_LATENCYB : Write latency of port-b                                                          //
//                      RD_LATENCYB : Read latency of port-b                                                           //
//                                                                                                                     //
//  File Description  : This module applies latency to the signals. All the write operation related                    //
//                      signals are delayed by write latency parameter and the read related signals                    //
//                      are delayed with read latency parameter. The write delayed signals are then                    //  
//                      given to the normal DP RAM. And the output of the DP RAM is inturn given to                    //                                                
//                      latency module which is then delayed by read latency parameter.                                //                                                                           
//                                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module latency#(  parameter DATA_WIDTH  = 8,
                  parameter ADDR_WIDTH  = $clog2(MEM_DEPTH),
                  parameter MEM_DEPTH   = 16,
                  parameter MEM_WIDTH   = 2 * DATA_WIDTH,
                  parameter WR_LATENCYA = 1,
                  parameter RD_LATENCYA = 1,
                  parameter WR_LATENCYB = 1,
                  parameter RD_LATENCYB = 1
               )( input                       i_wea,i_web,clka,clkb,i_ena_wr_in,i_enb_wr_in,
                  input      [DATA_WIDTH-1:0] i_wr_dina,i_wr_dinb,
                  input      [ADDR_WIDTH-1:0] i_addra,i_addrb,
                  input      [DATA_WIDTH-1:0] i_rd_dina,i_rd_dinb,
                  
                  output reg [DATA_WIDTH-1:0] o_wr_dina_out,o_wr_dinb_out,
                  output reg [DATA_WIDTH-1:0] o_rd_dina_out,o_rd_dinb_out,
                  output reg [ADDR_WIDTH-1:0] o_addra_out,o_addrb_out,
                  output reg                  o_wea_out,o_web_out,o_ena_wr_out,o_enb_wr_out              

                );
  
  reg ena_wr     [WR_LATENCYA:0];
  reg enb_wr     [WR_LATENCYB:0];
  reg wea_wr_pos [WR_LATENCYA:0];
  reg web_wr_pos [WR_LATENCYB:0];

  reg [DATA_WIDTH-1:0] wr_dina_temp  [WR_LATENCYA:0];
  reg [DATA_WIDTH-1:0] wr_dinb_temp  [WR_LATENCYB:0];
  reg [ADDR_WIDTH-1:0] wr_addra_temp [WR_LATENCYA:0];
  reg [ADDR_WIDTH-1:0] wr_addrb_temp [WR_LATENCYB:0];

  reg [DATA_WIDTH-1:0] rd_dina_temp  [RD_LATENCYA:0];
  reg [DATA_WIDTH-1:0] rd_dinb_temp  [RD_LATENCYB:0];

  
`ifdef  LATENCYA_1 
  always@(*)
  begin
    if(WR_LATENCYA == 1)
    begin
      o_wea_out      =   i_wea;
      o_ena_wr_out   =   i_ena_wr_in;
    end
    else
    begin
      o_wea_out      =   o_wea_out;
      o_ena_wr_out   =   o_ena_wr_out;
    end
  end

  always@(*)
  begin
    if(WR_LATENCYA == 1)
    begin
      o_wr_dina_out  =   i_wr_dina;
      o_addra_out    =   i_addra;
    end
    else
    begin
      o_wr_dina_out  =   o_wr_dina_out;
      o_addra_out    =   i_addra;
    end
  end

  `else
  always@(posedge clka)
  begin
    if(WR_LATENCYA == 2)
    begin
      o_wea_out    <=   i_wea;
      o_ena_wr_out <=   i_ena_wr_in;
    end
    
    else
    begin
      ena_wr[0]       <=   i_ena_wr_in;
      wea_wr_pos[0]   <=   i_wea;;
      for(int i = 1 ; i <= WR_LATENCYA-3 ; i++)
      begin
        wea_wr_pos[i] <= wea_wr_pos[i-1];
        ena_wr[i]     <= ena_wr[i-1];
      end
      o_ena_wr_out  <= ena_wr [WR_LATENCYA-3];
      o_wea_out     <= wea_wr_pos [WR_LATENCYA-3];
    end
       
  end


  
  always@(posedge clka)
  begin
    if(WR_LATENCYA == 2)
    begin
      o_wr_dina_out <= i_wr_dina;
      o_addra_out   <= i_addra;
    end
    else
    begin
      wr_dina_temp[0]  <= i_wr_dina;
      wr_addra_temp[0] <= i_addra;
     for(int j = 1 ; j <= WR_LATENCYA-3 ; j++)
     begin
       wr_addra_temp[j] <= wr_addra_temp[j-1];
       wr_dina_temp[j]  <= wr_dina_temp[j-1];
     end
     o_wr_dina_out <= wr_dina_temp [WR_LATENCYA-3];
     o_addra_out   <= wr_addra_temp [WR_LATENCYA-3];
    end
  end
`endif

`ifdef RD_LATENCYA_1
  always@(*)
  begin
    if(RD_LATENCYA == 1)
      o_rd_dina_out = i_rd_dina;
    else
      o_rd_dina_out = o_rd_dina_out;
  end

`else
  
  always@(posedge clka)
  begin
    if(RD_LATENCYA == 2)
    begin
      o_rd_dina_out <= i_rd_dina;
    end
    else
    begin
      rd_dina_temp[0] <= i_rd_dina;
      for(int u = 1 ; u <= RD_LATENCYA-3 ; u++)
      begin
         rd_dina_temp[u] <= rd_dina_temp[u-1];
      end
      o_rd_dina_out <= rd_dina_temp[RD_LATENCYA-3];
    end
  end
`endif



 `ifdef LATENCYB_1
  always@(*)
  begin
    if(WR_LATENCYB == 1)
    begin
      o_web_out    = i_web;
      o_enb_wr_out = i_enb_wr_in;
    end
    else
    begin
      o_web_out    = o_web_out;
      o_enb_wr_out = o_enb_wr_out;
    end
  end
  
  always@(*)
  begin
    if(WR_LATENCYB == 1)
    begin
      o_wr_dinb_out = i_wr_dinb;
      o_addrb_out   = i_addrb;
    end
    else
    begin
      o_wr_dinb_out = o_wr_dinb_out;
      o_addrb_out   = o_addrb_out;
    end
  end
  
  
 `else 
  always@(posedge clkb)
  begin
    if(WR_LATENCYB == 2)
    begin
      o_web_out    <= i_web;
      o_enb_wr_out <= i_enb_wr_in;
    end
    else
    begin
      enb_wr[0]     <= i_enb_wr_in;
      web_wr_pos[0] <= i_web;
      for(int k = 1 ; k <= WR_LATENCYB-3 ; k++)
      begin
          web_wr_pos[k] <= web_wr_pos[k-1];
          enb_wr[k]     <= enb_wr[k-1];
      end
      o_enb_wr_out <= enb_wr[WR_LATENCYB-3];
      o_web_out    <= web_wr_pos[WR_LATENCYB-3];
    end
  end


  
  always@(posedge clkb)
  begin
    if(WR_LATENCYB == 2)
    begin
      o_wr_dinb_out <= i_wr_dinb;
      o_addrb_out   <= i_addrb;
    end
    else
    begin
      wr_dinb_temp[0]  <= i_wr_dinb;
      wr_addrb_temp[0] <= i_addrb;
      for(int l = 1 ; l <= WR_LATENCYB-3 ; l++)
      begin
        wr_addrb_temp[l] <= wr_addrb_temp[l-1];
        wr_dinb_temp[l]  <= wr_dinb_temp[l-1];
      end
      o_wr_dinb_out <= wr_dinb_temp[WR_LATENCYB-3];
      o_addrb_out   <= wr_addrb_temp[WR_LATENCYB-3];
    end
  end

  `endif


`ifdef RD_LATENCYB_1
  always@(*)
  begin
    if(RD_LATENCYB == 1)
      o_rd_dinb_out = i_rd_dinb;
    else
      o_rd_dinb_out = o_rd_dinb_out;
  end
`else
  
  always@(posedge clkb)
  begin
    if(RD_LATENCYB == 2)
      o_rd_dinb_out <= i_rd_dinb;
    else
    begin
      rd_dinb_temp[0] <= i_rd_dinb;
      for(int p = 1 ; p <= RD_LATENCYB-3 ; p++)
      begin
         rd_dinb_temp[p] <= rd_dinb_temp[p-1];
      end
      o_rd_dinb_out <= rd_dinb_temp[RD_LATENCYB-3];
    end
  end
`endif
endmodule
