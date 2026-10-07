module VGA_DRIVER (
    input         sysclk,
    input  [15:0] vga_data,
    output [12:0] vga_addr,
    output        HS,
    output        VS,
    output reg [2:0] RED,
    output reg [2:0] GREEN,
    output reg [1:0] BLUE
);
 
    //Start at 64, go to 546, start at 112, go to 368
    localparam [9:0] X_START = 10'd64;    // (640 - 512) / 2
    localparam [9:0] X_END   = 10'd576;   // X_START + 512
    localparam [9:0] Y_START = 10'd112;   // (480 - 256) / 2
    localparam [9:0] Y_END   = 10'd368;   // Y_START + 256

    //                                 R   G   B
    localparam [7:0] FG_COLOR     = 8'b111_111_11;   
    localparam [7:0] BG_COLOR     = 8'b000_000_00;
    localparam [7:0] BORDER_COLOR = 8'b000_000_00;
 
    wire [9:0] x, y;
    wire       blank;
    wire       hs_raw, vs_raw;
 
    vga vga (
        .CLK  (sysclk),
        .HS   (hs_raw),
        .VS   (vs_raw),
        .x    (x),
        .y    (y),
        .blank(blank)
    );
 
    wire [9:0] px = x - X_START;
    wire [9:0] py = y - Y_START;
 
    wire in_window = (x >= X_START) && (x < X_END) &&
                     (y >= Y_START) && (y < Y_END) && !blank;
 
    //address = row * 32 + column / 16
    assign vga_addr = {py[7:0], px[8:4]};
 
    reg [2:0] pair_sel1;
    reg in_window1;
    reg border1;
    reg hs1, vs1;
 
    initial begin
        pair_sel1  = 3'd0;
        in_window1 = 1'b0;
        border1    = 1'b0;
        hs1        = 1'b1;
        vs1        = 1'b1;
        RED = 3'd0; GREEN = 3'd0; BLUE = 2'd0;
    end
 
    always @(posedge sysclk) begin
        pair_sel1  <= px[3:1];
        in_window1 <= in_window;
        border1    <= !blank && !in_window && (x < 10'd640);
        hs1        <= hs_raw;
        vs1        <= vs_raw;
    end
 
    reg hs2, vs2;
    initial begin
        hs2 = 1'b1;
        vs2 = 1'b1;
    end
 
    // OR the two adjacent pixels
    wire [1:0] pair   = vga_data >> {pair_sel1, 1'b0};
    wire pixel  = (|pair) ^ 1'b0;
 
    always @(posedge sysclk) begin
        hs2 <= hs1;
        vs2 <= vs1;
 
        if (in_window1) begin
            {RED, GREEN, BLUE} <= pixel ? FG_COLOR : BG_COLOR;
        end else if (border1) begin
            {RED, GREEN, BLUE} <= BORDER_COLOR;
        end else begin
            {RED, GREEN, BLUE} <= 8'b0;
        end
    end
 
    assign HS = hs2;
    assign VS = vs2;
 
endmodule