`timescale 1ns / 1ps
`include "defines.vh"

module RAM (
    input sysclk,
    input [14:0] addressM,
    input [`REGISTER_SIZE-1:0] outM,
    input writeM,
    output reg [`REGISTER_SIZE-1:0] out,
    input reset,
    
    // VGA
    input [12:0] vga_addr,
    output reg [`REGISTER_SIZE-1:0] vga_data
);
    // RAM Arrays
    reg [`REGISTER_SIZE-1:0] ram_array [0:16383];
    reg [`REGISTER_SIZE-1:0] screen_array [0:8191];
    reg [`REGISTER_SIZE-1:0] kbd = 16'b0;
    
    //Start by setting RAM to 0
    integer i, j;
    initial begin
        for (i = 0; i < 16384; i = i + 1) begin
            ram_array[i] = 16'b0;
        end
        for (j = 0; j < 8192; j = j + 1) begin
            screen_array[j] = 16'b0;
        end
    end

    //VGA Reading
    always @(posedge sysclk) begin
        if (vga_addr < 8192)
            vga_data <= screen_array[vga_addr];
        else
            vga_data <= 16'b0;
    end

    //CPU Reading
    always @(*) begin
        if (addressM <= 16383) 
            out = ram_array[addressM];
        else if (addressM >= 16384 && addressM <= 24575) 
            out = screen_array[addressM - 16384];
        else if (addressM == 24576)
            out = kbd;
        else 
            out = 0;
    end
    
    //Writing and Reading
    integer z;
    always @(posedge sysclk) begin
        if (writeM) begin
            if (addressM <= 16383) 
                ram_array[addressM] <= outM;
            else if (addressM >= 16384 && addressM <= 24575) 
                screen_array[addressM - 16384] <= outM;
        end
        
        //if (reset) begin
        //    for (z = 0; z < 16384; z = z + 1) begin
        //        ram_array[z] = 16'b0;
        //    end
        //    z = 0;
        //end
    end

endmodule