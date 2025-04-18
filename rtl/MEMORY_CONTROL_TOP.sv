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
                  )(  input                     clka,clkb,                 // Clock inputs for port-a and port-b.
                      input                     i_wea,i_web,               // Write_enable signals for port-a and port-b.
                      input                     i_ena,i_enb,               // Enable signals for port-a and port-b.
	                    input  [ADDR_A-1:0]       i_addra,                   // port-a input address.
	                    input  [ADDR_B-1:0]       i_addrb,                   // port-b input address.
	                    input  [DATA_A-1:0]       i_data_in_a,               // port-a data input.
	                    input  [DATA_B-1:0]       i_data_in_b,               // port-b data input.
	                    output [DATA_A-1:0]       o_dout_a,                  // Data output port for port-a.
	                    output [DATA_B-1:0]       o_dout_b                   // Data output port for port-b.
                   );
	
	wire [DATA_WIDTH-1:0]            bank_a1,bank_a2,bank_a3,bank_a4;       // Wires to transmit bank outputs of port-a.
	wire [DATA_WIDTH-1:0]            bank_b1,bank_b2,bank_b3,bank_b4;       // Wires to trasmit bank outputs of port-b.
	reg  [ADDR_WIDTH1-1:ADDR_WIDTH2-1] sel_in_a,sel_in_b;                     // Wires to transmit the top two bits of input address from top module to select latency module.
  reg  [ADDR_WIDTH1-1:ADDR_WIDTH2-1] sel_out_a,sel_out_b;                   // Outputs of select latency module that goes to data selector to route data onto single channel.

  //Data router for port-a which routes all the 4 data outputs from the dual
  //port memories of port-a type onto single channel.
	MUX_4x1#( .DATA_WIDTH(DATA_A),
            .ADDR_1(ADDR_WIDTH1),
            .ADDR_2(ADDR_WIDTH2))BANK_ROUTER_A( .i_i0(bank_a1),
                                                .i_i1(bank_a2),
                                                .i_i2(bank_a3),
                                                .i_i3(bank_a4),
                                                .o_Y(o_dout_a),
                                                .i_sel(sel_out_a)
                                              );

  //Data router for port-b which routes all the 4 data outputs from the dual
  //port memories of port-b type onto single channel.
	MUX_4x1#( .DATA_WIDTH(DATA_A),
            .ADDR_1(ADDR_B),
            .ADDR_2(ADDR_B-1))BANK_ROUTER_B(  .i_i0(bank_b1),
                                              .i_i1(bank_b2),
                                              .i_i2(bank_b3),
                                              .i_i3(bank_b4),
                                              .o_Y(o_dout_b),
                                              .i_sel(sel_out_b)
                                           );

  //Memory controller which deals with overall banking, address decoding and
  //routing of data to their corresponding bank.
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
                                                                     .BANKA_1(bank_a1),
                                                                     .BANKA_2(bank_a2),
                                                                     .BANKA_3(bank_a3),
                                                                     .BANKA_4(bank_a4),
	                                                                   .BANKB_1(bank_b1),
                                                                     .BANKB_2(bank_b2),
                                                                     .BANKB_3(bank_b3),
                                                                     .BANKB_4(bank_b4)
                                                                  );
  //This module selects the data from the memory outputs after read latency
  //period. Based on this select input, the mux routes one of its 4 inputs onto
  //the single channel.
	sel_latency#( .READ_LATENCYA(RD_LATENCYA),
                .READ_LATENCYB(RD_LATENCYB),
                .ADDR_WIDTH1(ADDR_WIDTH1),
                .ADDR_WIDTH2(ADDR_WIDTH2))ROUTER_SELECT_LINES( .clka(clka),
                                                               .clkb(clkb),
                                                               .i_sel_in_a(sel_in_a),
                                                               .i_sel_in_b(sel_in_b),
                                                               .o_sel_out_a(sel_out_a),
                                                               .o_sel_out_b(sel_out_b)
                                                             );

  //This always block routes the data onto the single channel during read
  //operation configuration.
  always@(*)
  begin
    if(i_ena == 1'b1 && i_wea == 1'b0)
       sel_in_a = i_addra[ADDR_A - 1 : ADDR_A - 2];
    if(i_enb == 1'b1 && i_web == 1'b0)
       sel_in_b = i_addrb[ADDR_B - 1 : ADDR_B - 2];
  end

endmodule
