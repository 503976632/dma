module decoder(
input FIFOReset,
input ReadDataEnable,
input WriteDataEnable,
input [2:0] DMACActivedChannel, 


output ReadDataEnable_0,
output ReadDataEnable_1,
output ReadDataEnable_2,
output ReadDataEnable_3,
output ReadDataEnable_4,
output ReadDataEnable_5,

output FIFOReset_0,
output FIFOReset_1,
output FIFOReset_2,
output FIFOReset_3,
output FIFOReset_4,
output FIFOReset_5,

output WriteDataEnable_0,
output WriteDataEnable_1,
output WriteDataEnable_2,
output WriteDataEnable_3,
output WriteDataEnable_4,
output WriteDataEnable_5


);


assign {WriteDataEnable_0,ReadDataEnable_0,FIFOReset_0} = (DMACActivedChannel==3'b000)?{WriteDataEnable,ReadDataEnable,FIFOReset}:3'b000;
assign {WriteDataEnable_1,ReadDataEnable_1,FIFOReset_1} = (DMACActivedChannel==3'b001)?{WriteDataEnable,ReadDataEnable,FIFOReset}:3'b000;
assign {WriteDataEnable_2,ReadDataEnable_2,FIFOReset_2} = (DMACActivedChannel==3'b010)?{WriteDataEnable,ReadDataEnable,FIFOReset}:3'b000;
assign {WriteDataEnable_3,ReadDataEnable_3,FIFOReset_3} = (DMACActivedChannel==3'b011)?{WriteDataEnable,ReadDataEnable,FIFOReset}:3'b000;
assign {WriteDataEnable_4,ReadDataEnable_4,FIFOReset_4} = (DMACActivedChannel==3'b100)?{WriteDataEnable,ReadDataEnable,FIFOReset}:3'b000;
assign {WriteDataEnable_5,ReadDataEnable_5,FIFOReset_5} = (DMACActivedChannel==3'b101)?{WriteDataEnable,ReadDataEnable,FIFOReset}:3'b000;


endmodule
