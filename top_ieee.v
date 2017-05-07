module top_ieee
(
  clk,
  rst,
  ieee_x,
  en,
  ieee_epx,
  ieee_sinhx,
  ieee_coshx,
  valid
);

input             clk;
input             rst;
input      [31:0] ieee_x;
input             en;

output     [31:0] ieee_epx;
output     [31:0] ieee_sinhx;
output     [31:0] ieee_coshx;
output            valid;

wire       [31:0] x;
wire       [31:0] epx;
wire       [31:0] sinhx;
wire       [31:0] coshx;

wire       [31:0] coeff;
wire       [31:0] ieee_e_mul;
wire              mul_stb;
wire              fti_ack;
wire              fti_stb;
wire              top_ack;

multiplier mul(
  .input_a      (ieee_x),
  .input_b      (coeff),
  .input_a_stb  (en),
  .input_b_stb  (en),
  .output_z_ack (fti_ack),
  .clk          (clk),
  .rst          (rst),
  .output_z     (ieee_e_mul),
  .output_z_stb (mul_stb)
  //.input_a_ack  ( ),
  //.input_b_ack  ( )
);

float_to_int fti(
  .input_a      (ieee_e_mul),
  .input_a_stb  (mul_stb),
  .output_z_ack ( ),
  .clk          (clk),
  .rst          (rst),
  .output_z     (x),
  .output_z_stb (fti_stb),
  .input_a_ack  (fti_ack)
);

top nonieee (
  .clk    (clk),
  .rst    (rst),
  .x      (x),
  .en     (fti_stb),
  .epx    (ieee_epx),
  .sinhx  (ieee_sinhx),
  .coshx  (ieee_coshx),
  .valid  (valid)
);

always @ (posedge clk, rst) begin
end

assign coeff = 32'h47800000; // 2^16 in IEEE-754

endmodule
