/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  File name         : controller_interface.v                                                                         //
//  Version           : 0.2                                                                                            //
//                                                                                                                     //
//  parameters used   : MEM_DEPTH   : Depth of the DP RAM                                                              //
//                      ADDRA_WIDTH : Width of address from port-a                                                     //
//                      ADDRB_WIDTH : Width of address from port-b                                                     //
//                      DATAA_WIDTH : Width of data from port-a                                                        //
//                      DATAB_WIDTH : Width of data from port-b                                                        //
//                                                                                                                     //
//  File Description  : This is the top module of the banking control interface that connects all the address          // 
//                      decoding and data decoding muxes to the bank selection decoders that forms                     //
//                      the overall banking control and selection logic.                                               //
//                                                                                                                     //  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module controller_interface#( parameter MEM_DEPTH   = 64,
	                            parameter ADDRA_WIDTH = $clog2(4 * MEM_DEPTH),
	                            parameter ADDRB_WIDTH = ADDRA_WIDTH,
	                            parameter DATAA_WIDTH = 8,
	                            parameter DATAB_WIDTH = DATAA_WIDTH
                            )(  input  [ADDRA_WIDTH-1:0] i_addra,
	                              input  [ADDRB_WIDTH-1:0] i_addrb,
	                              input  [DATAA_WIDTH-1:0] i_data_a,
	                              input  [DATAB_WIDTH-1:0] i_data_b,
	                              input                    i_ena,i_enb,
	                              
	                              output [ADDRA_WIDTH-3:0] o_addr_out_a1,o_addr_out_a2,o_addr_out_a3,o_addr_out_a4,
	                              output [ADDRB_WIDTH-3:0] o_addr_out_b1,o_addr_out_b2,o_addr_out_b3,o_addr_out_b4,
	                              output [DATAA_WIDTH-1:0] o_data_out_a1,o_data_out_a2,o_data_out_a3,o_data_out_a4,
	                              output [DATAB_WIDTH-1:0] o_data_out_b1,o_data_out_b2,o_data_out_b3,o_data_out_b4,
	                              
	                              output o_a1,o_a2,o_a3,o_a4,
	                              output o_b1,o_b2,o_b3,o_b4
                             );

	wire [ADDRA_WIDTH-1:ADDRA_WIDTH-2] select_wire1,select_wire2,select_wire3,select_wire4,select_wire5,select_wire6;
  wire [ADDRA_WIDTH-3:0]             w0;
	wire [ADDRB_WIDTH-3:0]             w5;
	wire [3:0]                         w10,w11;
	
	Demultiplexer1_address#(  .ADDR_WIDTH(ADDRA_WIDTH),
                            .SELECT_WIDTH1(ADDRA_WIDTH),
                            .SELECT_WIDTH2(ADDRA_WIDTH-1))ADDRESS_DECODER_1( .i_address(w0),
                                                                             .i_sel(select_wire1),
                                                                             .o_y0(o_addr_out_a1),
                                                                             .o_y1(o_addr_out_a2),
                                                                             .o_y2(o_addr_out_a3),
                                                                             .o_y3(o_addr_out_a4)
                                                                           );
	
	Demultiplexer1_address#(  .ADDR_WIDTH(ADDRB_WIDTH),
                            .SELECT_WIDTH1(ADDRB_WIDTH),
                            .SELECT_WIDTH2(ADDRB_WIDTH-1))ADDRESS_DECODER_2( .i_address(w5),
                                                                             .i_sel(select_wire2),
                                                                             .o_y0(o_addr_out_b1),
                                                                             .o_y1(o_addr_out_b2),
                                                                             .o_y2(o_addr_out_b3),
                                                                             .o_y3(o_addr_out_b4)
                                                                           );
	
	demultiplexer_data#(  .DATA_WIDTH(DATAA_WIDTH),
                        .SELECT_DATA_WIDTH1(ADDRA_WIDTH),
                        .SELECT_DATA_WIDTH2(ADDRA_WIDTH-1))DATA_ROUTING_A(  .i_data(i_data_a),
                                                                            .i_sel(select_wire3),
                                                                            .o_y0(o_data_out_a1),
                                                                            .o_y1(o_data_out_a2),
                                                                            .o_y2(o_data_out_a3),
                                                                            .o_y3(o_data_out_a4)
                                                                         );
	
	demultiplexer_data#(  .DATA_WIDTH(DATAB_WIDTH),
                        .SELECT_DATA_WIDTH1(ADDRB_WIDTH),
                        .SELECT_DATA_WIDTH2(ADDRB_WIDTH-1))DATA_ROUTING_B(  .i_data(i_data_b),
                                                                            .i_sel(select_wire4),
                                                                            .o_y0(o_data_out_b1),
                                                                            .o_y1(o_data_out_b2),
                                                                            .o_y2(o_data_out_b3),
                                                                            .o_y3(o_data_out_b4)
                                                                         );
	
	Decoder_enable_lines#(  .SELECT_ADDR1(ADDRA_WIDTH),
                          .SELECT_ADDR2(ADDRA_WIDTH-1))BANK_SELECTOR_A(  .i_I(select_wire5),
                                                                         .o_y(w10)
                                                                      );

	Decoder_enable_lines#(  .SELECT_ADDR1(ADDRB_WIDTH),
                          .SELECT_ADDR2(ADDRB_WIDTH-1))BANK_SELECTOR_B(  .i_I(select_wire6),
                                                                         .o_y(w11)
                                                                      );
	
	assign w0           = i_addra [ADDRA_WIDTH-3:0];
	assign w5           = i_addrb [ADDRB_WIDTH-3:0];
	assign select_wire1 = i_addra [ADDRA_WIDTH-1:ADDRA_WIDTH-2];
	assign select_wire2 = i_addrb [ADDRB_WIDTH-1:ADDRB_WIDTH-2];
	assign select_wire3 = i_addra [ADDRA_WIDTH-1:ADDRA_WIDTH-2];
	assign select_wire4 = i_addrb [ADDRB_WIDTH-1:ADDRB_WIDTH-2];
	assign select_wire5 = select_wire3;
	assign select_wire6 = select_wire4;

	assign o_a1 = w10[3] ? (i_ena == 1) : 1'b0;
	assign o_a2 = w10[2] ? (i_ena == 1) : 1'b0;
	assign o_a3 = w10[1] ? (i_ena == 1) : 1'b0;
	assign o_a4 = w10[0] ? (i_ena == 1) : 1'b0;
	
	assign o_b1 = w11[3] ? (i_enb == 1) : 1'b0;
	assign o_b2 = w11[2] ? (i_enb == 1) : 1'b0;
	assign o_b3 = w11[1] ? (i_enb == 1) : 1'b0;
	assign o_b4 = w11[0] ? (i_enb == 1) : 1'b0;

endmodule
