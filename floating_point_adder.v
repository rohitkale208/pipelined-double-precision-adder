module floating_point_adder (f_in1, f_in2, f_out, clk);

input [63:0] f_in1, f_in2;
output reg [63:0] f_out;
input clk;

//--------------exponent_comparator-----------/

reg [10:0] ex_exp1, ex_exp2, ex_exp_diff, ex_larger_exp, ex_smaller_exp;
reg ex_sign1, ex_sign2, ex_larger_sign, ex_smaller_sign;
reg [51:0] ex_mant1, ex_mant2, ex_larger_mant, ex_smaller_mant;

always @ (posedge clk)

begin

ex_sign1 = f_in1[63];
ex_sign2 = f_in2[63];

ex_exp1 = f_in1[62:52];
ex_exp2 = f_in2[62:52];

ex_mant1 = f_in1[51:0];
ex_mant2 = f_in2[51:0];

if(ex_exp1 >= ex_exp2)

 begin
 
  ex_exp_diff = ex_exp1 - ex_exp2;
  ex_larger_exp = ex_exp1;
  ex_smaller_exp = ex_exp2;
  ex_larger_mant = ex_mant1;
  ex_smaller_mant = ex_mant2;
  ex_larger_sign = ex_sign1;
  ex_smaller_sign = ex_sign2;
 
 end

else 

 begin
 
  ex_exp_diff = ex_exp2 - ex_exp1;
  ex_larger_exp = ex_exp2;
  ex_smaller_exp = ex_exp1;
  ex_larger_mant = ex_mant2;
  ex_smaller_mant = ex_mant1;
  ex_larger_sign = ex_sign2;
  ex_smaller_sign = ex_sign1;
 
 end

end
//------------------------------------------//

reg ea_sign1, ea_sign2;
reg [10:0] ea_larger_exp, ea_smaller_exp, ea_exp_diff;
reg [51:0] ea_larger_mant, ea_smaller_mant;
reg [52:0] ea_mant_larger, ea_mant_smaller;


//--------------exponent_adjuster-----------//
always @ (negedge clk)

begin

ea_sign1 = ex_larger_sign;
ea_sign2 = ex_smaller_sign;

ea_larger_exp = ex_larger_exp;
ea_smaller_exp = ex_smaller_exp;
ea_exp_diff = ex_exp_diff;

ea_larger_mant = ex_larger_mant;
ea_smaller_mant = ex_smaller_mant;

ea_mant_larger = {1'b1, ea_larger_mant};
ea_mant_smaller = {1'b1, ea_smaller_mant} >> ea_exp_diff;


end
//------------------------------------------//

reg ma_sign1, ma_sign2, ma_larger_sign, ma_smaller_sign;
reg [10:0] ma_exp1, ma_exp2;
reg [52:0] ma_mant1, ma_mant2;
reg [52:0] ma_larger_mant, ma_smaller_mant;

//--------------mantisa_comparator----------//
always @ (posedge clk)

begin

ma_sign1 = ea_sign1;
ma_sign2 = ea_sign2;

ma_exp1 = ea_larger_exp;
ma_exp2 = ea_larger_exp;

ma_mant1 = ea_mant_larger;
ma_mant2 = ea_mant_smaller;

if(ma_mant1 >= ma_mant2)

 begin
 
  ma_larger_mant = ma_mant1;
  ma_smaller_mant = ma_mant2;
  ma_larger_sign = ma_sign1;
  ma_smaller_sign = ma_sign2;
 
 end
 
else 

 begin
 
  ma_larger_mant = ma_mant2;
  ma_smaller_mant = ma_mant1;
  ma_larger_sign = ma_sign2;
  ma_smaller_sign = ma_sign1;
 
 end

end
//-------------------------------------------//

reg ad_sign1, ad_sign2, ad_sign_result;
reg [10:0] ad_exp1, ad_exp2, ad_exp_result;
reg [52:0] ad_mant1, ad_mant2;
reg [53:0] ad_mant_result;

//--------------adder------------------------//
always @ (negedge clk)

begin

ad_sign1 = ma_larger_sign;
ad_sign2 = ma_smaller_sign;
ad_exp1 = ma_exp1;
ad_exp2 = ma_exp2;
ad_mant1 = ma_larger_mant;
ad_mant2 = ma_smaller_mant;

if( ad_sign1 == ad_sign2 )
 
 begin
 
  ad_mant_result = ad_mant1 + ad_mant2;
  ad_exp_result = ad_exp1;
  ad_sign_result = ad_sign1;
 
 end
 
else 

 begin
 
  ad_mant_result = ad_mant1 - ad_mant2;
  ad_exp_result = ad_exp1;
  ad_sign_result = ad_sign1;
  
 end

end
//--------------------------------------------//

reg nom_sign, result_sign;
reg [10:0] nom_exp_result, result_exp;
reg [51:0] result_mant;
reg [53:0] nom_mant_result;
reg [52:0] nom_mant_52;
integer i;

//----------------normalizer------------------//
always @ (posedge clk)

begin

nom_sign = ad_sign_result;
nom_exp_result = ad_exp_result;
nom_mant_result = ad_mant_result;

if (nom_mant_result[53:52] == 2'b11)
 
 begin
 
  result_mant = nom_mant_result[52:1];
  result_exp = nom_exp_result + 1'b1;
  result_sign = nom_sign;
 
 end
 
if (nom_mant_result[53:52] == 2'b01)

 begin
 
  result_mant = nom_mant_result[51:0];
  result_exp = nom_exp_result;
  result_sign = nom_sign;
 
 end

 
if (nom_mant_result[53:52] == 2'b10)
 
 begin
 
  result_mant = nom_mant_result[52:1];
  result_exp = nom_exp_result + 1'b1;
  result_sign = nom_sign;
 
 end
 
if (nom_mant_result[53:52] == 2'b00)

 begin
  
  result_mant = {nom_mant_result[50:0], 1'b0};
  result_exp = nom_exp_result - 1'b1;
  result_sign = nom_sign;
 
 end
 
if (nom_mant_result == 0)

 begin
 
  f_out = 63'b0;
  
 end
 
 
else 

 f_out = {result_sign, result_exp, result_mant};
 
end
//--------------------------------------------//

endmodule














