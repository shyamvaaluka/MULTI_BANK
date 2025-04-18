////////////////////////////////////////////////////////////////////////////////////
//  File name        : top.sv                                                     //
//                                                                                //
//                                                                                //
//  File Description : This is the top module which controls the overall          //
//                     latency and banking features with all the test bench       // 
//                     components and design units instantiated within this       //
//                     module.                                                    //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

//Importing pkg_2 which consists of all the parameters that are required for
//adjusting data width, address width, latency values of read and write etc.
import pkg_2::*;
//Here we include all the design units and interface that are to be compiled 
//and verified using `include directive.
`include "./rtl/latency_module.sv"
`include "./rtl/modified_dual_mem.sv"
`include "./rtl/latency_ram_top.sv"
`include "./rtl/Demultiplexer1_address.v"
`include "./rtl/demultiplexer_data.v"
`include "./rtl/Decoder_enable_lines.v"
`include "./rtl/controller_interface.v"
`include "./rtl/Controlling_Memory.v"
`include "./rtl/4x1MUX.v"
`include "./rtl/sel_latency.sv"
`include "./rtl/MEMORY_CONTROL_TOP.sv"
`include "interface.sv"
//Imporitng the package class which consists of all the test bench component
//files that are included within the package class using `include directive.
import pkg::*;

//This is the top module which consists of clock generation, design top
//instantiation to the test bench and creating object for test class which
//controls all the other test bench components in hierarchy.
module top;
  //Declaring clock inputs for port-a and port-b.
	bit clka,clkb;

  //Using always block we generate the clock for 5ns and 10ns time periods for
  //port-a and port-b respectively. And this is done till the coverage of read
  //and write for both ports cover 100%. 
	always #5 clka=~clka;
	always #10 clkb=~clkb;	

  	
  //Instantiating the top module of latency and banking feature to the test bench
  //interface using pass by name method.
	MEMORY_TOP#( .DATA_A(DATA_WIDTH),
               .MEM_DEPTH(MEM_DEPTH),
               .WR_LATENCYA(WR_LATENCYA),
               .WR_LATENCYB(WR_LATENCYB),
               .RD_LATENCYA(RD_LATENCYA),
               .RD_LATENCYB(RD_LATENCYB)
               )DUT(  .clka(in0.clka),
			 						    .clkb(in0.clkb),
									    .i_ena(in0.i_ena),
									    .i_enb(in0.i_enb),
									    .i_wea(in0.i_wea),
									    .i_web(in0.i_web),
									    .i_data_in_a(in0.i_dina),
									    .i_data_in_b(in0.i_dinb),
									    .i_addra(in0.i_addra),
									    .i_addrb(in0.i_addrb),
									    .o_dout_a(in0.o_douta),
									    .o_dout_b(in0.o_doutb));


  //Instantiating the clock inputs of the testbench top to the interface clock
  //so that the stimulus is synchronized to the testbench top clock of both
  //the ports. 
  dual_iff in0( .clka(clka),
        				.clkb(clkb));

  //Here we declare handle for test class. 
  dual_test test_h;

  //In this block we are creating object for test class and passing all the
  //static interfaces from top module to the environment.
  initial
  begin
    //Creating object using new() keyword and passing all the static
    //interfaces to the environment which are later converted to virtual and
    //are used by drivers and monitors of both the ports.
    test_h=new(in0,in0,in0,in0);
    //We call the run method in the test class to initiate all the start
    //methods of all test bench components. 
    test_h.run();
  end
   
endmodule
