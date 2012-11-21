module rl_onehot_gen (v, onehot_v);
   parameter WIDTH=4;

   input  [WIDTH-1:0] v;
   output [WIDTH-1:0] onehot_v;

   wire [WIDTH-1:0]   v_m1, v_xor;

   assign v_m1[WIDTH-1:0]     = v[WIDTH-1:0] - 1'b1;
   assign v_xor[WIDTH-1:0]    = v[WIDTH-1:0] ^ v_m1[WIDTH-1:0];
   assign onehot_v[WIDTH-1:0] = v[WIDTH-1:0] & v_xor[WIDTH-1:0];

endmodule