/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : MEMORY_CONTROL_TOP.sv                                                                          // 
//  Version           : 0.2                                                                                            //
//                                                                                                                     //
//  parameters used   : DATA_A       : Width of the data form port-a                                                   //
//                      DATA_B       : Width of the data from port-b                                                   //
//                      ADDR_A       : Width of the address from port-a                                                //
//                      ADDR_B       : Width of the address from port-b                                                //
//                      MEM_DEPTH    : Depth of the internal memory in the DP RAM                                      //
//                      MEM_WIDTH    : Width of each location in DP RAM                                                //
//                      ADDR_WIDTH1  : Nth bit of the top module address                                               //
//                      ADDR_WIDTH2  : N-1 bit of the top module address                                               //
//                      DATA_BITS    : Number of data bits                                                             //
//                      PARITY_BITS  : Number of parity bits being injected into the data                              //
//                      ENCODED_WORD : Length of the hamming encoded word                                              //
//                      WR_LATENCYA  : Write latency of port-a                                                         //
//                      RD_LATENCYA  : Read latency of port-a                                                          //
//                      WR_LATENCYB  : Write latency of port-b                                                         //
//                      RD_LATENCYB  : Read latency of port-b                                                          //
//                                                                                                                     //
//  File Description  : This is the top module that combines all the features that include latency,banking,            //
//                      error detection and correction.                                                                //         
//                                                                                                                     //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module MEMORY_TOP#( parameter DATA_A       = 12,
	                  parameter DATA_B       = DATA_A,
	                  parameter ADDR_A       = $clog2(4 * MEM_DEPTH),
	                  parameter ADDR_B       = $clog2(4 * MEM_DEPTH),
	                  parameter MEM_DEPTH    = 64,
	                  parameter MEM_WIDTH    = ADDR_A + ADDR_B,
	                  parameter ADDR_WIDTH1  = ADDR_A,
	                  parameter ADDR_WIDTH2  = ADDR_A - 1,
                    parameter DATA_BITS    = DATA_A,
                    parameter PARITY_BITS  = $clog2(DATA_BITS) + 1,
	                  parameter ENCODED_WORD = DATA_BITS+PARITY_BITS,
	                  
	                  parameter WR_LATENCYA  = 1,
	                  parameter RD_LATENCYA  = 1,
	                  parameter WR_LATENCYB  = 1,
	                  parameter RD_LATENCYB  = 1
                  )(  input                   clka,clkb,i_wea,i_web,i_ena,i_enb,
	                    input  [ADDR_A-1:0]     i_addra,
	                    input  [ADDR_B-1:0]     i_addrb,
	                    input  [DATA_A-1:0]     i_data_in_a,
	                    input  [DATA_B-1:0]     i_data_in_b,
	                    output [DATA_A-1:0]     o_dout_a,
	                    output [DATA_B-1:0]     o_dout_b
                   );
	
	wire[DATA_A-1:0]w1,w2,w3,w4;
	wire[DATA_B-1:0]w5,w6,w7,w8;
	reg[ADDR_WIDTH1-1:ADDR_WIDTH2-1]w9,w10,w11,w12;

	MUX_4x1#( .DATA_WIDTH(DATA_A),
            .ADDR_1(ADDR_WIDTH1),
            .ADDR_2(ADDR_WIDTH2))BANK_ROUTER_A( .i_i0(w1),
                                                .i_i1(w2),
                                                .i_i2(w3),
                                                .i_i3(w4),
                                                .o_Y(o_dout_a),
                                                .i_sel(w11)
                                              );

	MUX_4x1#( .DATA_WIDTH(DATA_A),
            .ADDR_1(ADDR_B),
            .ADDR_2(ADDR_B-1))BANK_ROUTER_B(  .i_i0(w5),
                                              .i_i1(w6),
                                              .i_i2(w7),
                                              .i_i3(w8),
                                              .o_Y(o_dout_b),
                                              .i_sel(w12)
                                          );


	Memory_Control_Unit#( .DATA_A(DATA_A),
                        .DATA_B(DATA_B),
                        .ADDR_A(ADDR_A),
                        .ADDR_B(ADDR_B),
                        .MEM_DEPTH(MEM_DEPTH),
                        .MEM_WIDTH(MEM_WIDTH),
                        .WR_LATENCYA(WR_LATENCYA),
                        .RD_LATENCYA(RD_LATENCYA),
                        .WR_LATENCYB(WR_LATENCYB),
                        .RD_LATENCYB(RD_LATENCYB))MEMORY_BANKS_UNIT( .clka(clka),
                                                                     .clkb(clkb),
                                                                     .i_wea(i_wea),
                                                                     .i_web(i_web),
                                                                     .i_ena(i_ena),
                                                                     .i_enb(i_enb),
                                                                     .i_addra(i_addra),
                                                                     .i_addrb(i_addrb),
                                                                     .i_data_in_a(i_data_in_a),
                                                                     .i_data_in_b(i_data_in_b),
                                                                     .BANKA_1(w1),
                                                                     .BANKA_2(w2),
                                                                     .BANKA_3(w3),
                                                                     .BANKA_4(w4),
	                                                                   .BANKB_1(w5),
                                                                     .BANKB_2(w6),
                                                                     .BANKB_3(w7),
                                                                     .BANKB_4(w8)
                                                                  );

	sel_latency#( .READ_LATENCYA(RD_LATENCYA),
                .READ_LATENCYB(RD_LATENCYB),
                .ADDR_WIDTH1(ADDR_WIDTH1),
                .ADDR_WIDTH2(ADDR_WIDTH2))ROUTER_SELECT_LINES( .clka(clka),
                                                               .clkb(clkb),
                                                               .i_sel_in_a(w9),
                                                               .i_sel_in_b(w10),
                                                               .o_sel_out_a(w11),
                                                               .o_sel_out_b(w12)
                                                             );

  always@(*)
  begin
    if(i_ena == 1'b1 && i_wea == 1'b0)
       w9 = i_addra[ADDR_A - 1 : ADDR_A - 2];
    if(i_enb == 1'b1 && i_web == 1'b0)
       w10 = i_addrb[ADDR_B - 1 : ADDR_B - 2];
  end
endmodule
