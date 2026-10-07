`timescale 1ns / 1ps
`include "defines.vh"

module CPU(
    input sysclk,
    input [15:0] instruction,
    input [`REGISTER_SIZE-1:0] inM,
    input reset,
    output [`REGISTER_SIZE-1:0] outM,
    output writeM,
    output [14:0] addressM,
    output [14:0] pc
);
    
    reg [15:0] A;
    reg [15:0] D;
    reg [15:0] PC;
    
    initial begin
        A  = 16'b0;
        D  = 16'b0;
        PC = 16'b0;
    end
    
    //Standard CPU things
    wire zr_wire, ng_wire;
    wire [15:0] outm;
    
    wire isA = !instruction[15];
    wire isC = instruction[15];

    wire loadA  = isA || (isC && instruction[5]); 
    wire loadD  = isC && instruction[4];          
    assign writeM = isC && instruction[3];       

    wire [15:0] AM_mux = instruction[12] ? inM : A;

    assign outM     = outm;
    assign addressM = A[14:0];
    assign pc       = PC[14:0];

    wire isPos    = !ng_wire && !zr_wire; 

    wire jumpLT   = instruction[2] && ng_wire;
    wire jumpEQ   = instruction[1] && zr_wire;
    wire jumpGT   = instruction[0] && isPos;
    
    wire willJump = isC && (jumpLT || jumpEQ || jumpGT);

    ALU a (
        .D(D), 
        .AM(AM_mux), 
        .comp(instruction[11:6]), 
        .outM(outm), 
        .ZR(zr_wire), 
        .NG(ng_wire)
    );
    
    //Edit registers
    always @(posedge sysclk) begin
        if (reset) begin
            A  <= 16'b0;
            D  <= 16'b0;
            PC <= 16'b0;
        end 
        else begin
            if (loadA) begin
                A <= isA ? instruction : outm;
            end
            
            if (loadD) begin
                D <= outm;
            end
            
            if (willJump) begin
                PC <= A; 
            end else begin
                PC <= PC + 1'b1;
            end
        end
    end
    
endmodule