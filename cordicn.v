// cordicn.v
// Team Seniors
// Used to calculate e^-x
// All values are fixed-point decimal
// with point in the exact center
module cordicn(
  x,
  clk,
  rst,
  en,
  lookup,
  y,
  valid);

input [31:0] x;
input clk;
input en;
input rst;
input [2047:0] lookup;

wire [63:0] tab [31:0];

output reg [63:0] y;
output reg valid;

reg [63:0] x_reg;
reg [4:0] counter;

reg [1:0] state;
  parameter E_IDLE  = 2'd0;
  parameter E_CALC  = 2'd1;

always @ (posedge clk, rst) begin
  // Reset condition, set all values to default
  if (rst == 1'b1) begin
    x_reg <= {16'h00, x, 16'h00};
    y <= 64'h0000_0001_0000_0000; // 1.00
    counter <= 4'b0;
    valid <= 1'b0;
    state <= E_IDLE;
  end

  case (state)
    // Idle state: Await enable signal
    E_IDLE: begin
      x_reg <= {16'h00, x, 16'h00};
      valid <= 1'b0;
      if (en == 1'b1)
        state <= E_CALC;
    end

    // Calculate using a cordic variant
    E_CALC: begin
      // Increment counter on next iteration
      counter <= counter+1;

      // Attempt to factor out this iteration's
      // table's value
      if (x_reg > tab[counter]) begin
        x_reg <= x_reg - tab[counter];

        // Logic to handle when table goes from >1 to nearly 1
        if (counter < 5'd16)
          y <= y >> (5'd16 - counter);
        else
          y <= y - (y >> (counter - 5'd14));
      end

      // Gone through all of the table, go back to idle
      // and show that y is valid answer
      if (counter == 5'd31) begin
        state <= E_IDLE;
        valid <= 1'b1;
      end 
    end
  endcase
end


// Put lookup table in to a more readable
// 2d array format using a generate statement
genvar i;
generate
  for (i=0; i<32; i=i+1) begin : U
    assign tab[31-i] = lookup[(i*64+63):i*64];
  end
endgenerate


endmodule
