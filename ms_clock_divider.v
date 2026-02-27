module ms_clock_divider(cin, cout);

// Based on code from fpga4student.com
// cin is the input clock; if from the DE10-Lite,
// the input clock will be at 50 MHz
// The clock divider toggles cout every 25,000 cycles of the input clock

input cin;
output reg cout;

reg[31:0] count; 
parameter D = 32'd250000;

always @(posedge cin)
begin
   count <= count + 32'd1;
      if (count >= (D-1)) begin
         cout <= ~cout;
         count <= 32'd0;
      end
end
endmodule