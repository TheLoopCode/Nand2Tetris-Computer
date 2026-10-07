`timescale 1ns / 1ps
`include "defines.vh"

module Computer(
    input sysclk,

    output HS,
    output VS,
    output [2:0] RED,
    output [2:0] GREEN,
    output [1:0] BLUE,
    output [3:0] out
);

    wire [15:0] instruction;
    wire [`REGISTER_SIZE-1:0] vgaData_wire;
    wire [12:0] vgaAddr_wire;
    wire [`REGISTER_SIZE-1:0] outM_wire;
    wire [`REGISTER_SIZE-1:0] inM_wire;
    wire [14:0] addressM_wire;
    wire [14:0] pc_wire;
    wire writeM_wire;

    ROM rom (
        .sysclk(sysclk),
        .instruction(instruction),
        .address(pc_wire)
    );

    CPU cpu (
        .sysclk(sysclk),
        .instruction(instruction),
        .inM(inM_wire),
        .reset(reset),
        .outM(outM_wire),
        .writeM(writeM_wire),
        .addressM(addressM_wire),
        .pc(pc_wire)
    );

    RAM ram (
        .sysclk(sysclk),
        .addressM(addressM_wire),
        .outM(outM_wire),
        .writeM(writeM_wire),
        .out(inM_wire),
        .vga_addr(vgaAddr_wire),
        .vga_data(vgaData_wire)
    );

    VGA_DRIVER vga_driver (
        .sysclk(sysclk),
        .vga_data(vgaData_wire),
        .vga_addr(vgaAddr_wire),
        .HS(HS),
        .VS(VS),
        .RED(RED),
        .GREEN(GREEN),
        .BLUE(BLUE)
    );

    assign out = inM_wire[3:0];

endmodule