// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Lite Edition"
// CREATED		"Wed Mar 29 15:12:51 2023"

module Sn_counter_module(
	UP_in,
	D_in,
	DN_in,
	CLK_In,
	CLRn_in,
	UP_out,
	D_out,
	Q_out,
	DN_out
);

input wire	UP_in;
input wire	D_in;
input wire	DN_in;
input wire	CLK_In;
input wire	CLRn_in;
output wire	UP_out;
output wire	D_out;
output wire	Q_out;
output wire	DN_out;

wire	Qn;
reg	Q;
wire	D;
wire	Down;
wire	Up;

always@(posedge CLK_In or negedge CLRn_in)
begin
if (!CLRn_in)
	begin
	Q <= 0;
	end
else
	begin
	Q <= D;
	end
end

assign	Up = UP_in & Q;
assign	D = Q ^ D_in;
assign	Qn =  ~Q;
assign	Down = Qn & DN_in;

assign	UP_out = Up;
assign	D_out = Down | Up;
assign	Q_out = Q;
assign	DN_out = Down;

endmodule
