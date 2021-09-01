
module dmac_ahbmaster(
                     // system HCLK
	              HCLK                                     ,
		      // system reset
                      HRESETn                                  ,
		      // AMBA AHB Interface
                      in_HGRANT_m                              ,
                      in_HREADY_m                              ,
                      in_HRESP_m                               ,
                      in_HTRANS_s_h                            ,
                      out_HBUSREQ_m                            ,
                      out_HLOCK_m                              ,
                      out_HTRANS_m                             ,
                      out_HADDR_m                              ,
                      out_HWRITE_m                             ,
                      out_HSIZE_m                              ,
                      out_HBURST_m                             ,
		      // AMBA APB Interface
                      out_PSELen                               ,
                      out_PENABLEen                            ,
                      out_PWRITEen                             ,
                      in_PSEL                                  ,
                      in_PENABLE                               ,
		      // next channel ready from arbit
                      in_NextChannelReady                      ,
	          // transfer control information from ahbslave
		  // include: 1.source address
		  //          2.destination address
		  //          3.number of data need to transfer
		  //          4.destination address whether to increased
		  //          5.source address whether to increased 
		  //          6.source size :byte halfword or word
		  //          7.destination size : byte halfword or word
		  //          8.destination burst size: 1 4 8 or 16
		  //          9.source burst size :1 4 8 or 16
		  //          10.transfer controlled by DMAC or periperal equipment
		  //          11.transfer flow: m2p, m2m,or p2m
                      in_SourceAddr                            , // 1.
                      in_DestAddr                              , // 2.
                      in_TransferSize                          , // 3.
                      in_DestinationInc                        , // 4.
                      in_SourceInc                             , // 5.
                      in_DestinationSize                       , // 6.
                      in_SourceSize                            , // 7.
                      in_DestinationBurst                      , // 8.
                      in_SourceBurst                           , // 9.
                      in_Control_DorP                          , // 10.
					  		 in_FlowControl                           , // 11.
		   // FSM enabled when req 
                      in_EnableDmac                            ,
		   // req APB bus from AMBA
                      in_BridgeReq                             ,
		   // for nand boot 
                      in_NandTransComplete                     ,
		   // for nand boot (del now)
                      in_bootnand                              ,
		   // response for APB bridge req
                      out_DmacAck                              ,
		   // signal to AMBA for APB bridge
                      out_Bridgeing                            ,
		   // after a transfer
                      out_FIFOReset                            ,
		   // for INTC to slave
                      out_AHBResponseError                     ,
		   // register the transfer information after a B TRANs
		      // 1. source addr
		      // 2. dest addr
		      // 3. num of data need to trans
                      out_CurrentSourceAddrressLog             , // 1.
                      out_CurrentDestinationAddrressLog        , // 2.
                      out_CurrentChannelTransferSizeLog        , // 3.
		   // after a B trans cntrl signal 
		      // 1, for src addr
                      out_WriteSourceAddressRegisterAgain      ,
		      // 2. for dest sddr
                      out_WriteDestinationAddressRegisterAgain ,
		      // 3. for num of data
                      out_WriteTransferSizeAgain               ,
		      // 4. to start a trans again
                      out_RequestNextChannel                   ,
		   // ctrl signal for fifo data 
		      // 1. for read
                      out_WriteDataEnable                      ,
		      // 2. for write
                      out_ReadDataEnable                       ,
		   // to slave trans again
                      out_TransStart                           ,
		   // to slave INTC 
                      out_TransferCompleted                    ,
		   // to APB If for timing
                      out_DmacState                            ,
		   // to fifo sel data from
                      out_SourceBus                            ,
		   // LLI index
                      in_Descriptor_Index                      ,
		   //  for LLI load
                      out_read_en                              ,
		   // for LLI load
                      out_descriptor_counter                   ,
		   // for external req
                      in_external_req                          ,
		   // response for external req
		      // 1.
                      out_DMAC_EXTERNAL_ACK_1                  ,
		      // 2.
                      out_DMAC_EXTERNAL_ACK_2
                      );
                      
`define	  DMAC_IDLE				5'd0
`define	  SOURCE_PREPARE 		5'd1
`define	  SOURCE_APB_PREPARE 	5'd2
`define	  SOURCE_AHB_PREPARE 	5'd3
`define   DEST_PREPARE 			5'd4
`define   DEST_APB_PREPARE 		5'd5
`define   DEST_AHB_PREPARE 		5'd6
`define   SOURCE_APB_SETUP 		5'd7
`define   SOURCE_APB_ENABLE 	5'd8
`define   SOURCE_AHB_TRANSFER 	5'd9
`define   HALF 					5'd10
`define   DEST_APB_SETUP 		5'd11
`define   DEST_APB_ENABLE 		5'd12
`define   DEST_AHB_TRANSFER 	5'd13
`define   END 					5'd14
`define   LOOP_RELOAD			5'd15
`define 	DESCRIPTOR_PREPARE 5'd16
`define 	DESCRIPTOR_WAIT	5'd17
`define 	DESCRIPTOR_TRANSFER 5'd18
`define 	DESCRIPTOR_END 5'd19

`define DMAC_SINGLE  3'b000
`define DMAC_INCR    3'b001
`define DMAC_INCR4   3'b011
`define DMAC_INCR8   3'b101
`define DMAC_INCR16  3'b111

`define DMAC_BYTE 3'b000
`define DMAC_HALFWORD 3'b001
`define DMAC_WORD 3'b010

`define MIN_AVAILABLE_ADDRESS 1'b0
`define ADDR_UART_1   32'd0
`define ADDR_UART_2	32'd1
`define ADDR_SPI 32'd2
`define ADDR_USB  32'd3
`define ADDR_MMC 32'd4
`define ADDR_AC97 32'd5
`define ADDR_EMI 32'd6

`define APB_BUS 1'b0
`define AHB_BUS 1'b1

`define NONSEQ 2'b01
`define SEQ 2'b10

`define DMAC_OKAY 2'b01
                      
//================================================================
//==================   input and output   ========================
//================================================================
// system HCLK
input            HCLK                                         ;
// system reset
input            HRESETn                                      ;
// AMBA AHB Interface
input            in_HGRANT_m                                  ;
input            in_HREADY_m                                  ;
input   [1:0]    in_HRESP_m                                   ;
input   [1:0]    in_HTRANS_s_h                                ;
output           out_HBUSREQ_m                                ;
output           out_HLOCK_m                                  ;
output  [1:0]    out_HTRANS_m                                 ;
output  [31:0]   out_HADDR_m                                  ;
output           out_HWRITE_m                                 ;
output  [2:0]    out_HSIZE_m                                  ;
output  [2:0]    out_HBURST_m                                 ;
   // transfer control information from ahbslave
	 // include: 1.source address
	 //          2.destination address
   //          3.number of data need to transfer
	 //          4.destination address whether to increased
	 //          5.source address whether to increased 
	 //          6.source size :byte halfword or word
	 //          7.destination size : byte halfword or word
	 //          8.destination burst size: 1 4 8 or 16
	 //          9.source burst size :1 4 8 or 16
	 //          10.transfer controlled by DMAC or periperal equipment
	 //          11.transfer flow: m2p, m2m,or p2m
input   [31:0]   in_SourceAddr                                ; // 1.
input   [31:0]   in_DestAddr                                  ; // 2.
input   [11:0]   in_TransferSize                              ; // 3.
input            in_DestinationInc                            ; // 4.
input            in_SourceInc                                 ; // 5.
input   [2:0]    in_DestinationSize                           ; // 6.
input   [2:0]    in_SourceSize                                ; // 7.
input   [2:0]    in_DestinationBurst                          ; // 8.
input   [2:0]    in_SourceBurst                               ; // 9.
input            in_Control_DorP                              ; // 10.
input   [1:0]    in_FlowControl                               ; // 11.
// next channel ready from arbit
input            in_NextChannelReady                          ;
// FSM enabled when req 
input            in_EnableDmac                                ;
// req APB bus from AMBA
input            in_BridgeReq                                 ;
// AMBA APB IF 
input            in_PSEL                                      ;
input            in_PENABLE                                   ;
output           out_PSELen                                   ;
output           out_PENABLEen                                ;
output           out_PWRITEen                                 ;
// for nand boot 
input            in_NandTransComplete                         ;
// for nand boot (del now)
input            in_bootnand                                  ; 
// LLi index
input   [31:0]   in_Descriptor_Index                          ;
// external req 
input   [1:0]    in_external_req                              ;
// for load LLi
output           out_read_en                                  ;
// for load LLi
output  [2:0]    out_descriptor_counter                       ;
// external req 1. 2 .
output           out_DMAC_EXTERNAL_ACK_1                      ;
output           out_DMAC_EXTERNAL_ACK_2                      ;
// ack signal for APB bridge 
output           out_DmacAck                                  ;
// fifo reset after a trans
output           out_FIFOReset                                ;
// for error INT
output           out_AHBResponseError                         ;
// register the transfer information after a B TRANs
		      // 1. source addr
		      // 2. dest addr
		      // 3. num of data need to trans
output  [31:0]   out_CurrentSourceAddrressLog                 ; // 1.
output  [31:0]   out_CurrentDestinationAddrressLog            ; // 2.
output  [11:0]   out_CurrentChannelTransferSizeLog            ; // 3.
 // after a B trans cntrl signal 
		      // 1. for src addr
output           out_WriteSourceAddressRegisterAgain          ;
                      // 2. for dest addr 
output           out_WriteDestinationAddressRegisterAgain     ;
                      // 3. for num addr
output           out_WriteTransferSizeAgain                   ;
// req the next channel
output           out_RequestNextChannel                       ;
// sinal for fifo to read or write 
output           out_WriteDataEnable                          ;
output           out_ReadDataEnable                           ;
// signal to slave to start another trans
output           out_TransStart                               ;
// signal to slave for INT
output           out_TransferCompleted                        ;
// to APB If for timing cntrl
output  [4:0]    out_DmacState                                ;
// to fifo to sel data from 
output           out_SourceBus                                ;
// indicate bridge is for DMAC 
output           out_Bridgeing                                ;
//==================================================================


wire [31:0]   in_Descriptor_Index                             ;
wire [1:0]    in_FlowControl                                  ; 
wire [1:0]    in_external_req                                 ;
wire [11:0]   exceedboundaryflag                              ;
reg           out_read_en                                     ;
reg  [2:0]    out_descriptor_counter                          ;
reg  [4:0]    sourceloop                                      ;
reg  [4:0]    destloop                                        ;
reg  [4:0]    sourceloop_r                                    ;
reg  [4:0]    destloop_r                                      ;
reg  [11:0]   sourcetransnum                                  ;   
reg  [11:0]   desttransnum                                    ;    
reg           out_DMAC_EXTERNAL_ACK_1                         ;
reg           out_DMAC_EXTERNAL_ACK_2                         ; 


wire        AllowTransmitNext                                 ;
wire        ResetShakeHandArbiter                             ;
wire [31:0] out_HADDR_m                                       ;
wire [4:0]  out_DmacState                                     ;
wire        out_SourceBus                                     ;
//wire        out_DestBus                                       ;
wire        out_Bridgeing                                     ;
reg [2:0]     SourceBurstType                                 ;
reg [2:0]     DestBurstType                                   ;
reg [13:0]    DestinationTransferSize                         ;
reg           SourceBus                                       ;
reg           DestBus                                         ;
reg [4:0]     DmacState                                       ;   
reg           out_HBUSREQ_m                                   ;
wire          out_HLOCK_m                                     ;
reg [1:0]     out_HTRANS_m                                    ;
reg           out_HWRITE_m                                    ;
reg           out_PSELen                                      ;
reg           out_PENABLEen                                   ;
reg           out_PWRITEen                                    ;
reg           out_FIFOReset                                   ;
reg           out_AHBResponseError                            ;
reg  [31:0]   out_CurrentSourceAddrressLog                    ;
reg  [31:0]   out_CurrentDestinationAddrressLog               ;
reg  [11:0]   out_CurrentChannelTransferSizeLog               ;
reg           out_WriteSourceAddressRegisterAgain             ;
reg           out_WriteDestinationAddressRegisterAgain        ;
reg           out_WriteTransferSizeAgain                      ;
reg [13:0]    CurrentChannelTransferSize                      ;
reg [31:0]    CurrentTransferAddress                          ;
reg           out_RequestNextChannel                          ;
reg [31:0]    TransferAddr                                    ;
reg           out_WriteDataEnable                             ;
reg           out_ReadDataEnable                              ;
reg           out_TransStart                                  ;
reg [2:0]     out_HSIZE_m                                     ;
reg [2:0]     out_HBURST_m                                    ; 


reg           out_TransferCompleted                           ;
reg           TransferCompleted                               ;
reg           DelayPENABLE                                    ;
reg           DelayPSEL                                       ;
reg           out_DmacAck                                     ;
reg           HLOCK                                           ; 
reg           cnt_loop                                        ;

// assign reg to wire
  assign out_DmacState = DmacState ;
  assign out_SourceBus = SourceBus ;
// signal indicate slave is ready and master can use the bus
  assign AllowTransmitNext = (in_HREADY_m == 1) & (in_HGRANT_m == 1) ;
// signal to AMBA APB Bridge
  assign out_Bridgeing = (in_BridgeReq & out_DmacAck) ? 1'b1 : 1'b0 ;
// for nand boot (del now)
  assign out_HLOCK_m = ((~in_NandTransComplete) && in_bootnand)? 1'b1 : HLOCK ;  //  nand flash
//======================= For Exceed 1K Boundary ===========================
// judge the information about whether to exceed 1 k boundary 

assign exceedboundaryflag = {in_SourceBurst        , // source burst size :1 4 8 or 16
                             in_SourceSize         , // source size :byte halfword or word
                             in_DestinationBurst   , // destination burst size: 1 4 8 or 16
                             in_DestinationSize      // destination size : byte halfword or word
                             }                     ;
always @ (in_SourceBurst           or
          in_SourceAddr            or
          in_TransferSize          or
          in_DestinationBurst      or
          in_DestAddr              or
          in_FlowControl           or
          DestinationTransferSize  or
          exceedboundaryflag       or
          desttransnum             or
          sourcetransnum
          )
  begin
    sourceloop      =  5'b0        ;  // src Burst to Single cnt
    destloop        =  5'b0        ;  // dest Burst to Single cnt
    case(exceedboundaryflag) // Source           Destination
      12'b000_000_000_000:   // Single Byte      Single Byte
      // never exceed 1K boundary
        begin
          SourceBurstType = `DMAC_SINGLE ;
          DestBurstType   = `DMAC_SINGLE ;
        end
      12'b000_001_000_001:   // Single Halfword  Single Halfword 
       // never exceed 1K boundary 
        begin
          SourceBurstType = `DMAC_SINGLE ;  
          DestBurstType   = `DMAC_SINGLE ;
        end
      12'b000_010_000_010:   // Single Word      Single Word
       // never exceed 1K boundary
        begin
          SourceBurstType = `DMAC_SINGLE ;
          DestBurstType   = `DMAC_SINGLE ;
        end
      12'b000_010_011_000:   // Single word      Burst4 byte
        begin
	 // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0] < (in_DestAddr[9:0] + 10'b00_0000_0011)))
            begin
              SourceBurstType = `DMAC_SINGLE ; 
              if(DestinationTransferSize < 4)  // when Htrans == 1
                DestBurstType = `DMAC_INCR   ;
              else
                DestBurstType = `DMAC_INCR4  ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              DestBurstType   = `DMAC_SINGLE ; 
              if(DestinationTransferSize < 4) // when Htrans == 1
                destloop        =  desttransnum[4:0] ;
              else
                destloop        =  5'b0011     ;
            end
        end
      12'b011_000_000_010:   // Burst4 Byte      Single Word
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_0011)))
            begin
              DestBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 4)  // when Htrans == 1
                SourceBurstType = `DMAC_INCR   ;
              else
                SourceBurstType = `DMAC_INCR4  ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              DestBurstType   = `DMAC_SINGLE ;
              if(in_TransferSize < 4) // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ; 
                else
                  sourceloop      =  5'b0011     ;
            end
        end
      12'b011_000_011_000:   // Burst4 Byte      Burst4 Byte
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_0011)))
            begin
              if(in_TransferSize < 4) // when Htrans == 1
                SourceBurstType = `DMAC_INCR  ;
              else
                SourceBurstType = `DMAC_INCR4 ;
            end
          else
            begin 
               if(in_TransferSize < 4) // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ;
                else
                  sourceloop      = 5'b0011      ;
              SourceBurstType = `DMAC_SINGLE ;
            end
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_0011)))
            begin
	    // judge address whether to exceed the 1K boundary 
	    // when the transfer Object is not APB peripheral  
              if(DestinationTransferSize < 4) // when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR4 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE ; 
              if(DestinationTransferSize < 4) // when Htrans == 1
                destloop        = desttransnum[4:0]  ;
              else
                destloop        = 5'b0011      ; 
            end
        end
      12'b011_001_011_001:   // Burst4 Halfword  Burst4 Halfword
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_0111)))
            begin
              if(in_TransferSize < 4) // when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR4 ;
            end
          else
            begin
                if(in_TransferSize < 4) // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ;
                else
                  sourceloop      = 5'b0011      ;
              SourceBurstType = `DMAC_SINGLE ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_0111)))
            begin
              if(DestinationTransferSize < 4) // when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR4 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE ; 
              if(DestinationTransferSize < 4) // when Htrans == 1
                destloop        = desttransnum[4:0]  ;
              else
                destloop        = 5'b0011        ;  
            end
        end
      12'b011_001_101_000:  // Burst4 Halfword   Burst8 Byte
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_0111)))
            begin
              if(in_TransferSize < 4) // when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR4 ;
            end
          else
            begin
               if(in_TransferSize < 4) // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ;
                else
                  sourceloop      = 5'b0011        ;
              SourceBurstType = `DMAC_SINGLE   ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_0111)))
            begin
              if(DestinationTransferSize < 8) // when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR8 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE   ; 
              if(DestinationTransferSize < 8) // when Htrans == 1
                destloop        = desttransnum[4:0]  ; 
              else
                destloop        =  5'b0111       ; 
            end
        end
      12'b011_010_011_010:   //Burst4 Word Burst4 Word
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
            begin
              if(in_TransferSize < 4) // when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR4 ;
            end
          else
            begin 
               SourceBurstType = `DMAC_SINGLE ;
               if(in_TransferSize < 4) // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ;
                else
                  sourceloop      = 5'b0011      ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral  
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
            begin
              if(DestinationTransferSize < 4) // when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR4 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE ;
              if(DestinationTransferSize < 4) // when Htrans == 1
                destloop        = desttransnum[4:0]  ;
              else
                destloop        = 5'b0011      ; 
            end
        end
      12'b011_010_101_001:   //Burst4 Word Burst8 Halfword
        begin
	  // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
            begin
              if(in_TransferSize < 4) // when Htrans == 1
                  SourceBurstType = `DMAC_INCR ;
              else
                  SourceBurstType = `DMAC_INCR4 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 4) // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ; 
                else
                  sourceloop      =  5'b0011     ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
            begin
              if(DestinationTransferSize < 8) // when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR8 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE ;
              if(DestinationTransferSize < 8) // when Htrans == 1
                destloop        = desttransnum[4:0]  ; 
              else
                destloop        =  5'b0111     ;
            end
        end
      12'b011_010_111_000:   //Burst4 Word Burst16 Byte
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
            begin
              if(in_TransferSize < 4) // when Htrans == 1
                  SourceBurstType = `DMAC_INCR ;
              else
                  SourceBurstType = `DMAC_INCR4 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 4) // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ; 
                else
                  sourceloop      =  5'b0011     ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
            begin
              if(DestinationTransferSize < 16)// when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR16 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE ;
              if(DestinationTransferSize < 16)// when Htrans == 1
                destloop        = desttransnum[4:0]  ; 
              else
                destloop        =  5'b1111     ;
            end
        end
      12'b101_000_101_000:   //Burst8 Byte Burst8 Byte
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_0111)))
            begin
              if(in_TransferSize < 8)// when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR8 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 8)          // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ;
                else
                  sourceloop      = 5'b0111      ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_0111)))
            begin
               if(DestinationTransferSize < 8)// when Htrans == 1
                 DestBurstType   = `DMAC_INCR  ;
               else
                 DestBurstType   = `DMAC_INCR8 ;
             end
          else
            begin
              if(DestinationTransferSize < 8) // when Htrans == 1
                destloop        = desttransnum[4:0]  ; 
              else
                destloop        = 5'b0111      ;
              DestBurstType   = `DMAC_SINGLE ;
            end
        end
      12'b101_000_011_001:    // Burst8 Byte  Burst4 Halfword
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
         if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_0111)))
           begin
             if(in_TransferSize < 8)// when Htrans == 1
               SourceBurstType = `DMAC_INCR  ;
             else
               SourceBurstType = `DMAC_INCR8 ;
           end
         else
           begin
             SourceBurstType = `DMAC_SINGLE ;
             if(in_TransferSize < 8) // when Htrans == 1
                 sourceloop      =  sourcetransnum[4:0] ;
               else
                 sourceloop      =  5'b0111     ;
           end
	   // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
         if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_0111)))
            begin
              if(DestinationTransferSize < 4)// when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR4 ;
            end
          else
            begin
              if(DestinationTransferSize < 4) // when Htrans == 1
                destloop        = desttransnum[4:0]  ;   
              else
                destloop        = 5'b0011      ;
              DestBurstType   = `DMAC_SINGLE ;
            end
        end
      12'b101_001_101_001:   //Burst8 Halfword  Burst8 Halfword
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
            begin
              if(in_TransferSize < 8)// when Htrans == 1
                SourceBurstType = `DMAC_INCR  ;
              else
                SourceBurstType = `DMAC_INCR8 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 8) // when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ;                         
                else
                  sourceloop      = 5'b0111      ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
             begin
               if(DestinationTransferSize < 8)// when Htrans == 1
                 DestBurstType   = `DMAC_INCR  ;
               else
                 DestBurstType   = `DMAC_INCR8 ;
             end
          else
            begin
              if(DestinationTransferSize < 8)// when Htrans == 1
                destloop        = desttransnum[4:0]  ;
              else
                destloop        = 5'b0111      ;
              DestBurstType   = `DMAC_SINGLE ;
            end
        end
      12'b101_001_111_000:    //Burst8 Halfword Burst16 Byte
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
             begin
               if(in_TransferSize < 8)// when Htrans == 1
                 SourceBurstType = `DMAC_INCR  ;                                   
               else
                 SourceBurstType = `DMAC_INCR8 ;
             end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ; 
              if(in_TransferSize < 8)// when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ;    
                else
                  sourceloop      = 5'b0111      ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
             begin
               if(DestinationTransferSize < 16)// when Htrans == 1
                 DestBurstType   = `DMAC_INCR   ;
               else
                 DestBurstType   = `DMAC_INCR16 ;
             end
           else
             begin
               DestBurstType   = `DMAC_SINGLE   ;
               if(DestinationTransferSize < 16)  // when Htrans == 1
                 destloop        = desttransnum[4:0]  ;
               else
                 destloop        =  5'b1111       ;
             end
         end
      12'b101_001_011_010:  //Burst8 Halfword Burst4 Word
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
            begin
              if(in_TransferSize < 8)// when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR8 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE   ;
              if(in_TransferSize < 8)// when Htrans == 1
                  sourceloop      =  sourcetransnum[4:0] ;
                else
                  sourceloop      =  5'b0111       ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
            begin
              if(DestinationTransferSize < 4)// when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR4 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE ;
              if(DestinationTransferSize < 4)// when Htrans == 1
                destloop        = desttransnum[4:0]  ;
              else
                destloop        = 5'b0011      ; 
            end
        end                                                                                                        
      12'b101_010_101_010:  //Burst8 Word Burst8 Word
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
         if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0001_1111)))
           begin
             if(in_TransferSize < 8)// when Htrans == 1
               SourceBurstType = `DMAC_INCR ;
             else
               SourceBurstType = `DMAC_INCR8 ;
           end
         else
           begin
             SourceBurstType = `DMAC_SINGLE ;
             if(in_TransferSize < 8)// when Htrans == 1
                 sourceloop      =  sourcetransnum[4:0] ;
               else
                 sourceloop      = 5'b0111      ;
           end
	   // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
         if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0001_1111)))
           begin
             if(DestinationTransferSize < 8)// when Htrans == 1
               DestBurstType   = `DMAC_INCR ;
             else
               DestBurstType   = `DMAC_INCR8 ;
           end
         else
           begin
             if(DestinationTransferSize < 8)// when Htrans == 1
               destloop        = desttransnum [4:0] ;
             else
               destloop        = 5'b0111     ;
             DestBurstType   = `DMAC_SINGLE ;
           end
       end
     12'b101_010_111_001:    // Burst8 Word Burst16 Halfword
       begin
       // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
         if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0001_1111)))
           begin
             if(in_TransferSize < 8)// when Htrans == 1
               SourceBurstType = `DMAC_INCR ;
             else
               SourceBurstType = `DMAC_INCR8 ;
           end
         else
           begin
             SourceBurstType = `DMAC_SINGLE ;
             if(in_TransferSize < 8)    // when Htrans == 1
                 sourceloop      =  sourcetransnum[4:0] ; 
               else
                 sourceloop      = 5'b0111      ;
           end
	   // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
         if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0001_1111)))
           begin
            if(DestinationTransferSize < 16)// when Htrans == 1
              DestBurstType   = `DMAC_INCR ;
            else
              DestBurstType   = `DMAC_INCR16 ;
           end
         else
           begin
             DestBurstType   = `DMAC_SINGLE ;
             if(DestinationTransferSize < 16)  // when Htrans == 1
               destloop        = desttransnum [4:0] ; 
             else
               destloop        = 5'b1111      ;
           end
        end
      12'b111_000_111_000:    // Burst16 Byte Burst16 Byte
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
            begin
              if(in_TransferSize < 16)// when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR16 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 16)// when Htrans == 1
                  sourceloop      =  sourcetransnum  [4:0]   ;
                else
                  sourceloop      =  5'b1111 ; 
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
             begin
              if(DestinationTransferSize < 16)// when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR16 ;
            end
          else
            begin
            if(DestinationTransferSize < 16)  // when Htrans == 1
              destloop        =  desttransnum[4:0] ;
             else
               destloop        =  5'b1111     ; 
              DestBurstType   = `DMAC_SINGLE ;
            end
        end
      12'b111_000_101_001:   // Burst16 Byte Burst8 Halfword
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
            begin
              if(in_TransferSize < 16)// when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR16 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 16) // when Htrans == 1
                  sourceloop      = sourcetransnum[4:0]      ; 
                else
                  sourceloop      = 5'b1111      ;  
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
            begin
              if(DestinationTransferSize < 8)// when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR8 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE   ;
              if(DestinationTransferSize < 8)// when Htrans == 1
                destloop      =  desttransnum[4:0]       ; 
              else
                destloop      =  5'b0111       ; 
            end
        end
      12'b111_000_011_010:    // Burst16 Byte Burst4 Word
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0000_1111)))
            begin
              if(in_TransferSize < 16)// when Htrans == 1
                SourceBurstType = `DMAC_INCR   ;
              else
                SourceBurstType = `DMAC_INCR16 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 16) // when Htrans == 1
                  sourceloop      = sourcetransnum [4:0]     ;  
                else
                  sourceloop      = 5'b1111      ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0000_1111)))
            begin
              if(DestinationTransferSize < 4)// when Htrans == 1
                DestBurstType   = `DMAC_INCR  ;
              else
                DestBurstType   = `DMAC_INCR4 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE   ;
              if(DestinationTransferSize < 4)// when Htrans == 1
                destloop      =  desttransnum[4:0]       ;
              else
                destloop      =  5'b0011       ; 
            end
        end
      12'b111_001_111_001:   //Burst16 Halfword Burst16 Halfword
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0001_1111)))
            begin
              if(in_TransferSize < 16)// when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR16 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 16)// when Htrans == 1
                  sourceloop      = sourcetransnum[4:0]     ;
                else
                  sourceloop      = 5'b1111      ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0001_1111)))
            begin
              if(DestinationTransferSize < 16)// when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR16 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE   ;
              if(DestinationTransferSize < 16)// when Htrans == 1
                destloop      =  desttransnum [4:0]      ;
              else
                destloop      =  5'b1111       ; 
            end
        end
      12'b111_001_101_010:    // Burst16 Halfword Burst8 Word
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0001_1111)))
            begin
              if(in_TransferSize < 16)// when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR16 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 16)// when Htrans == 1
                  sourceloop      = sourcetransnum[4:0]     ;
                else
                  sourceloop      = 5'b1111      ;    
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0001_1111)))
            begin
              if(DestinationTransferSize < 8)// when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR8 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE   ;
              if(DestinationTransferSize < 8)// when Htrans == 1
                destloop      =  desttransnum [4:0]      ;
              else
                destloop      =  5'b0111       ;
            end
        end
      12'b111_010_111_010:    // Burst16 Word Burst16 Word
        begin
	// judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[1]?1'b1:(in_SourceAddr[9:0] < (in_SourceAddr[9:0] + 10'b00_0011_1111)))
            begin
              if(in_TransferSize < 16)// when Htrans == 1
                SourceBurstType = `DMAC_INCR ;
              else
                SourceBurstType = `DMAC_INCR16 ;
            end
          else
            begin
              SourceBurstType = `DMAC_SINGLE ;
              if(in_TransferSize < 16)// when Htrans == 1
                  sourceloop      = sourcetransnum[4:0]      ;
                else
                  sourceloop      = 5'b1111      ;
            end
	    // judge address whether to exceed the 1K boundary 
	 // when the transfer Object is not APB peripheral
          if(in_FlowControl[0]?1'b1:(in_DestAddr[9:0]   < (in_DestAddr[9:0]   + 10'b00_0011_1111)))
            begin
              if(DestinationTransferSize < 16)// when Htrans == 1
                DestBurstType   = `DMAC_INCR ;
              else
                DestBurstType   = `DMAC_INCR16 ;
            end
          else
            begin
              DestBurstType   = `DMAC_SINGLE   ;
              if(DestinationTransferSize < 16)// when Htrans == 1
                destloop      =  desttransnum [4:0]      ;
              else
                destloop      =  5'b1111       ;
            end
        end
      default:
        begin
          SourceBurstType  =  in_SourceBurst        ;
          DestBurstType    =  in_DestinationBurst   ;
        end
      endcase
  end
//=====================================================================================================================

//========================== SEL BUS APB or AHB ========================
  //choice the amba bus : apb or ahb
  always @ (in_SourceAddr  or
            in_DestAddr
            )
    begin
      // for src peripheral
      case (in_SourceAddr[31:`MIN_AVAILABLE_ADDRESS])
        `ADDR_UART_1 : SourceBus = `APB_BUS   ;
        `ADDR_UART_2 : SourceBus = `APB_BUS   ;
        `ADDR_SPI    : SourceBus = `APB_BUS   ;
        `ADDR_USB    : SourceBus = `APB_BUS   ;
        `ADDR_MMC    : SourceBus = `APB_BUS   ;
        `ADDR_AC97   : SourceBus = `APB_BUS   ;
        `ADDR_EMI    : SourceBus = `AHB_BUS   ;
         default     : SourceBus = `AHB_BUS   ;
      endcase
      // for dest peripheral
      case (in_DestAddr[31:`MIN_AVAILABLE_ADDRESS])
        `ADDR_UART_1 : DestBus = `APB_BUS   ;
        `ADDR_UART_2 : DestBus = `APB_BUS   ;
        `ADDR_SPI    : DestBus = `APB_BUS   ;
        `ADDR_USB    : DestBus = `APB_BUS   ;
        `ADDR_MMC    : DestBus = `APB_BUS   ;
        `ADDR_AC97   : DestBus = `APB_BUS   ;
        `ADDR_EMI    : DestBus = `AHB_BUS   ;
         default     : DestBus = `AHB_BUS   ;
      endcase
    end

//==============================================================


//============== Tell Arbiter When to Calculate another Req =============
  assign ResetShakeHandArbiter = (DmacState != `DMAC_IDLE );

  //Shake Hand Signal for DMAC Arbiter
  always @(posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn)
        out_RequestNextChannel<= 0;  // clear the register when system Reset low 
      else
        if(in_EnableDmac) // one is start ,another can calculate
          begin
            if (ResetShakeHandArbiter == 0)   // DmacState == `IDEL
              out_RequestNextChannel <= 1;
            else
              out_RequestNextChannel <= 0;    // clear when trans
          end
        else
          out_RequestNextChannel <= 0;
    end
//================================================================

//===================== Deal the APB signal to APB if ==================
  always @ (posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn)
        begin
          //HREADY        <= 1'b0  ;
          //HGRANT        <= 1'b0  ;
          DelayPSEL     <= 1'b0  ; // clear the register when system Reset low 
          DelayPENABLE  <= 1'b0  ;
        end
      else
        begin
          //HREADY        <= in_HREADY_m  ;
          //HGRANT        <= in_HGRANT_m  ; // delay one cycle for appropriate timing
          DelayPSEL     <= in_PSEL      ;
          DelayPENABLE  <= in_PENABLE   ;
        end
    end
  //====================================================================
  
  
  //==================== DMAC Control Transfer FSM =======================
  
  always @ (posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn)             // clear the register when system Reset low 
        begin
          DmacState                                 <= `DMAC_IDLE ;
          HLOCK                                     <= 1'b0       ;
          out_HBUSREQ_m                             <= 1'b1       ;
          out_DmacAck                               <= 1'b0       ;
          out_read_en                               <= 1'b0       ;          
          out_descriptor_counter                    <= 3'b0       ;  
          out_HTRANS_m                              <= 2'b00      ;
          out_HWRITE_m                              <= 1'b1       ;
          out_PSELen                                <= 1'b0       ;
          out_PENABLEen                             <= 1'b0       ;
          out_PWRITEen                              <= 1'b0       ;
          out_FIFOReset                             <= 1'b1       ;
          out_TransStart                            <= 1'b0       ;
          out_HSIZE_m                               <= 3'b0       ;
          out_HBURST_m                              <= 3'b0       ;
          TransferAddr                              <= 32'b0      ;
          DestinationTransferSize                   <= 12'b0      ;
          out_CurrentSourceAddrressLog              <= 32'b0      ;
          out_CurrentDestinationAddrressLog         <= 32'b0      ;
          CurrentChannelTransferSize                <= 12'b0      ;
          CurrentTransferAddress                    <= 32'b0      ;
          out_CurrentChannelTransferSizeLog         <= 12'b0      ;
          out_WriteTransferSizeAgain                <= 1'b0       ;
          out_AHBResponseError                      <= 1'b0       ;
          out_WriteSourceAddressRegisterAgain       <= 1'b0       ;
          out_WriteDestinationAddressRegisterAgain  <= 1'b0       ;
          TransferCompleted                         <= 1'b0       ;
          out_TransferCompleted                     <= 1'b0       ;
          sourceloop_r                              <= 5'b0       ;   
          destloop_r                                <= 5'b0       ;   
          sourcetransnum                            <= 12'b0      ;  
          desttransnum                              <= 12'b0      ;
          out_DMAC_EXTERNAL_ACK_1                   <= 1'b0       ;
          out_DMAC_EXTERNAL_ACK_2                   <= 1'b0       ;
          cnt_loop                                  <= 1'b0       ;
        end
      else
        begin
          if(!in_EnableDmac) // clear the register when channel is not enabled 
            begin
              HLOCK                                    <= 1'b0       ;
              DmacState                                <= `DMAC_IDLE ;
              out_TransStart                           <= 1'b0       ;
              out_HSIZE_m                              <= 3'b0       ;
              out_HBURST_m                             <= 3'b0       ;
              TransferAddr                             <= 32'b0      ;
              TransferCompleted                        <= 1'b0       ;
              out_PSELen                               <= 1'b0       ;
              out_PENABLEen                            <= 1'b0       ;
              out_PWRITEen                             <= 1'b0       ;
              out_FIFOReset                            <= 1'b1       ;
              out_read_en                              <= 1'b0       ;
              out_descriptor_counter                   <= 3'b0       ;
              out_AHBResponseError                     <= 1'b0       ;
              out_CurrentSourceAddrressLog             <= 32'b0      ;
              out_CurrentDestinationAddrressLog        <= 32'b0      ;
              out_TransferCompleted                    <= 1'b0       ;
              CurrentChannelTransferSize               <= 12'b0      ;
              CurrentTransferAddress                   <= 32'b0      ;
              out_CurrentChannelTransferSizeLog        <= 12'b0      ;
              out_WriteTransferSizeAgain               <= 1'b0       ;
              out_WriteSourceAddressRegisterAgain      <= 1'b0       ;
              out_WriteDestinationAddressRegisterAgain <= 1'b0       ; 
              sourceloop_r                              <= 5'b0      ;
              destloop_r                                <= 5'b0      ;
              sourcetransnum                            <= 12'b0     ;   // for `DMAC_INCR
              desttransnum                              <= 12'b0     ;
              out_DMAC_EXTERNAL_ACK_1                   <= 1'b0      ;
              out_DMAC_EXTERNAL_ACK_2                   <= 1'b0      ;
              cnt_loop                                  <= 1'b0      ; 
              out_DmacAck <= in_BridgeReq ? 1'b1 : 1'b0              ;
	      // judge for nand boot ( can del now ) 
              if((~in_NandTransComplete) && in_bootnand)
                 out_HBUSREQ_m <= 1'b1                               ;
              else
                 out_HBUSREQ_m <= 1'b0                               ;
            end
          else
            case(DmacState)
              `DMAC_IDLE: 
                begin // state IDLE for wait 
                  DmacState    <= (in_NextChannelReady && (!out_Bridgeing)) ? `LOOP_RELOAD: `DMAC_IDLE ;
                  out_DmacAck    <= in_BridgeReq ? 1'b1 : 1'b0 ;
                  out_TransStart <= 1'b0 ;
                  out_HSIZE_m    <= 3'b0;
                  out_HBURST_m   <= 3'b0;
                  TransferAddr   <= 32'b0;
                  out_CurrentSourceAddrressLog      <= 32'b0;
                  out_CurrentDestinationAddrressLog <= 32'b0;
                  HLOCK         <= 1'b0 ;
                  out_HTRANS_m  <= 2'b00;
                  out_HWRITE_m  <= 1'b1 ;
                  out_PSELen    <= 1'b0 ;
                  out_PENABLEen <= 1'b0 ;
                  out_PWRITEen  <= 1'b0 ;
                  out_FIFOReset <= 1'b1 ; 
                  sourceloop_r   <= sourceloop      ;
                  destloop_r     <= destloop        ;      
                  sourcetransnum                            <= 12'b0      ;   // for `DMAC_INCR
                  desttransnum                              <= 12'b0      ; 
                  out_CurrentChannelTransferSizeLog        <= 12'b0  ;
                  out_WriteTransferSizeAgain               <= 1'b0   ;
                  out_AHBResponseError                     <= 1'b0   ;
                  out_WriteSourceAddressRegisterAgain      <= 1'b0   ;
                  out_WriteDestinationAddressRegisterAgain <= 1'b0   ;
                  out_TransferCompleted                    <= 1'b0   ;
                  TransferCompleted                        <= 1'b0   ; 
                  sourceloop_r                             <= sourceloop   ;
                  destloop_r                               <= destloop     ;
                  cnt_loop                                 <= 1'b0         ;
                  out_DMAC_EXTERNAL_ACK_1                  <= 1'b0         ;
                  out_DMAC_EXTERNAL_ACK_2                  <= 1'b0         ; 
                end 
              `LOOP_RELOAD:    //  for change channel wait
                begin
                  cnt_loop                          <= 1'b1              ;
                  sourceloop_r                      <= sourceloop        ;
                  destloop_r                        <= destloop          ;
		  
		 // calculate dest transfer num in term of :
		 // 1. source size
		 // 2. dest size
		 // 3. in_TransferSize
                  case (in_SourceSize)
                    `DMAC_BYTE:
                      case(in_DestinationSize)
                        `DMAC_BYTE:
                          DestinationTransferSize <= in_TransferSize;
                        `DMAC_HALFWORD:
                          if (in_TransferSize[0] == 1'b0)
                            DestinationTransferSize <= in_TransferSize >> 1;
                          else
                            DestinationTransferSize <= (in_TransferSize + 1) >> 1;
                        `DMAC_WORD:
                          case(in_TransferSize[1:0])
                            2'b00:DestinationTransferSize <= in_TransferSize       >> 2;
                            2'b01:DestinationTransferSize <= (in_TransferSize + 3) >> 2;
                            2'b10:DestinationTransferSize <= (in_TransferSize + 2) >> 2;
                            2'b11:DestinationTransferSize <= (in_TransferSize + 1) >> 2;
                          endcase                     
                      endcase                  
                    `DMAC_HALFWORD:         
                      case(in_DestinationSize)                 
                        `DMAC_BYTE:             
                          DestinationTransferSize <= in_TransferSize << 1;               
                        `DMAC_HALFWORD:    
                          DestinationTransferSize <= in_TransferSize ;               
                        `DMAC_WORD:        
                          if (in_TransferSize[0] == 1'b0) 
                            DestinationTransferSize <= in_TransferSize >> 1;                  
                          else                 
                            DestinationTransferSize <= (in_TransferSize + 1) >> 1;                   
                      endcase                     
                    `DMAC_WORD:                   
                      case(in_DestinationSize)              
                        `DMAC_BYTE:      
                          DestinationTransferSize <= in_TransferSize << 2;           
                        `DMAC_HALFWORD:   
                          DestinationTransferSize <= in_TransferSize << 1;               
                        `DMAC_WORD:      
                          DestinationTransferSize <= in_TransferSize;                      
                      endcase                           
                  endcase
		  // when Htrans == 2'b1
                  sourcetransnum                    <= in_TransferSize-1 ;
		  // state wait a cycle for load the trans information when channel changed 
                  if(cnt_loop == 1'b1) 
                    begin
                      DmacState                       <= `SOURCE_PREPARE   ;
                      desttransnum                    <=  DestinationTransferSize[11:0]-1  ;
                    end
                end    
		                       
              `SOURCE_PREPARE:                           
                begin 
		  // src trans prepare to load information from slave module
                  out_DmacAck    <= in_BridgeReq ? 1'b1 : 1'b0 ;  
                  out_TransStart <= 1'b0 ;     
                  out_HSIZE_m    <= in_SourceSize; 
                  out_FIFOReset  <= 1'b0         ;  
                  out_HBURST_m   <= SourceBurstType;  
                  TransferAddr   <= in_SourceAddr ;     
		  // APB bridge is not work 
		  // APB bridge no req
                  if((!out_Bridgeing) && (!in_BridgeReq))                
                    case(SourceBus)  
                      `APB_BUS: DmacState <= `SOURCE_APB_PREPARE ; 
                      `AHB_BUS: DmacState <= `SOURCE_AHB_PREPARE ;                       
                    endcase                          
                  else                       
                    DmacState <= `SOURCE_PREPARE ; // wait APB bridge over 
		  // for external req 
		  // choose which one to response
                  if(in_external_req[0])   
                    out_DMAC_EXTERNAL_ACK_1 <= 1'b1;
                  else
                    out_DMAC_EXTERNAL_ACK_1 <= 1'b0;
                  if(in_external_req[1])   
                    out_DMAC_EXTERNAL_ACK_2 <= 1'b1;
                  else
                    out_DMAC_EXTERNAL_ACK_2 <= 1'b0;                            
                end                      
	      // state for APB trans prepare 
              `SOURCE_APB_PREPARE:                             
                begin 
		  // for exceed 1k loop                      
                  desttransnum <=  DestinationTransferSize[11:0]-1  ;    
                  out_DmacAck <=  1'b0 ;   //editd by dragon to solve the APB timint bug      
                  out_FIFOReset <= 1'b0;   // reset fifo
		  // load trans information
                  CurrentChannelTransferSize <= in_TransferSize ;  
                  CurrentTransferAddress <= in_SourceAddr; 
                  out_CurrentSourceAddrressLog <= in_SourceAddr;             
                  out_PWRITEen <= 1'b0;    
                  //DmacState <= (!out_Bridgeing)? `SOURCE_APB_SETUP : `SOURCE_APB_PREPARE; 
                  DmacState <=  `SOURCE_APB_SETUP ;                              
                end                    
              `SOURCE_APB_SETUP:  // state for psel == 1                               
                begin                                
                  out_FIFOReset <= 1'b0;                       
                  DmacState <= `SOURCE_APB_ENABLE ;  
                  case(SourceBurstType)                              
                    `DMAC_SINGLE:
		        // judge when trans finished 
		      if((in_TransferSize - 1) < CurrentChannelTransferSize)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin 
			// ensure after configed beat trans psel == 0 and penable == 0 
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end
		    `DMAC_INCR4 :
		     // judge when trans finished 
		      if((in_TransferSize - 4) < CurrentChannelTransferSize)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0 
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end 
		    `DMAC_INCR8 :
		     // judge when trans finished 
		      if((in_TransferSize - 8) < CurrentChannelTransferSize)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0 
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end 
		    `DMAC_INCR16 : 
		     // judge when trans finished 
		      if((in_TransferSize - 16) < CurrentChannelTransferSize)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0 
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end
		    `DMAC_INCR :
		     // judge when trans finished 
		      if( CurrentChannelTransferSize > 0)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0 
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end
	          endcase 
		end 
              `SOURCE_APB_ENABLE:                                 
                begin                // state penable == 1'b1               
                  out_FIFOReset <= 1'b0 ;          
                  case(SourceBurstType)                              
                    `DMAC_SINGLE:                            
                      begin
		       // judge when trans finished  
			if((in_TransferSize - 1) < CurrentChannelTransferSize)
			  begin
			  // trans num decreased after one's trans 
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
			    DmacState     <= `SOURCE_APB_SETUP  ;
			    out_PSELen    <= 1'b1;                     
                            out_PENABLEen <= 1'b1;
			  end 
			else
			  begin   
			    // register the trans information after a beat trans  
			    // when control by dmac                 
                            if ((CurrentChannelTransferSize >= 0) && (!in_Control_DorP))                    
                              begin                  
                                out_CurrentChannelTransferSizeLog <= CurrentChannelTransferSize[11:0];                 
                                out_WriteTransferSizeAgain <= 1'b1;                  
                              end 
			    DmacState     <= `HALF ; 
			    out_PSELen    <= 1'b0;                     
                            out_PENABLEen <= 1'b0;
			  end                          
                      end                   
                    `DMAC_INCR4 :                          
                      begin          
		       // judge when trans finished                
                        if ( (in_TransferSize - 4) < CurrentChannelTransferSize)                       
                          begin                      
                            out_PSELen    <= 1'b1;                     
                            out_PENABLEen <= 1'b1;
                            DmacState     <= `SOURCE_APB_SETUP ; 
			    // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;      
                          end                      
                        else                        
                          begin                   
                            out_PSELen    <= 1'b0  ;              
                            out_PENABLEen <= 1'b0  ;              
                            DmacState     <= `HALF ; 
			    // register the trans information after a beat trans  
			    // when control by dmac                
                            if ((CurrentChannelTransferSize >= 0) && (!in_Control_DorP))                  
                              begin             
                                out_CurrentChannelTransferSizeLog <= CurrentChannelTransferSize[11:0];             
                                out_WriteTransferSizeAgain <= 1'b1;          
                              end                    
                          end                          
                      end                         
                    `DMAC_INCR8 :
                      begin 
		       // judge when trans finished 
                        if ( (in_TransferSize - 8) < CurrentChannelTransferSize)                       
                          begin                     
                            out_PSELen    <= 1'b1;                    
                            out_PENABLEen <= 1'b1; 
                            DmacState <= `SOURCE_APB_SETUP ; 
			    // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;                  
                          end                         
                        else                    
                          begin                   
                            out_PSELen    <= 1'b0   ;                    
                            out_PENABLEen <= 1'b0   ;                  
                            DmacState     <= `HALF  ;       
			    // register the trans information after a beat trans  
			    // when control by dmac        
                            if ((CurrentChannelTransferSize >= 0) && (!in_Control_DorP))                
                              begin      
                                out_CurrentChannelTransferSizeLog <= CurrentChannelTransferSize[11:0];              
                                out_WriteTransferSizeAgain <= 1'b1;              
                              end                   
                          end                        
                      end                         
                    `DMAC_INCR16:                    
                      begin           
		       // judge when trans finished           
                        if ( (in_TransferSize - 16) < CurrentChannelTransferSize)                    
                          begin             
                            out_PSELen    <= 1'b1;               
                            out_PENABLEen <= 1'b1;                 
                            DmacState     <= `SOURCE_APB_SETUP ; 
			    // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;                
                          end                   
                        else                  
                          begin              
                            out_PSELen    <= 1'b0;   
                            out_PENABLEen <= 1'b0;
                            DmacState <= `HALF ;
			    // register the trans information after a beat trans  
			    // when control by dmac 
                            if ((CurrentChannelTransferSize >= 0) && (!in_Control_DorP)) 
                              begin 
                                out_CurrentChannelTransferSizeLog <= CurrentChannelTransferSize[11:0];         
                                out_WriteTransferSizeAgain <= 1'b1; 
                              end                    
                          end                    
                      end                   
                    `DMAC_INCR  :                 
                      begin            
		       // judge when trans finished      
                        if (CurrentChannelTransferSize > 0)                
                          begin   
                            out_PSELen    <= 1'b1; 
                            out_PENABLEen <= 1'b1; 
                            DmacState <= `SOURCE_APB_SETUP ;
			    // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;  
                          end                   
                        else                    
                          begin                 
                            DmacState     <= `HALF ;           
                            out_PSELen    <= 1'b0;  
                            out_PENABLEen <= 1'b0;      
                          end                      
                      end                      
                  endcase                       
                end                         
              `SOURCE_AHB_PREPARE:                            
                begin   
		  // prepare information state for src from AHB      
                  desttransnum <=  DestinationTransferSize[11:0]-1  ; // for 1k load 
		  // judge APB bridge   
                  out_DmacAck <= in_BridgeReq ? 1'b1 : 1'b0 ;
		  // clear fifo before one's trans
                  out_FIFOReset <= 1'b0                     ;
		  // judge AHB bus is busy now ?
                  if((in_HTRANS_s_h==`NONSEQ) || (in_HTRANS_s_h==`SEQ) )
                    begin
                      //HLOCK <= 1'b0;
                      HLOCK <= 1'b1;
                      out_HBUSREQ_m <= 1'b1 ;
                      out_HTRANS_m  <= 2'b00;
                      DmacState     <= `SOURCE_AHB_PREPARE ; // wait for AHB idle
                    end
                  else 
                    begin  //  AHB idle
                      HLOCK <= 1'b1;
                      out_HBUSREQ_m <= 1'b1 ; // bus req
                      if(!out_Bridgeing) // APB Idle
                        begin
                          if(AllowTransmitNext) // can use bus and slave ready
                            begin
                              out_HWRITE_m <=1'b0;  // read  enble
                              out_HTRANS_m <= `NONSEQ; // the first trans 
                             // CurrentChannelTransferSize <= in_TransferSize - 1;
                              if(sourceloop_r == sourceloop) // judge whether to exceed 1k
                              begin
                                CurrentTransferAddress <= in_SourceAddr;  
                                CurrentChannelTransferSize <= in_TransferSize - 1; 
                              end 
                              else
			      // decreased the trans data num
                                CurrentChannelTransferSize <=  CurrentChannelTransferSize - 1;
                              out_HBUSREQ_m <= (( SourceBurstType != `DMAC_INCR)) ? 1'b0 : 1'b1 ;
                              DmacState <= `SOURCE_AHB_TRANSFER ;
                            end
                        end
                      else         // wait APB idle     
                        begin
                          out_HWRITE_m <=1'b0;
                          out_HTRANS_m <= 2'b00; 
                          if(sourceloop_r == sourceloop)           ///////////////// 
                          begin
                            CurrentTransferAddress <= in_SourceAddr;
			    // decreased the trans data num 
                            CurrentChannelTransferSize <= in_TransferSize - 1;
                          end
                          out_HBUSREQ_m <=  1'b0 ;
                          DmacState <= `SOURCE_AHB_PREPARE ;
                        end
                    end
                end
              `SOURCE_AHB_TRANSFER:
                begin                // AHB begin to trans
                  out_FIFOReset <= 1'b0 ;
                  case (SourceBurstType)
                    `DMAC_SINGLE:
                      begin
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if ( (in_TransferSize - 1) < CurrentChannelTransferSize)
                          if (AllowTransmitNext == 1)
                            begin
			    // judge addr whether to increased and how much to increased 
                              if(in_SourceInc)
                                case(in_SourceSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                                out_HTRANS_m <= `SEQ;
				// decreased the trans data num
                                CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
			 // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          if(AllowTransmitNext)
                            begin
                              DmacState <= `HALF ;
                              out_HTRANS_m  <= 2'b00;
                              out_HBUSREQ_m <= 1'b0;
                              HLOCK         <= 1'b0;
                              if(CurrentChannelTransferSize >= 0)
                                begin
                                  if (in_SourceInc == 1)
                                    case (in_SourceSize)
				    // judge addr whether to increased and how much to increased 
                                      `DMAC_BYTE:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 4;
                                    endcase 
                                  else
                                    out_CurrentSourceAddrressLog <= TransferAddr;
                                    if(sourceloop_r != 5'b0)
                                      begin
                                        case (in_SourceSize)
					// judge addr whether to increased and how much to increased 
                                      `DMAC_BYTE:
                                        CurrentTransferAddress <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        CurrentTransferAddress <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        CurrentTransferAddress <= CurrentTransferAddress + 4;
                                        endcase
                                      end
                                  out_CurrentChannelTransferSizeLog <= CurrentChannelTransferSize[11:0];
                                  out_WriteSourceAddressRegisterAgain <= (sourceloop_r == 5'b0)?1'b1:1'b0;   ////  modified By Mocca
                                  out_WriteTransferSizeAgain <= 1'b1;
                                end
                            end
                      end
                    `DMAC_INCR4 :
                      begin
		        // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if ( (in_TransferSize - 4) < CurrentChannelTransferSize)
                          if (AllowTransmitNext == 1)
                            begin
			    // judge addr whether to increased and how much to increased 
                              if(in_SourceInc)
                                case(in_SourceSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                                out_HTRANS_m <= `SEQ;
				// decreased the trans data num
                                CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
			  // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          if(AllowTransmitNext)
                            begin
                              DmacState <= `HALF ;
                              out_HTRANS_m <= 2'b00;
                              out_HBUSREQ_m <= 1'b0;
                              HLOCK       <= 1'b0;
                              if(CurrentChannelTransferSize >= 0)
                                begin
				 // judge addr whether to increased and how much to increased 
                                  if (in_SourceInc == 1)
                                    case (in_SourceSize)
                                      `DMAC_BYTE:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 4;
                                    endcase
                                  else
                                    out_CurrentSourceAddrressLog <= TransferAddr;
                                    out_CurrentChannelTransferSizeLog <= CurrentChannelTransferSize[11:0];
                                    out_WriteSourceAddressRegisterAgain <= (sourceloop_r == 5'b0)?1'b1:1'b0;  //// modified By Mocca
                                    out_WriteTransferSizeAgain <= 1'b1;
                                end
                            end
                      end
                    `DMAC_INCR8 :
                      begin
		        // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if ( (in_TransferSize - 8) < CurrentChannelTransferSize)
                          if (AllowTransmitNext == 1)
                            begin
			    // judge addr whether to increased and how much to increased 
                              if(in_SourceInc)
                                case(in_SourceSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                                out_HTRANS_m <= `SEQ;
				// decreased the trans data num
                                CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
			   // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          if(AllowTransmitNext)
                            begin
                              DmacState <= `HALF ;
                              out_HTRANS_m <= 2'b00;
                              out_HBUSREQ_m <= 1'b0;
                              HLOCK       <= 1'b0;
			       // judge addr whether to increased and how much to increased 
                              if(CurrentChannelTransferSize >= 0)
                                begin
                                  if (in_SourceInc == 1)
                                    case (in_SourceSize)
				     // judge addr whether to increased and how much to increased 
                                      `DMAC_BYTE:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 4;
                                    endcase
                                  else
                                    out_CurrentSourceAddrressLog <= TransferAddr;
                                  out_CurrentChannelTransferSizeLog <= CurrentChannelTransferSize[11:0];
                                  out_WriteSourceAddressRegisterAgain <= (sourceloop_r == 5'b0)?1'b1:1'b0;   ////modified By Mocca
                                  out_WriteTransferSizeAgain <= 1'b1;
                                end
                            end
                      end
                    `DMAC_INCR16:
                      begin
		         // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if ( (in_TransferSize - 16) < CurrentChannelTransferSize)
                          if (AllowTransmitNext == 1)
                            begin
                              if(in_SourceInc)
                                case(in_SourceSize)
				// judge addr whether to increased and how much to increased 
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                                out_HTRANS_m <= `SEQ;
				// decreased the trans data num
                                CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
			// judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          if(AllowTransmitNext)
                            begin
                              DmacState <= `HALF ;
                              out_HTRANS_m <= 2'b00;
                              out_HBUSREQ_m <= 1'b0;
                              HLOCK       <= 1'b0;
                              if(CurrentChannelTransferSize >= 0)
                                begin 
		      // judge addr whether to increased and how much to increased 
                                  if (in_SourceInc == 1)
                                    case (in_SourceSize)
                                      `DMAC_BYTE:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        out_CurrentSourceAddrressLog <= CurrentTransferAddress + 4;
                                    endcase
                                  else
                                    out_CurrentSourceAddrressLog <= TransferAddr;
                                  out_CurrentChannelTransferSizeLog <= CurrentChannelTransferSize[11:0];
                                  out_WriteSourceAddressRegisterAgain <= (sourceloop_r == 5'b0)?1'b1:1'b0;   ////modified By Mocca
                                  out_WriteTransferSizeAgain <= 1'b1;
                                end
                            end
                      end
                    `DMAC_INCR  :
                      begin
		      	// judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if (CurrentChannelTransferSize > 0)
                          if (AllowTransmitNext == 1)
                            begin
                              if(in_SourceInc) 
		      // judge addr whether to increased and how much to increased 
                                case(in_SourceSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                              out_HTRANS_m <= `SEQ;
			      // decreased the trans data num
                              CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
			    // judge the slave res whether be ok
                              if (in_HRESP_m != `DMAC_OKAY)
			      // signal for INT to slave module 
                                out_AHBResponseError <= 1;
                            end
                        else
                          begin
			  // req the bus when grant next dest trans begin
                            if (AllowTransmitNext == 1)
                              begin
                                DmacState     <= `HALF ;
                                out_HTRANS_m  <= 2'b00;
                                out_HBUSREQ_m <= 1'b0;
                                HLOCK         <= 1'b0;
                              end
                          end
                      end
                  endcase
                end

              `HALF:
                begin
		// fifo register the data from src
                  out_FIFOReset <= 1'b0;  
                  destloop_r    <=  destloop  ;  
		  // APB bridge req ?
                  out_DmacAck   <= in_BridgeReq ? 1'b1 : 1'b0 ;
                  out_WriteSourceAddressRegisterAgain <= 1'b0;
                  out_WriteTransferSizeAgain <= 1'b0;
                  out_PSELen    <= 1'b0;
                  out_PENABLEen <= 1'b0;
                  if(!out_Bridgeing)// APB bus is Idle
                    begin
                      out_TransStart <= 1'b0 ;
                      case(SourceBus)
                        `APB_BUS:
			         // loop for exceed 1K
                                  begin
                                    if(sourceloop_r == 5'b0)  
                                      DmacState <= `DEST_PREPARE ;
                                    else
                                      begin
                                        DmacState <= `SOURCE_PREPARE     ;
                                        sourceloop_r <= sourceloop_r - 1 ;
                                      end
                                  end
                        `AHB_BUS:
                                  begin
				  // loop for exceed 1K
                                    if(sourceloop_r == 5'b0)
				      // wait for slave ready 
                                      DmacState <= in_HREADY_m ? `DEST_PREPARE : `HALF ;  
                                    else
                                      begin
				      // wait for slave ready 
                                        DmacState <= in_HREADY_m ?`SOURCE_PREPARE:`HALF ;
                                        sourceloop_r <= in_HREADY_m?(sourceloop_r-1):sourceloop_r;
                                      end
                                  end
                      endcase
                    end
                end
              `DEST_PREPARE:
                begin    // state for dest prepare trans information 
		  // if APB req ,APB is busy
                  out_DmacAck  <= in_BridgeReq ? 1'b1 : 1'b0 ;
                  out_HSIZE_m  <= in_DestinationSize;
                  out_HBURST_m <= DestBurstType ;
                  out_TransStart <= 1'b0 ;
                  //if(!out_Bridgeing)
		  // APB is Idle and no req now
                  if((!out_Bridgeing) && (!in_BridgeReq))
		    // choose the Bus
                    case(DestBus)
                      `APB_BUS: DmacState <= `DEST_APB_PREPARE ;
                      `AHB_BUS: DmacState <= `DEST_AHB_PREPARE ;
                    endcase
                  else
                    DmacState <= `DEST_PREPARE ;
                end
              `DEST_APB_PREPARE:
                begin
                  //out_DmacAck <= in_BridgeReq ? 1'b1 : 1'b0 ;
                  out_DmacAck   <= 1'b0 ;
                  out_FIFOReset <= 1'b0;
		  // load the register information from slave
                  CurrentChannelTransferSize <= DestinationTransferSize ;
                  CurrentTransferAddress <= in_DestAddr;
		  // write is enable
                  out_PWRITEen <= 1'b1;
                  //if(!out_Bridgeing)
                    DmacState <= `DEST_APB_SETUP ;
                  //else
                  //  DmacState <= `DEST_APB_PREPARE ;
                end
              `DEST_APB_SETUP:               
                begin                 
                  out_FIFOReset <= 1'b0;               
                  DmacState     <= `DEST_APB_ENABLE ;  
		  case(DestBurstType)                              
                    `DMAC_SINGLE:
		     // judge when trans finished   
		      if((DestinationTransferSize - 1) < CurrentChannelTransferSize)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end
		    `DMAC_INCR4 :
		    // judge when trans finished  
		      if((DestinationTransferSize - 4) < CurrentChannelTransferSize)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end 
		    `DMAC_INCR8 :
		    // judge when trans finished  
		      if((DestinationTransferSize - 8) < CurrentChannelTransferSize)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end 
		    `DMAC_INCR16 : 
		    // judge when trans finished  
		      if((DestinationTransferSize - 16) < CurrentChannelTransferSize)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end
		    `DMAC_INCR :
		    // judge when trans finished  
		      if( DestinationTransferSize > 0)
			begin
			  out_PSELen    <= 1'b1;                               
                          out_PENABLEen <= 1'b0; 
			end
		      else
			begin
			// ensure after configed beat trans psel == 0 and penable == 0
			  out_PSELen    <= 1'b0;                               
                          out_PENABLEen <= 1'b0;
			end
	          endcase                                        
                end            
              `DEST_APB_ENABLE:                
                begin           
                  out_FIFOReset <= 1'b0; 
                  case (DestBurstType) 
                    `DMAC_SINGLE:  
                      begin  
			  // judge when trans finished  
		        if((DestinationTransferSize - 1) < CurrentChannelTransferSize)
			  begin
                            out_PSELen <= 1'b1;  
                            out_PENABLEen <= 1'b1;
			    DmacState <= `DEST_APB_SETUP;
			    // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1; 
			  end
			else
			  begin     
                            DmacState <= `END; 
			    out_PSELen <= 1'b0;  
                            out_PENABLEen <= 1'b0;  
			    // register the trans information after a beat trans  
			    // when control by dmac  
                            out_WriteSourceAddressRegisterAgain <= (destloop_r == 5'b0)? 1'b1:1'b0;
			    TransferCompleted <= ((!in_Control_DorP)&&(CurrentChannelTransferSize == 0))? 1'b1 : 1'b0; 
			  end   
                      end       
                    `DMAC_INCR4 :      
                      begin
		       // judge when trans finished  
                        if ( (DestinationTransferSize - 4) < CurrentChannelTransferSize) 
                          begin  
                            out_PSELen <= 1'b1; 
                            out_PENABLEen <= 1'b1;                                                             
                            DmacState <= `DEST_APB_SETUP;
			     // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                          end  
                        else       
                          begin 
                            DmacState <= `END ; 
                            out_PSELen <= 1'b0;
                            out_PENABLEen <= 1'b0;
			    // register the trans information after a beat trans  
			    // when control by dmac
                            out_WriteSourceAddressRegisterAgain <= 1'b1;  
                            TransferCompleted <= ((!in_Control_DorP)&&(CurrentChannelTransferSize == 0))? 1'b1 : 1'b0; 
                          end      
                      end      
                    `DMAC_INCR8 :      
                      begin     
		       // judge when trans finished  
                        if ( (DestinationTransferSize - 8) < CurrentChannelTransferSize)   
                          begin  
                            out_PSELen <= 1'b1;  
                            out_PENABLEen <= 1'b1;
                            DmacState <= `DEST_APB_SETUP; 
			     // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                          end  
                        else    
                          begin   
                            DmacState <= `END ; 
                            out_PSELen <= 1'b0;
                            out_PENABLEen <= 1'b0;
			    // register the trans information after a beat trans  
			    // when control by dmac
                            out_WriteSourceAddressRegisterAgain <= 1'b1;  
                            TransferCompleted <= ((!in_Control_DorP)&&(CurrentChannelTransferSize == 0))? 1'b1 : 1'b0;
                          end       
                      end        
                    `DMAC_INCR16:  
                      begin        
		       // judge when trans finished  
                        if ( (DestinationTransferSize - 16) < CurrentChannelTransferSize) 
                          begin 
                            out_PSELen <= 1'b1; 
                            out_PENABLEen <= 1'b1; 
                            DmacState <= `DEST_APB_SETUP;
			     // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1; 
                          end    
                        else    
                          begin  
                            DmacState <= `END ;
                            out_PSELen <= 1'b0;
                            out_PENABLEen <= 1'b0; 
			    // register the trans information after a beat trans  
			    // when control by dmac
                            out_WriteSourceAddressRegisterAgain <= 1'b1;  
                            TransferCompleted <= ((!in_Control_DorP)&&(CurrentChannelTransferSize == 0))? 1'b1 : 1'b0;    
                          end         
                      end          
                    `DMAC_INCR:       
                      begin      
		       // judge when trans finished  
                        if (CurrentChannelTransferSize > 0)    
                          begin  
                            out_PSELen <= 1'b1;  
                            out_PENABLEen <= 1'b1;
                            DmacState <= `DEST_APB_SETUP ;
			     // trans num decreased after one's trans
			    CurrentChannelTransferSize <= CurrentChannelTransferSize - 1; 
                          end    
                        else     
                          begin    
                            DmacState <= `END ;             
                            out_PSELen  <= 1'b0; 
                            out_PENABLEen <= 1'b0; 
			    // Int if controled by DMAC  
                            TransferCompleted <= (!in_Control_DorP) ? 1'b1 : 1'b0 ; 
                          end          
                      end
                  endcase              
                end                 
              `DEST_AHB_PREPARE:
                begin
                  out_DmacAck <= in_BridgeReq ? 1'b1 : 1'b0 ;
                  if((in_HTRANS_s_h==`NONSEQ) || (in_HTRANS_s_h==`SEQ) )
                    begin
                      //HLOCK <= 1'b0;
                      HLOCK <= 1'b1;
                      out_HBUSREQ_m <= 1'b1 ;
                      out_HTRANS_m <= 2'b00;
                      DmacState <= `DEST_AHB_PREPARE ;
                    end
                  else
                  //if (in_HADDR_s_h != 16'h1000)
                    begin
                      HLOCK <= 1'b1;
                      out_HBUSREQ_m <= 1'b1 ;
                      if(!out_Bridgeing)
                        begin
                          if(AllowTransmitNext)
                            begin
                              out_HWRITE_m <= 1'b1;
                              out_HTRANS_m <= `NONSEQ;
                              // CurrentChannelTransferSize <= DestinationTransferSize - 1; // 1015
                              if(destloop == destloop_r)    /////////  ^_^ By Mocca
                              begin
                                CurrentTransferAddress <= in_DestAddr;
                                CurrentChannelTransferSize <= DestinationTransferSize - 1;
                              end
                              else
                                CurrentChannelTransferSize <= CurrentChannelTransferSize -1;
                              out_HBUSREQ_m <= (( DestBurstType != `DMAC_INCR)) ? 1'b0 : 1'b1 ;
                              DmacState <= `DEST_AHB_TRANSFER ;
                            end
                        end
                      else
                        begin
                          out_HWRITE_m <= 1'b1;
                          out_HTRANS_m <= 2'b00;
                         // CurrentChannelTransferSize <= DestinationTransferSize - 1;
                          if(destloop == destloop_r)        //////////////  ^_^  By Mocca 
                          begin
                          CurrentTransferAddress <= in_DestAddr;
                          CurrentChannelTransferSize <= DestinationTransferSize - 1;
                          end
                          out_HBUSREQ_m <=  1'b0 ;
                          DmacState <= `DEST_AHB_PREPARE ;
                        end
                    end
                 end
              `DEST_AHB_TRANSFER:
                begin
                  out_FIFOReset <= 1'b0 ;
                  case (DestBurstType)
                    `DMAC_SINGLE:
                      begin
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if ( (DestinationTransferSize - 1) < CurrentChannelTransferSize)
                          if (AllowTransmitNext == 1)
                            begin
                              if(in_DestinationInc)
                                case(in_DestinationSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                                out_HTRANS_m <= `SEQ;
                                CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          if(AllowTransmitNext)
                            begin
                              DmacState <= `END ;
                              out_HTRANS_m <= 2'b00;
                              out_HBUSREQ_m <= 1'b0;
                              HLOCK       <= 1'b0;
                              if(CurrentChannelTransferSize >= 0)
                                begin
                                  if (in_DestinationInc == 1)
                                    case (in_DestinationSize)
                                      `DMAC_BYTE:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 4;
                                    endcase  
                                  else
                                    out_CurrentDestinationAddrressLog <= in_DestAddr;
                                    if(destloop_r != 5'b0)  /////  next 11 lines added By Mocca ^_^
                                      begin
                                        case (in_DestinationSize)
                                      `DMAC_BYTE:
                                        CurrentTransferAddress <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        CurrentTransferAddress <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        CurrentTransferAddress <= CurrentTransferAddress + 4;
                                        endcase
                                      end
                                    out_WriteDestinationAddressRegisterAgain <= (destloop_r == 5'b0)?1'b1:1'b0;               ///  ^_^
                                    out_WriteSourceAddressRegisterAgain <= (destloop_r == 5'b0)?1'b1:1'b0;       //added By Mocca
                                  TransferCompleted <= (!in_Control_DorP && (CurrentChannelTransferSize == 0)) ? 1'b1 : 1'b0 ;
                                end
                            end
                      end
                    `DMAC_INCR4 :
                      begin
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if ( (DestinationTransferSize - 4) < CurrentChannelTransferSize)
                          if (AllowTransmitNext == 1)
                            begin
                              if(in_DestinationInc)
                                case(in_DestinationSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                                out_HTRANS_m <= `SEQ;
                                CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          if(AllowTransmitNext)
                            begin
                              DmacState <= `END ;
                              out_HTRANS_m <= 2'b00;
                              out_HBUSREQ_m <= 1'b0;
                              HLOCK       <= 1'b0;
                              if(CurrentChannelTransferSize >= 0)
                                begin
                                  if (in_DestinationInc == 1)
                                    case (in_DestinationSize)
                                      `DMAC_BYTE:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 4;
                                    endcase
                                  else
                                    out_CurrentDestinationAddrressLog <= in_DestAddr;
                                    out_WriteDestinationAddressRegisterAgain <= 1'b1;
                                    out_WriteSourceAddressRegisterAgain <= 1'b1;
                                  TransferCompleted <= (!in_Control_DorP && (CurrentChannelTransferSize == 0)) ? 1'b1 : 1'b0 ;
                                end
                            end
                      end
                    `DMAC_INCR8 :
                      begin
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if ( (DestinationTransferSize - 8) < CurrentChannelTransferSize)
                          if (AllowTransmitNext == 1)
                            begin
                              if(in_DestinationInc)
                                case(in_DestinationSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                                out_HTRANS_m <= `SEQ;
                                CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          if(AllowTransmitNext)
                            begin
                              DmacState <= `END ;
                              out_HTRANS_m <= 2'b00;
                              out_HBUSREQ_m <= 1'b0;
                              HLOCK       <= 1'b0;
                              if(CurrentChannelTransferSize >= 0)
                                begin
                                  if (in_DestinationInc == 1)
                                    case (in_DestinationSize)
                                      `DMAC_BYTE:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 4;
                                    endcase
                                  else
                                    out_CurrentDestinationAddrressLog <= in_DestAddr;
                                    out_WriteDestinationAddressRegisterAgain <= 1'b1;
                                    out_WriteSourceAddressRegisterAgain <= 1'b1;
                                  TransferCompleted <= (!in_Control_DorP && (CurrentChannelTransferSize == 0)) ? 1'b1 : 1'b0 ;
                                end
                            end
                      end
                    `DMAC_INCR16:
                      begin
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if ( (DestinationTransferSize - 16) < CurrentChannelTransferSize)
                          if (AllowTransmitNext == 1)
                            begin
                              if(in_DestinationInc)
                                case(in_DestinationSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                                out_HTRANS_m <= `SEQ;
                                CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          if(AllowTransmitNext)
                            begin
                              DmacState <= `END ;
                              out_HTRANS_m <= 2'b00;
                              out_HBUSREQ_m <= 1'b0;
                              HLOCK       <= 1'b0;
                              if(CurrentChannelTransferSize >= 0)
                                begin
                                  if (in_DestinationInc == 1)
                                    case (in_DestinationSize)
                                      `DMAC_BYTE:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 1;
                                      `DMAC_HALFWORD:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 2;
                                      `DMAC_WORD:
                                        out_CurrentDestinationAddrressLog <= CurrentTransferAddress + 4;
                                    endcase
                                  else
                                    out_CurrentDestinationAddrressLog <= in_DestAddr;
                                    out_WriteDestinationAddressRegisterAgain <= 1'b1;
                                    out_WriteSourceAddressRegisterAgain <= 1'b1;
                                    TransferCompleted <= (!in_Control_DorP && (CurrentChannelTransferSize == 0)) ? 1'b1 : 1'b0 ;
                                end
                            end
                      end
                    `DMAC_INCR  :
                      begin
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                        if (CurrentChannelTransferSize > 0)
                          if (AllowTransmitNext == 1)
                            begin
                              if(in_DestinationInc)
                                case(in_DestinationSize)
                                  `DMAC_BYTE:
                                    CurrentTransferAddress <= CurrentTransferAddress + 1;
                                  `DMAC_HALFWORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 2;
                                  `DMAC_WORD:
                                    CurrentTransferAddress <= CurrentTransferAddress + 4;
                                endcase
                              out_HTRANS_m <= `SEQ;
                              CurrentChannelTransferSize <= CurrentChannelTransferSize - 1;
                            end
                          else
                            begin
                              if (in_HRESP_m != `DMAC_OKAY)
                                out_AHBResponseError <= 1;
                            end
                        else
		      // judge trans num whether to finish
		      // judge trans is can allowed
		      // judge addr whether to increased and how much to increased 
                          begin
                            if(!in_Control_DorP)
                              TransferCompleted <= 1'b1;
                            if (AllowTransmitNext == 1)
                              begin
                                DmacState <=  `END ;
                                out_HTRANS_m <= 2'b00;
                                out_HBUSREQ_m <= 1'b0;
                                HLOCK       <= 1'b0;
                              end 
                          end
                      end
                  endcase
                end 
              `END:
                begin
		// if APB bridge Req,Ack == 1'b1 
                  out_DmacAck <= in_BridgeReq ? 1'b1 : 1'b0 ;
                  // TransferCompleted modified by mocca
		  // judge when trans completed and no LLI  
                  if(!DestBus)
                    out_TransferCompleted <= ((TransferCompleted)&(in_Descriptor_Index == 32'b0))?1'b1 : 1'b0;
                  else
		  // judge when trans completed and no LLI
		  // AHB bus wait slave ready 
                    if(in_HREADY_m)
                      out_TransferCompleted <= ((TransferCompleted)&(in_Descriptor_Index == 32'b0))?1'b1 : 1'b0;
		  // clear the control signal 
                  out_WriteSourceAddressRegisterAgain <= 1'b0;
                  out_WriteDestinationAddressRegisterAgain <= 1'b0;
                  out_WriteTransferSizeAgain <= 1'b0;
                  out_PSELen    <= 1'b0;
                  out_PENABLEen <= 1'b0;
                  out_DMAC_EXTERNAL_ACK_1     <= 1'b0      ;
                  out_DMAC_EXTERNAL_ACK_2     <= 1'b0      ; 
		  // APB is IDLE 
                  if(!out_Bridgeing)
                    begin
		    // no LLI and one configed trans not finished
                      if((in_Descriptor_Index == 32'b0) || (TransferCompleted == 1'b0))
                         case(DestBus)
                           `APB_BUS: begin
			               // APB loop for exceed 1k
                                       if( destloop_r==5'b0)
                                         begin
                                           DmacState <= `DMAC_IDLE                          ;   
                                           out_TransStart <= 1'b1                           ;
                                         end
                                       else
                                         begin
                                           DmacState <= `DEST_PREPARE                       ;
                                           destloop_r <= destloop_r -1                      ;
                                         end
                                     end
                           `AHB_BUS: begin
			               // AHB loop for exceed 1k
                                       if( destloop_r == 5'b0)
                                         begin
					 // AHB judge the slave whether to be ready
                                           DmacState <= in_HREADY_m ? `DMAC_IDLE : `END     ;
                                           out_TransStart <= in_HREADY_m ? 1'b1 : 1'b0      ;
                                         end
                                       else
                                         begin
					  // AHB judge the slave whether to be ready
                                           DmacState  <= in_HREADY_m ?`DEST_PREPARE:`END          ;
                                           destloop_r <= in_HREADY_m ?(destloop_r -1):destloop_r  ;
                                         end
                                     end
                         endcase
                      else
                        case(DestBus)
			// when one configed trans finished and has a LLI ,next state prepare to load LLI
                          `APB_BUS: begin
                                      DmacState <= `DESCRIPTOR_PREPARE                      ;   
                                    end
                          `AHB_BUS: begin
                                      DmacState <= in_HREADY_m ? `DESCRIPTOR_PREPARE : `END ; 
                                    end
                        endcase
                    end
                end
              `DESCRIPTOR_PREPARE:
                begin
		  // when APB req to bridge, release the APB bus
                  out_DmacAck   <= in_BridgeReq ? 1'b1 : 1'b0             ;
		  // clear fifo after trans
                  out_FIFOReset <= 1'b1                                   ;
                  out_HBURST_m  <= `DMAC_SINGLE                           ;
                  out_HSIZE_m   <= `DMAC_WORD                             ;
                  if((in_HTRANS_s_h==`NONSEQ) || (in_HTRANS_s_h==`SEQ) )
                    begin
                      HLOCK          <= 1'b1                              ;
                      out_HBUSREQ_m  <= 1'b0                              ;
                      out_HTRANS_m   <= 2'b00                             ;
                      DmacState      <= `DESCRIPTOR_PREPARE               ;
                    end
                  else
                    begin
		    // req AHB bus to load LLI
                      HLOCK         <= 1'b1                               ;
                      out_HBUSREQ_m <= 1'b1                               ;
		      // if AHB is Idle ,next state load LLI 
                      if(!in_HGRANT_m)
                        begin
                          DmacState      <= `DESCRIPTOR_WAIT              ;
                          out_HTRANS_m           <=   2'b0                ;
                          CurrentTransferAddress <=  in_Descriptor_Index  ;
                        end
                      else
                        DmacState      <= `DESCRIPTOR_PREPARE             ; 
                    end
                end
             `DESCRIPTOR_WAIT:
                begin
                  out_DmacAck   <= in_BridgeReq ? 1'b1 : 1'b0         ;
		  // wait APB IDLe and trans allowed 
                  if(!out_Bridgeing & AllowTransmitNext)
                    begin
                      out_HWRITE_m           <=  1'b0                 ;
                      out_HTRANS_m           <=  2'b00                ;
                      out_descriptor_counter <=  5                    ;
		      // load LLI address 
                      CurrentTransferAddress <=  in_Descriptor_Index-4;
                      DmacState              <=  `DESCRIPTOR_TRANSFER ;
		      // read LLI enable to slave module
                      out_read_en            <=  1'b1                 ; 
                    end
                  else
                      DmacState              <= `DESCRIPTOR_WAIT      ;
                end
             `DESCRIPTOR_TRANSFER:
               begin
                 out_DmacAck   <= in_BridgeReq ? 1'b1 : 1'b0             ;
                 out_FIFOReset <= 1'b1                                   ;
                 out_HBURST_m  <= `DMAC_SINGLE                           ;
                 out_HSIZE_m   <= `DMAC_WORD                             ;
		 // AHB busy ?
                 if((in_HTRANS_s_h==`NONSEQ) || (in_HTRANS_s_h==`SEQ) )
                   begin
                     HLOCK          <= 1'b1                              ;
                     out_HBUSREQ_m  <= 1'b1                              ;
                     out_HTRANS_m   <= 2'b00                             ;
                     DmacState      <= `DESCRIPTOR_TRANSFER              ;
                     out_read_en            <=  1'b1                     ;  
                   end
                 else
		 // AHB Idle !
                   begin
                     HLOCK         <= 1'b1                               ;
                     out_HBUSREQ_m <= 1'b1                               ;
		     // AHB Idle and allow trans
                     if(!out_Bridgeing & AllowTransmitNext)
		       // cnt for load 5 LLI word
                       if(out_descriptor_counter > 0)
                         begin
                           out_read_en            <=  1'b1                             ; 
                           out_HWRITE_m           <=  1'b0                             ;
                           out_HTRANS_m           <=  `NONSEQ                          ;
			   // cnt decreased
                           out_descriptor_counter <=  out_descriptor_counter-1         ;
			   // address increaed
                           CurrentTransferAddress <=  CurrentTransferAddress+4         ;
                           DmacState              <=  `DESCRIPTOR_TRANSFER             ;
                         end
                       else
                         begin
                           DmacState              <=  `DESCRIPTOR_END                  ;
                           out_HTRANS_m           <=  2'b00                            ;
                           out_read_en            <=  1'b0                             ;
			   //start another trans to slave module
			    out_TransStart        <= 1'b1                              ;
                         end
                   end
               end
            `DESCRIPTOR_END: // one B or S trans end next state wait a new trans  
               begin
                 out_HTRANS_m           <=  2'b00      ;
                 HLOCK                  <=  1'b0       ;
                 out_HBUSREQ_m          <=  1'b0       ;
                 DmacState              <=  `DMAC_IDLE ;
               end
            default:
              DmacState                 <=  `DMAC_IDLE ; 
            endcase
        end
    end

//  AMBA AHB address 
  assign out_HADDR_m = CurrentTransferAddress ;


// control signal to FIFO when to read or when to read 
  always @(DmacState or SourceBus or DestBus or DelayPSEL or out_PSELen or out_PENABLEen or DelayPENABLE or in_HREADY_m or in_HGRANT_m or out_HTRANS_m)                                                                                                              
    begin
      case(DmacState)
      `DMAC_IDLE,`SOURCE_PREPARE,`SOURCE_APB_PREPARE,`SOURCE_AHB_PREPARE,
      `DEST_PREPARE,`DEST_APB_PREPARE,`DEST_AHB_PREPARE:
        begin
          out_ReadDataEnable = 1'b0;
          out_WriteDataEnable = 1'b0;
        end
	// control signal to FIFO when to read or when to read
      `SOURCE_APB_SETUP,`SOURCE_APB_ENABLE:
        begin
          out_ReadDataEnable = 1'b0;
          if (DelayPSEL & DelayPENABLE)
            out_WriteDataEnable = 1'b1;
          else
            out_WriteDataEnable = 1'b0;
        end
      `SOURCE_AHB_TRANSFER:
        begin
	// control signal to FIFO when to read or when to read
          out_ReadDataEnable = 1'b0;
          if ((in_HREADY_m  & in_HGRANT_m )&(out_HTRANS_m == `SEQ))
            out_WriteDataEnable = 1'b1;
          else
            out_WriteDataEnable = 1'b0;
        end

      `HALF:
        begin
          out_ReadDataEnable = 1'b0 ;
          case(SourceBus)
            `APB_BUS:
	    // control signal to FIFO when to read or when to read
                if (DelayPSEL & DelayPENABLE)
                  out_WriteDataEnable = 1'b1;
                else
                  out_WriteDataEnable = 1'b0;
             `AHB_BUS:
	     // control signal to FIFO when to read or when to read
               if(in_HREADY_m  & in_HGRANT_m )
                 out_WriteDataEnable = 1'b1;
               else
                 out_WriteDataEnable = 1'b0;
          endcase
        end

      `DEST_APB_SETUP,`DEST_APB_ENABLE:
        begin
          out_WriteDataEnable = 1'b0;
	  // control signal to FIFO when to read or when to read
          if (out_PSELen & out_PENABLEen)
            out_ReadDataEnable = 1'b1;
          else
            out_ReadDataEnable = 1'b0;
        end
      `DEST_AHB_TRANSFER:
        begin
          out_WriteDataEnable = 1'b0;
	  // control signal to FIFO when to read or when to read
          if ((in_HREADY_m  & in_HGRANT_m )&(out_HTRANS_m == `SEQ))
            out_ReadDataEnable = 1'b1;
          else
            out_ReadDataEnable = 1'b0;
        end

      `END:
        begin
          out_WriteDataEnable = 1'b0;
          case(DestBus)
            `APB_BUS:
	    // control signal to FIFO when to read or when to read
                if (out_PSELen & out_PENABLEen)
                  out_ReadDataEnable = 1'b1;
                else
                  out_ReadDataEnable = 1'b0;
             `AHB_BUS:
	     // control signal to FIFO when to read or when to read
               if(in_HREADY_m  & in_HGRANT_m)
                 out_ReadDataEnable = 1'b1;
               else
                 out_ReadDataEnable = 1'b0;
          endcase
        end


      default:
        begin
          out_ReadDataEnable = 1'b0;
          out_WriteDataEnable = 1'b0;
        end
      endcase
    end

endmodule                                                                                                                     
