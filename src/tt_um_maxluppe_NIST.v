/*
 * Copyright (c) 2024 Maximiliam Luppe
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_maxluppe_NIST (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    reg RND_in;
    wire [3:0] RND_out;
    wire RND_D_out;
    wire sel;
    wire lfsr_clk, lfsr_rst_n, lfsr_out;
    wire alfsr_clk, alfsr_rst_n;
    wire NIST_clk, NIST_rst_n;
    wire global_error_n, error1, error2, error3, error4;
    
    // All output pins must be assigned. If not used, assign to 0.
    assign uio_out[7:4] = 0;
    assign uio_oe  = 8'b00001111;

    alfsr alfsr0 (.clk(alfsr_clk),                //Digitalization clock
                  .rng_out_d(RND_D_out),    //ALFSR 'digitalized' output
                  .rng_out(RND_out),        //ALFSR 'analog' outputs
                  .alfsr_rst_n(alfsr_rst_n),   //ALFSR reset
                  .lfsr_clk(ui_in[0]),		//LFSR Configurator clock
                  .lfsr_rst_n(rst_n),	    //LFSR Configurator reset
                  .lfsr_out(lfsr_out),		//LFSR Configurator output
    );
    
    assign alfsr_clk = clk;
    assign alfsr_rst_n = ui_in[1];
    assign lfsr_clk = sel ? ui_in[0] : global_error_n;
    assign lfsr_rst_n = rst_n;
    
    assign uio_out[3:0] = RND_out;

    always @(negedge(clk)) begin
        RND_in <= sel ? RND_D_out : ui_in[2];        //Random bits input
    end

    NIST_SP_800_22 NIST0123 (.clk(NIST_clk),
                             .rstn(NIST_rst_n),
                             .RND_in(RND_in),
                             .error1(error1),
                             .error2(error2),
                             .error3(error3),
                             .error4(error4)
    );

    assign sel = ui_in[3];    //Operation mode: 1 - test, 0 - running

    assign NIST_clk = clk;
    assign NIST_rst_n = sel ? rst_n : global_error_n;
    assign global_error_n = ~(error1 | error2 | error3 | error4);

    assign uo_out[0] = error1;
    assign uo_out[1] = error2;
    assign uo_out[2] = error3;
    assign uo_out[3] = error4;
    assign uo_out[4] = global_error_n;
    assign uo_out[5] = lfsr_out;
    assign uo_out[6] = RND_D_out;
    assign uo_out[7] = RND_out[3];
    
    wire _unused = &{ena, ui_in[7], ui_in[6], ui_in[5], ui_in[4], 1'b0};

endmodule
