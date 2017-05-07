module top_ieee_tb;

reg         clk;
reg         rst;
reg  [31:0] x;
reg         en;

wire [31:0] epx;
wire [31:0] sinhx;
wire [31:0] coshx;
wire        valid;

top_ieee uut
(
  .clk         (clk),
  .rst         (rst),
  .ieee_x      (x),
  .en          (en),
  .ieee_epx    (epx),
  .ieee_sinhx  (sinhx),
  .ieee_coshx  (coshx),
  .valid       (valid)
);

always begin
  clk = !clk;
  #5;
  if (valid == 1'b1)
    $finish;
end

initial begin
  clk =  1'b0;
  rst =  1'b1;
  x   = 32'b0;
  en  =  1'b0;

  #20;
  
  rst =  1'b0;
  en  =  1'b1;
  x   = 32'h40800000; // 4 in IEEE-754 format 
  
  #40;

  en = 1'b0;
end

endmodule
