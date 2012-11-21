module register (clk, rst_n, update, new_value, curr_value);
   parameter WIDTH=4;
   parameter RESET_VALUE=4'd0;

   input clk, rst_n;
   
   output [WIDTH-1:0] curr_value;
   input [WIDTH-1:0]  new_value;
   input 	      update_value;

   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       curr_value[WIDTH-1:0] <= RESET_VALUE;
     else if (update)
       curr_value[WIDTH-1:0] <= new_value[WIDTH-1:0];
     else
       curr_value[WIDTH-1:0] <= curr_value[WIDTH-1:0];

endmodule

	 