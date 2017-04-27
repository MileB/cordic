module adder_tb;

reg     clk;
reg     rst;

reg     [31:0] input_a;
reg     input_a_stb;
wire    input_a_ack;

reg     [31:0] input_b;
reg     input_b_stb;
wire    input_b_ack;

wire    [31:0] output_z;
wire    output_z_stb;
reg     output_z_ack;


adder uut(
  .input_a      (input_a),
  .input_b      (input_b),
  .input_a_stb  (input_a_stb),
  .input_b_stb  (input_b_stb),
  .output_z_ack (output_z_ack),
  .clk          (clk),
  .rst          (rst),
  .output_z     (output_z),
  .output_z_stb (output_z_stb),
  .input_a_ack  (input_a_ack),
  .input_b_ack  (input_b_ack));

// Set initial values
initial begin
  clk           = 1'b0;
  rst           = 1'b0;
  input_a       = 32'b0;
  input_a_stb   = 1'b0;
  input_b       = 32'b0;
  input_b_stb   = 1'b0;
  output_z_ack  = 1'b0;
end

always begin
  clk = !clk;
  #5;
end

initial begin
  rst = 1'b1;
  #20;
  // Provide inputs for A and B
  rst = 1'b0;
  input_a = 32'h42490000; // 50.25
  input_b = 32'h42200000; // 40.00
  #10;
  // Tell ADDER that A and B are stable
  input_a_stb = 1'b1; 
  input_b_stb = 1'b1;
  #400;
  // Tell ADDER that we read the Z 
  output_z_ack = 1'b1;
end

endmodule // adder_tb
