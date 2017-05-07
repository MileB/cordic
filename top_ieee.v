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
wire              nonieee_valid;
wire       [31:0] epx_part;
wire              epx_itf_stb;
wire              epx_div_ack;
wire       [31:0] sinhx_part;
wire              sinhx_itf_stb;
wire              sinhx_div_ack;
wire       [31:0] coshx_part;
wire              coshx_itf_stb;
wire              coshx_div_ack;

wire              coshx_stb;
wire              sinhx_stb;
wire              epx_stb;

reg               coshx_stb_reg;
reg               sinhx_stb_reg;
reg               epx_stb_reg;

multiplier mul(
  .input_a      (ieee_x),
  .input_b      (coeff),
  .input_a_stb  (en),
  .input_b_stb  (1'b1),
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
  .epx    (epx),
  .sinhx  (sinhx),
  .coshx  (coshx),
  .valid  (nonieee_valid)
);

int_to_float epx_itf(
  .input_a      (epx),
  .input_a_stb  (nonieee_valid),
  .output_z_ack (epx_div_ack),
  .clk          (clk),
  .rst          (rst),
  .output_z     (epx_part),
  .output_z_stb (epx_itf_stb)
  //.input_a_ack  ( )
);

divider epx_div(
  .input_a      (epx_part),
  .input_b      (coeff),
  .input_a_stb  (epx_itf_stb),
  .input_b_stb  (1'b1),
  .output_z_ack ( ),
  .clk          (clk),
  .rst          (rst),
  .output_z     (ieee_epx),
  .output_z_stb (epx_stb), 
  .input_a_ack  (epx_div_ack)
  //.input_b_ack  ( )
);

int_to_float sinhx_itf(
  .input_a      (sinhx),
  .input_a_stb  (nonieee_valid),
  .output_z_ack (sinhx_div_ack),
  .clk          (clk),
  .rst          (rst),
  .output_z     (sinhx_part),
  .output_z_stb (sinhx_itf_stb)
  //.input_a_ack  ( )
);

divider sinhx_div(
  .input_a      (sinhx_part),
  .input_b      (coeff),
  .input_a_stb  (sinhx_itf_stb),
  .input_b_stb  (1'b1),
  .output_z_ack ( ),
  .clk          (clk),
  .rst          (rst),
  .output_z     (ieee_sinhx),
  .output_z_stb (sinhx_stb), 
  .input_a_ack  (sinhx_div_ack)
  //.input_b_ack  ( )
);

int_to_float coshx_itf(
  .input_a      (coshx),
  .input_a_stb  (nonieee_valid),
  .output_z_ack (coshx_div_ack),
  .clk          (clk),
  .rst          (rst),
  .output_z     (coshx_part),
  .output_z_stb (coshx_itf_stb)
  //.input_a_ack  ( )
);

divider coshx_div(
  .input_a      (coshx_part),
  .input_b      (coeff),
  .input_a_stb  (coshx_itf_stb),
  .input_b_stb  (1'b1),
  .output_z_ack ( ),
  .clk          (clk),
  .rst          (rst),
  .output_z     (ieee_coshx),
  .output_z_stb (coshx_stb),
  .input_a_ack  (coshx_div_ack)
  //.input_b_ack  ( )
);


always @ (posedge clk, rst) begin
  if (rst == 1'b1) begin
    coshx_stb_reg <= 1'b0;
    sinhx_stb_reg <= 1'b0;
    epx_stb_reg   <= 1'b0;
  end
  if (coshx_stb == 1'b1) coshx_stb_reg <= 1'b1;
  if (sinhx_stb == 1'b1) sinhx_stb_reg <= 1'b1;
  if (epx_stb   == 1'b1)   epx_stb_reg <= 1'b1;
end

assign coeff = 32'h47800000; // 2^16 in IEEE-754

assign valid = coshx_stb & sinhx_stb_reg & epx_stb_reg;

endmodule
