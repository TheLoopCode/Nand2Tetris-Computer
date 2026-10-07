`timescale 1ns / 1ps
`include "defines.vh"

module ALU (
    input [`REGISTER_SIZE-1:0] D,      // x input
    input [`REGISTER_SIZE-1:0] AM,     // y input
    input [5:0] comp,                  // instruction[11:6] -> [zx, nx, zy, ny, f, no]
    output ZR,
    output NG,
    output [`REGISTER_SIZE-1:0] outM
    );

    // Unpack bits directly matching instruction[11:6]
    wire zx = comp[5]; // instruction[11]
    wire nx = comp[4]; // instruction[10]
    wire zy = comp[3]; // instruction[9]
    wire ny = comp[2]; // instruction[8]
    wire f  = comp[1]; // instruction[7]
    wire no = comp[0]; // instruction[6]

    // Step 1: Zero / Invert X (D)
    wire [`REGISTER_SIZE-1:0] x1 = zx ? 16'b0 : D;
    wire [`REGISTER_SIZE-1:0] x2 = nx ? ~x1 : x1;

    // Step 2: Zero / Invert Y (AM)
    wire [`REGISTER_SIZE-1:0] y1 = zy ? 16'b0 : AM;
    wire [`REGISTER_SIZE-1:0] y2 = ny ? ~y1 : y1;

    // Step 3: Compute f (1 = Add, 0 = Bitwise AND)
    wire [`REGISTER_SIZE-1:0] f_out = f ? (x2 + y2) : (x2 & y2);

    // Step 4: Invert output
    wire [`REGISTER_SIZE-1:0] out = no ? ~f_out : f_out;

    assign outM = out;
    assign ZR   = (out == 16'b0);
    assign NG   = out[`REGISTER_SIZE-1];

endmodule