module mux6_1(
input [31:0] hwdata_m_0,
input [31:0] hwdata_m_1,
input [31:0] hwdata_m_2,
input [31:0] hwdata_m_3,
input [31:0] hwdata_m_4,
input [31:0] hwdata_m_5,
input [2:0]  DMACActivedChannel,

output reg [31:0] hwdata_m

);

always @(*)
begin
	case(DMACActivedChannel)
		3'b000:hwdata_m=hwdata_m_0;
		3'b001:hwdata_m=hwdata_m_1;
		3'b010:hwdata_m=hwdata_m_2;
		3'b011:hwdata_m=hwdata_m_3;
		3'b100:hwdata_m=hwdata_m_4;
		3'b101:hwdata_m=hwdata_m_5;
	endcase
end



endmodule
