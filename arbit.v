module arbit(
	input clk,
	input rst_n,
	input [5:0] ShortTimeEnableChannel,//空闲输出7；优先级0最高，5最低
	output reg [2:0]  DMACActivedChannel,
	output reg        NextChannelReady
	);

//reg [2:0] DMACActivedChannel;
//reg		  NextChannelReady;
always @(posedge clk or negedge rst_n) 
begin 
	if(~rst_n) 
	begin
		 DMACActivedChannel<=0;
		 NextChannelReady<=0;
	end 

	else 
	begin
		if(ShortTimeEnableChannel==0)
		begin
			DMACActivedChannel<=0;
			NextChannelReady<=0;
		end
		 else if(ShortTimeEnableChannel[2:0]!=0)
		 	begin
		 		NextChannelReady<=1;
		 		case(ShortTimeEnableChannel[2:0])
		 			3'b001:DMACActivedChannel<=0;
		 			3'b011:DMACActivedChannel<=0;
		 			3'b101:DMACActivedChannel<=0;
		 			3'b111:DMACActivedChannel<=0;
		 			3'b010:DMACActivedChannel<=1;
		 			3'b110:DMACActivedChannel<=1;
		 			3'b100:DMACActivedChannel<=2;
		 		endcase
		 	end
		 	else if((ShortTimeEnableChannel[2:0]==0)&&(ShortTimeEnableChannel[5:3]!=0))
		 	begin
		 		NextChannelReady<=1;
		 		case (ShortTimeEnableChannel[5:3])
		 			3'b001:DMACActivedChannel<=3;
		 			3'b011:DMACActivedChannel<=3;
		 			3'b101:DMACActivedChannel<=3;
		 			3'b111:DMACActivedChannel<=3;
		 			3'b010:DMACActivedChannel<=4;
		 			3'b110:DMACActivedChannel<=4;
		 			3'b100:DMACActivedChannel<=5;
		 		endcase
		 	end
	end
end
endmodule