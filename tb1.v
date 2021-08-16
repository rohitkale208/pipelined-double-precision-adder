`timescale 10 ns/10 ps

module tb1();
  

    reg clk;
	 wire Done, correct;
  
	 initial 
	 begin
	 
	 clk = 1'b0;
    
	 end

    checker2 chu(.clk(clk), .Done(done), .correct(correct));
	 
	 always 
    begin
    clk = 1'b1; 
    #1; // high for 20 * timescale = 20 ns

    clk = 1'b0;
    #1; // low for 20 * timescale = 20 ns
    end 

		 
endmodule