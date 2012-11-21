module lr_onehot_gen (v, onehot_v);
   parameter WIDTH=4;

   input  [WIDTH-1:0] v;
   output [WIDTH-1:0] onehot_v;

   wire [WIDTH-1:0]   r_v, r_onehot_v, r_v_m1, r_v_xor;


   genvar w;
   generate 
      for (w=0; w<WIDTH; w=w+1) begin: reverse_input
	 assign r_v[WIDTH-1-w] = v[w];
      end
   endgenerate


   assign r_v_m1[WIDTH-1:0]     = r_v[WIDTH-1:0] - 1'b1;
   assign r_v_xor[WIDTH-1:0]    = r_v[WIDTH-1:0] ^ r_v_m1[WIDTH-1:0];
   assign r_onehot_v[WIDTH-1:0] = r_v[WIDTH-1:0] & r_v_xor[WIDTH-1:0];


   generate 
      for (w=0; w<WIDTH; w=w+1) begin: reverse_output
	 assign onehot_v[WIDTH-1-w] = r_onehot_v[w];
      end
   endgenerate
   
endmodule