module checker2(input clk,output reg Done,output correct);

	reg rst;
	reg [63:0] number1,number2;
	wire [63:0] result;
	wire ready;
	
	//parameter RDY=3'b000, waiting=3'b001, issue=3'b010,DONE=3'b011;
	
	
	reg [191:0] test [0:7];
	reg [63:0] expected_result;
	
	//reg [2:0] state= RDY;
	reg [2:0] icount=3'b000;
	reg [3:0] ocount=4'b0000;
	reg mistake;
	
	initial
	begin
		rst=1'b1;
		//Test cases
		test[0]={64'h4056800000000000, 64'h4056800000000000, 64'h4066800000000000};//90 + 90 = 180
		test[1]={64'h4049000000000000, 64'h4034000000000000, 64'h4051000000000000};//50 + 20 = 70
		test[2]={64'h4056800000000000, 64'h4056800000000000, 64'h4066800000000000};//90 + 90 = 180
		test[3]={64'h4049000000000000, 64'h4034000000000000, 64'h4051800000000000};//50 + 20 = 70
		test[4]={64'h4056800000000000, 64'h4056800000000000, 64'h4066800000000000};//90 + 90 = 180
		test[5]={64'h4049000000000000, 64'h4034000000000000, 64'h4051800000000000};//50 + 20 = 70
		test[6]={64'h4056800000000000, 64'h4056800000000000, 64'h4066800000000000};//90 + 90 = 180
		test[7]={64'h4049000000000000, 64'h4034000000000000, 64'h4051800000000000};//50 + 20 = 70
		
		//Done=1'b0;
		number1=test[0][191:128];
		number2=test[0][127:64];
		expected_result=test[0][63:0];
		mistake=1'b0;
		//correct=1'b0;
		
	end
	
	floating_point_adder fpa(.f_in1(number1), .f_in2(number2), .f_out(result), .clk(clk));
	
	always@(posedge clk) //Data input 
	begin
		if(icount<5)
		begin
			number1<=test[icount][191:128];
			number2<=test[icount][127:64];
			icount<=icount+1;
		end
	end

	always@(posedge clk)
	begin
		if(ocount<3)
		begin
			Done<=1'b0;
			ocount<=ocount+4'b0001;
			expected_result<=test[0][63:0];
			mistake<=1'b0;
		end
		else
		begin
			expected_result<=test[ocount-3][63:0];
			if(result!=expected_result)
		     mistake = Done ? mistake : 1'b1;		
			if(ocount==8)
			begin				
				Done<=1'b1;
				ocount<=4'b1000;	
			end
			else
			begin
				ocount<=ocount+4'b0001;
				Done<=1'b0;
			end	
		end
	end
	
	assign correct=(Done)?(~mistake):1'b0;
	
	
endmodule