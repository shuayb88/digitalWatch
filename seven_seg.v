module seven_seg(a,b,c,d,e,f,g,x3,x2,x1,x0);

input x3,x2,x1,x0;
output a,b,c,d,e,f,g;

assign a = (~x3 & ~x2 & ~x1 & x0) | (~x3 & x2 & ~x1 & ~x0) | (x3 & x2 & ~x1 & x0) | (x3 & ~x2 & x1 & x0);
assign b = (x3 & x2 & x1) | (x2 & x1 & ~x0) | (x3 & x1 & x0) | (x3 & x2 & ~x0) | (~x3 & x2 & ~x1 & x0);
assign c = (x3 & x2 & x1) | (x3 & x2 & ~x0) | (~x3 & ~x2 & x1 & ~x0);

assign d = (x2 & x1 & x0) | (x3 & ~x2 & x1 & ~x0) | (~x3 & x2 & ~x1 & ~x0) | (~x3 & ~x2 & ~x1 & x0);
assign e = (~x3 & x0) | (~x3 & x2 & ~x1) | (~x2 & ~x1 & x0);
assign f = (~x3 & ~x2 & x1) | (~x3 & ~x2 & x0) | (~x3 & x1 & x0) | (x3 & x2 & ~x1 & x0);
assign g = (~x3 & ~x2 & ~x1) | (~x3 & x2 & x1 & x0) | (x3 & x2 & ~x1 & ~x0);

endmodule

//I submitted this initially as part of Lab 2