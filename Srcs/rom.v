`include "defines.vh"

module ROM (
    input sysclk,
    input [14:0] address,
    output [15:0] instruction
);

    reg [15:0] rom_array [0:32768];
    
    //Load main.mem to rom array
    initial begin
        $readmemb("main.mem", rom_array);
    end

    //output rom_array[address]
    assign instruction = rom_array[address];

endmodule