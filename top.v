module top
(
  clk,
  rst,
  x,
  en,
  epx,
  sinhx,
  coshx,
  valid
);

input             clk;
input             rst;
input      [31:0] x;
input             en;

output reg [31:0] epx;
       reg [31:0] enx;
output reg [31:0] sinhx;
output reg [31:0] coshx;
output reg        valid;


wire [2047:0] lookupp;
wire [2047:0] lookupn;

wire   [31:0] w_sinhx;
wire   [31:0] w_coshx;
wire   [63:0] w_epx;
wire   [63:0] w_enx;
wire          w_valid;


cordicp epos (
  .x      (x),
  .clk    (clk),
  .rst    (rst),
  .en     (en),
  .lookup (lookupp),
  .y      (w_epx),
  .valid  (validp)
);

cordicn eneg (
  .x      (x),
  .clk    (clk),
  .rst    (rst),
  .en     (en),
  .lookup (lookupn),
  .y      (w_enx),
  .valid  (validn)
);

always @ (posedge clk, rst) begin
  if (rst == 1'b1) begin
    epx   <= 32'b0;
    enx   <= 32'b0;
    sinhx <= 32'b0;
    coshx <= 32'b0;
    valid <=  1'b0;
  end
  
  /* Lock in e^x, e^-x when valid is high */
  if (validp == 1'b1)
    epx <= w_epx[47:16];
  if (validn == 1'b1)
    enx <= w_enx[47:16];

  sinhx <= w_sinhx;
  coshx <= w_coshx;
  valid <= w_valid;

end

assign w_sinhx = (w_epx [47:16] - w_enx [47:16]) >> 1;
assign w_coshx = (w_epx [47:16] + w_enx [47:16]) >> 1;
assign w_valid = validn & validp;

assign lookupp = { 
  64'h0000_000B_1721_7F7D,    
  64'h0000_000A_65AF_6785,    
  64'h0000_0009_B43D_4F8D,    
  64'h0000_0009_02CB_3795,    
  64'h0000_0008_5159_1F9D,    
  64'h0000_0007_9FE7_07A6,    
  64'h0000_0006_EE74_EFAE,    
  64'h0000_0006_3D02_D7B6,    
  64'h0000_0005_8B90_BFBE,    
  64'h0000_0004_DA1E_A7C6,    
  64'h0000_0004_28AC_8FCE,    
  64'h0000_0003_773A_77D7,    
  64'h0000_0002_C5C8_5FDF,   
  64'h0000_0002_1456_47E7,   
  64'h0000_0001_62E4_2FEF,   
  64'h0000_0000_B172_17F7,   
  64'h0000_0000_67CC_8FB2,   
  64'h0000_0000_391F_EF8F,   
  64'h0000_0000_1E27_076E,  
  64'h0000_0000_0F85_1860, 
  64'h0000_0000_07E0_A6C3, 
  64'h0000_0000_03F8_1516, 
  64'h0000_0000_01FE_02A6, 
  64'h0000_0000_00FF_8055, 
  64'h0000_0000_007F_E00A,
  64'h0000_0000_003F_F801,
  64'h0000_0000_001F_FE00,
  64'h0000_0000_000F_FF80,
  64'h0000_0000_0007_FFE0,
  64'h0000_0000_0003_FFF8,
  64'h0000_0000_0001_FFFE,
  64'h0000_0000_0000_FFFF
  };

assign lookupn = {
    64'h0000_000B_1721_7F7D,      
    64'h0000_000A_65AF_6785,      
    64'h0000_0009_B43D_4F8D,      
    64'h0000_0009_02CB_3795,      
    64'h0000_0008_5159_1F9D,      
    64'h0000_0007_9FE7_07A6,      
    64'h0000_0006_EE74_EFAE,      
    64'h0000_0006_3D02_D7B6,      
    64'h0000_0005_8B90_BFBE,      
    64'h0000_0004_DA1E_A7C6,      
    64'h0000_0004_28AC_8FCE,      
    64'h0000_0003_773A_77D7,      
    64'h0000_0002_C5C8_5FDF,     
    64'h0000_0002_1456_47E7,     
    64'h0000_0001_62E4_2FEF,     
    64'h0000_0000_B172_17F7, 
    64'h0000_0000_49A5_8844, 
    64'h0000_0000_222F_1D04, 
    64'h0000_0000_1085_98B5, 
    64'h0000_0000_0820_AEC4, 
    64'h0000_0000_0408_1596,
    64'h0000_0000_0202_02AE,
    64'h0000_0000_0100_8055,
    64'h0000_0000_0080_200A,
    64'h0000_0000_0040_0801,
    64'h0000_0000_0020_0200,
    64'h0000_0000_0010_0080,
    64'h0000_0000_0008_0020,
    64'h0000_0000_0004_0008,
    64'h0000_0000_0002_0002,
    64'h0000_0000_0001_0000,
    64'h0000_0000_0000_8000
    };


endmodule
