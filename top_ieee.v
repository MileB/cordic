/* top_ieee.v
* Wrapper around the top.v file
* to provide the same functionality
* using IEEE-754 standard format
* Note: IEEE-754 is not at all efficient
* for this math so the conversion is
* actually what takes the longest */
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

/* Multiply the given X value (in IEEE-754 format)
*  by 2^16. This will let us interpret the integer
*  as a fixed-point decimal as expected */
multiplier mul(
  .input_a      (ieee_x),     /* Provided input X */
  .input_b      (coeff),      /* 2^16 constant */
  .input_a_stb  (en),         /* Provided enable signal, shows X is ready */
  .input_b_stb  (1'b1),       /* Input B is a constant, always stable */
  .output_z_ack (fti_ack),    /* Receives ack from next block that output was read */
  .clk          (clk),        /* Clock */
  .rst          (rst),        /* Reset */
  .output_z     (ieee_e_mul), /* Output */
  .output_z_stb (mul_stb)     /* Tells next block that output is stable */
);

/* Converts the just-multiplied IEEE-754 X value to
*  32-bit integer representation */
float_to_int fti(
  .input_a      (ieee_e_mul),
  .input_a_stb  (mul_stb),
  .clk          (clk),
  .rst          (rst),
  .output_z     (x),
  .output_z_stb (fti_stb),
  .input_a_ack  (fti_ack)
);

/* Performs the CORDIC algorithm and light math to
*  get e^x, sinhx, coshx, all in fixed-point decimal
*  format */
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

/* Convert fixed-point decimal output of 
*  e^x to float. Note, this value is equal to
*  e^x * 2^16, still need to divide that out */
int_to_float epx_itf(
  .input_a      (epx),
  .input_a_stb  (nonieee_valid),
  .output_z_ack (epx_div_ack),
  .clk          (clk),
  .rst          (rst),
  .output_z     (epx_part),
  .output_z_stb (epx_itf_stb)
);

/* Divide e^x * 2^16 by
*  2^16 to put the desired value
*  of just e^x out */
divider epx_div(
  .input_a      (epx_part),
  .input_b      (coeff),
  .input_a_stb  (epx_itf_stb),
  .input_b_stb  (1'b1),
  .clk          (clk),
  .rst          (rst),
  .output_z     (ieee_epx),
  .output_z_stb (epx_stb), 
  .input_a_ack  (epx_div_ack)
);

/* Convert fixed-point decimal output of 
*  sinhx to float. Note, this value is equal to
*  sinhx * 2^16, still need to divide that out */
int_to_float sinhx_itf(
  .input_a      (sinhx),
  .input_a_stb  (nonieee_valid),
  .output_z_ack (sinhx_div_ack),
  .clk          (clk),
  .rst          (rst),
  .output_z     (sinhx_part),
  .output_z_stb (sinhx_itf_stb)
);

/* Divide sinhx * 2^16 by
*  2^16 to put the desired value
*  of just sinhx out */
divider sinhx_div(
  .input_a      (sinhx_part),
  .input_b      (coeff),
  .input_a_stb  (sinhx_itf_stb),
  .input_b_stb  (1'b1),
  .clk          (clk),
  .rst          (rst),
  .output_z     (ieee_sinhx),
  .output_z_stb (sinhx_stb), 
  .input_a_ack  (sinhx_div_ack)
);

/* Convert fixed-point decimal output of 
*  coshx to float. Note, this value is equal to
*  coshx * 2^16, still need to divide that out */
int_to_float coshx_itf(
  .input_a      (coshx),
  .input_a_stb  (nonieee_valid),
  .output_z_ack (coshx_div_ack),
  .clk          (clk),
  .rst          (rst),
  .output_z     (coshx_part),
  .output_z_stb (coshx_itf_stb)
);

/* Divide coshx * 2^16 by
*  2^16 to put the desired value
*  of just coshx out */
divider coshx_div(
  .input_a      (coshx_part),
  .input_b      (coeff),
  .input_a_stb  (coshx_itf_stb),
  .input_b_stb  (1'b1),
  .clk          (clk),
  .rst          (rst),
  .output_z     (ieee_coshx),
  .output_z_stb (coshx_stb),
  .input_a_ack  (coshx_div_ack)
);


always @ (posedge clk, rst) begin
  if (rst == 1'b1) begin
    coshx_stb_reg <= 1'b0;
    sinhx_stb_reg <= 1'b0;
    epx_stb_reg   <= 1'b0;
  end

  /* Lock in all stable values to registers 
  *  once they've been seen. */
  if (coshx_stb == 1'b1) coshx_stb_reg <= 1'b1;
  if (sinhx_stb == 1'b1) sinhx_stb_reg <= 1'b1;
  if (epx_stb   == 1'b1)   epx_stb_reg <= 1'b1;
end

assign coeff = 32'h47800000; // 2^16 in IEEE-754

/* Output is valid when all divided values have been registered stable */
assign valid = coshx_stb & sinhx_stb_reg & epx_stb_reg;

endmodule
