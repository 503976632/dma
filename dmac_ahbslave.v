
module dmac_ahbslave( 
                  // system HCLK
                     HCLK                                     , 
		  // system reset
                     HRESETn                                  , 
		  // can delete
                     in_bootnand                              , 
		  // AMBA SLAVE INTERFACE
                     in_HSEL_s                                ,
                     in_HADDR_s                               ,
                     in_HWRITE_s                              ,
                     in_HTRANS_s                              ,
                     in_HSIZE_s                               ,
                     in_HWDATA_s                              , 
                     out_HREADY_s                             ,
                     out_HRESP_s                              ,
                     out_HRDATA_s                             ,
          // from arbit indicate which channel is in transfering
                     in_DMACActivedChannel                    ,
		  // from FSM indicate next transfer can start
                     in_TransStart                            ,
		  // register the current channle's transfer information
	             // include: 1.source address 
	             //          2.destination address 
	             //          3.number of data need to transfer 
                     in_CurrentSourceAddrressLog              , // 1.
                     in_CurrentDestinationAddrressLog         , // 2.
                     in_CurrentChannelTransferSizeLog         , // 3.
		  // signal indicate to reload the informations from FSM
	              // reload source addres
                     in_WriteSourceAddressRegisterAgain       ,
		      // reload destination address
                     in_WriteDestinationAddressRegisterAgain  ,
		      // reload number of data need to transfer 
                     in_WriteTransferSizeAgain                ,
		     // signal indicate current transfer completed 
                     in_TransferCompleted                     ,
		     // indicate transfer error
                     in_AHBResponseError                      ,
                  // module slave send the transfer information which software configed 
		  // to the control FSM module
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
                     out_SourceAddr                           , // 1
                     out_DestAddr                             , // 2
                     out_TransferSize                         , // 3
                     out_DestinationInc                       , // 4
                     out_SourceInc                            , // 5
                     out_DestinationSize                      , // 6
                     out_SourceSize                           , // 7
                     out_DestinationBurst                     , // 8
                     out_SourceBurst                          , // 9
                     out_Control_DorP                         , // 10
                     out_FlowControl                          , // 11
		  // signal to FSM module to start the transfering
		  // signal to FIFO module to clear the fifo for new transfering
                     out_EnableDmac                           ,
		  // signal indicate which channel has request to arbit module
                     out_ShortTimeEnableChannel               ,
		  // signal to FSM for nandboot control when booting
                     out_NandTransComplete                    ,
		  // to INTC module indicate transfering completed 
                     out_TransferCompletedInt                 ,
		  // to INTC module indicate transfer error 
                     out_DmacIntErrorInt                      ,
		  // counter for reading descriptor  
                     in_descriptor_counter                    ,
		  // read descriptor enable
                     in_read_en                               ,
		  // data when DMAC as ahb Master read from memory
                     in_HRDATA_m                              ,
		  // descriptor Index to FSM module to judge whether to read descriptor
                     out_Descriptor_Index                     , 
		  // to FSM indicate the current transfer for external request
		     out_external_req                         ,
//		  // DMA REQUEST From Internal Module 
//		     // From USB Module
                     in_DMACBREQ_USBin     , // Burst  in 
                     in_DMACSREQ_USBin     , // Single in
                     in_DMACBREQ_USBout    , // Burst  out
                     in_DMACSREQ_USBout    , // Single out
		     // From NAND Module
                     in_DMACBREQ_NANDin    , // Burst  in 
                     in_DMACSREQ_NANDin    , // Single in
                     in_DMACBREQ_NANDout   , // Burst  out
                     in_DMACSREQ_NANDout   , // Single out
//		      // From Uart1 Module
                     in_DMACBREQ_UART1in   , // Burst  in 
                     in_DMACSREQ_UART1in   , // Single in
                     in_DMACBREQ_UART1out  , // Burst  out
                     in_DMACSREQ_UART1out  , // Single out
		     // From Uart2 Module
                     in_DMACBREQ_UART2in   , // Burst  in 
                     in_DMACSREQ_UART2in   , // Single in
                     in_DMACBREQ_UART2out  , // Burst  out
                     in_DMACSREQ_UART2out  , // Single out
		     // From AC97 Mudule
                     in_DMACBREQ_AC97in    , // Burst  in 
                     in_DMACSREQ_AC97in    , // Single in
                     in_DMACBREQ_AC97out   , // Burst  out
                     in_DMACSREQ_AC97out   , // Single out
		     // From SPI Module
                     in_DMACBREQ_SPIin     , // Burst  in 
                     in_DMACSREQ_SPIin     , // Single in
                     in_DMACBREQ_SPIout    , // Burst  out
                     in_DMACSREQ_SPIout    , // Single out
		      // From MMC Module
                     in_DMACBREQ_MMCin     , // Burst  in 
                     in_DMACSREQ_MMCin     , // Single in
                     in_DMACBREQ_MMCout    , // Burst  out
                     in_DMACSREQ_MMCout    , // Single out
		  // External Request from PCB board 
		     in_DMACBREQ_EXTERNAL_1   , 
		     in_DMACBREQ_EXTERNAL_2
                     );


`define ADDRESS_CHANNEL_00_SOURCEADDR 32'd0
`define ADDRESS_CHANNEL_01_SOURCEADDR 16'd4
`define ADDRESS_CHANNEL_02_SOURCEADDR 16'd8
`define ADDRESS_CHANNEL_03_SOURCEADDR 16'd12
`define ADDRESS_CHANNEL_04_SOURCEADDR 16'd16
`define ADDRESS_CHANNEL_05_SOURCEADDR 16'd20
`define ADDRESS_CHANNEL_00_DESTINATIONADDR 32'd24
`define ADDRESS_CHANNEL_01_DESTINATIONADDR 16'd28
`define ADDRESS_CHANNEL_02_DESTINATIONADDR 16'd32
`define ADDRESS_CHANNEL_03_DESTINATIONADDR 16'd36
`define ADDRESS_CHANNEL_04_DESTINATIONADDR 16'd40
`define ADDRESS_CHANNEL_05_DESTINATIONADDR 16'd44
`define ADDRESS_CHANNEL_00_CONTROL 32'd44
`define ADDRESS_CHANNEL_01_CONTROL 16'd48
`define ADDRESS_CHANNEL_02_CONTROL 16'd52
`define ADDRESS_CHANNEL_03_CONTROL 16'd56
`define ADDRESS_CHANNEL_04_CONTROL 16'd60
`define ADDRESS_CHANNEL_05_CONTROL 16'd64
`define ADDRESS_CHANNEL_00_CONFIGURATION 32'd68
`define ADDRESS_CHANNEL_01_CONFIGURATION 16'd72
`define ADDRESS_CHANNEL_02_CONFIGURATION 16'd76
`define ADDRESS_CHANNEL_03_CONFIGURATION 16'd80
`define ADDRESS_CHANNEL_04_CONFIGURATION 16'd84
`define ADDRESS_CHANNEL_05_CONFIGURATION 16'd88
`define ADDRESS_INT_STATUS       32'd92
`define ADDRESS_INT_TC_STATUS    32'd96
`define ADDRESS_INT_ERROR_STATUS 32'd100
`define ADDRESS_CHANNEL_00_DESCRIPTOR 32'd104
`define ADDRESS_CHANNEL_01_DESCRIPTOR 16'd108
`define ADDRESS_CHANNEL_02_DESCRIPTOR 16'd112
`define ADDRESS_CHANNEL_03_DESCRIPTOR 16'd116
`define ADDRESS_CHANNEL_04_DESCRIPTOR 16'd120
`define ADDRESS_CHANNEL_05_DESCRIPTOR 16'd124
`define ADDRESS_ENABLE_CHANNEL  32'd128
`define ADDRESS_INT_TC_CLEAR    32'd132
`define ADDRESS_INT_ERROR_CLEAR 32'd136
`define P_ONE        4'd1
`define P_TWO        4'd2
`define P_THREE      4'd3
`define P_FOUR       4'd4
`define P_FIVE       4'd5
`define P_SIX        4'd6
`define P_SEVEN      4'd7
`define P_EIGHT      4'd8
`define P_NINE       4'd9
`define DMAC_SINGLE  3'b000
`define DMAC_INCR4   3'b011
`define DMAC_INCR8   3'b101
`define DMAC_INCR16  3'b111












//================================================================
//==================== INPUT AND OUTPUT ==========================
//================================================================
// system HCLK
input           HCLK                                          ;
// system reset
input           HRESETn                                       ;
 // can delete
input           in_bootnand                                   ;
 // AMBA SLAVE INTERFACE
input           in_HSEL_s                                     ;
input  [31:0]   in_HADDR_s                                    ;
input           in_HWRITE_s                                   ;
input  [1:0]    in_HTRANS_s                                   ;
input  [2:0]    in_HSIZE_s                                    ;
input  [31:0]   in_HWDATA_s                                   ;
output          out_HREADY_s                                  ;
output [1:0]    out_HRESP_s                                   ;
output [31:0]   out_HRDATA_s                                  ;
 // from arbit indicate which channel is in transfering
input  [2:0]    in_DMACActivedChannel                         ;
// from FSM indicate next transfer can start  
input           in_TransStart                                 ;
 // register the current channle's transfer information
	 // include: 1.source address 
	 //          2.destination address 
	 //          3.number of data need to transfer 
input  [31:0]   in_CurrentSourceAddrressLog                   ;// 1.
input  [31:0]   in_CurrentDestinationAddrressLog              ;// 2.
input  [11:0]   in_CurrentChannelTransferSizeLog              ;// 3.
// signal indicate to reload the informations from FSM
	// reload source addres
input           in_WriteSourceAddressRegisterAgain            ;
        // reload destination address 
input           in_WriteDestinationAddressRegisterAgain       ;
        // reload number of data need to transfer
input           in_WriteTransferSizeAgain                     ;
// signal indicate current transfer completed 
input           in_TransferCompleted                          ;
// indicate transfer error
input           in_AHBResponseError                           ;
// DMA REQUEST From Internal Module 
                // From USB Module
input           in_DMACBREQ_USBin                             ;// Burst   in 
input           in_DMACSREQ_USBin                             ;// Single  in 
input           in_DMACBREQ_USBout                            ;// Burst   out 
input           in_DMACSREQ_USBout                            ;// Single  out
                // From NAND Module
input           in_DMACBREQ_NANDin                            ;// Burst   in 
input           in_DMACSREQ_NANDin                            ;// Single  in
input           in_DMACBREQ_NANDout                           ;// Burst   out 
input           in_DMACSREQ_NANDout                           ;// Single  out
                // From UART1 Module
input           in_DMACBREQ_UART1in                           ;// Burst   in 
input           in_DMACSREQ_UART1in                           ;// Single  in
input           in_DMACBREQ_UART1out                          ;// Burst   out
input           in_DMACSREQ_UART1out                          ;// Single  out
                 // From UART2 Module
input           in_DMACBREQ_UART2in                           ;// Burst   in
input           in_DMACSREQ_UART2in                           ;// Single  in
input           in_DMACBREQ_UART2out                          ;// Burst   out
input           in_DMACSREQ_UART2out                          ;// Single  out
                 // From AC97 Module
input           in_DMACBREQ_AC97in                            ;// Burst   in
input           in_DMACSREQ_AC97in                            ;// Single  in
input           in_DMACBREQ_AC97out                           ;// Burst   out
input           in_DMACSREQ_AC97out                           ;// Single  out
                // From SPI Module
input           in_DMACBREQ_SPIin                             ;// Burst   in
input           in_DMACSREQ_SPIin                             ;// Single  in
input           in_DMACBREQ_SPIout                            ;// Burst   out
input           in_DMACSREQ_SPIout                            ;// Single  out
                // From MMC Module
input           in_DMACBREQ_MMCin                             ;// Burst   in
input           in_DMACSREQ_MMCin                             ;// Single  in
input           in_DMACBREQ_MMCout                            ;// Burst   out
input           in_DMACSREQ_MMCout                            ;// Single  out

// module slave send the transfer information which software configed 
		  // to the control FSM module
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
output [31:0]   out_SourceAddr                                ; // 1.
output [31:0]   out_DestAddr                                  ; // 2.
output [11:0]   out_TransferSize                              ; // 3.
output          out_DestinationInc                            ; // 4.
output          out_SourceInc                                 ; // 5.
output [2:0]    out_SourceSize                                ; // 6.
output [2:0]    out_DestinationSize                           ; // 7.
output [2:0]    out_DestinationBurst                          ; // 8.
output [2:0]    out_SourceBurst                               ; // 9.
output          out_Control_DorP                              ; // 10.
output [1:0]    out_FlowControl                               ; // 11.
 // signal to FSM module to start the transfering
 // signal to FIFO module to clear the fifo for new transfering
output          out_EnableDmac                                ;
 // signal indicate which channel has request to arbit module
output [5:0]    out_ShortTimeEnableChannel                    ;
 // signal to FSM for nandboot control when booting
output          out_NandTransComplete                         ;
 // to INTC module indicate transfering completed  
output          out_TransferCompletedInt                      ;
  // to INTC module indicate transfer error 
output          out_DmacIntErrorInt                           ;
  // counter for reading descriptor 
input  [2:0]    in_descriptor_counter                         ;
  // read descriptor enable
input           in_read_en                                    ;
  // External Request from PCB board 
input           in_DMACBREQ_EXTERNAL_1                        ;
input           in_DMACBREQ_EXTERNAL_2                        ;
 // data when DMAC as ahb Master read from memory
input  [31:0]   in_HRDATA_m                                   ;
 // descriptor Index to FSM module to judge whether to read descriptor
output [31:0]   out_Descriptor_Index                          ;
 // to FSM indicate the current transfer for external request
output  [1:0]   out_external_req                              ;
//=======================================================================

// data read from registers when DMAC as AHB slave
reg  [31:0] out_HRDATA_s              ;
// current enabled channels register
wire [5:0]  DMACEnbldChns_r           ;    //only read
// INT status of 6 channels register
wire [5:0]  DMACIntStatus_r           ;    //only read
// Transfer Completed INT status register 
reg  [5:0]  DMACIntTCStatus_r         ;    //only read
// Transfer Error INT status register 
reg  [5:0]  DMACIntErrorStatus_r      ;    //only read
// Clear Transfer Completed INT regiser 
reg  [5:0]  DMACIntTCClear_r          ;    //only write
// Clear Transfer Error INT status register
reg  [5:0]  DMACIntErrClr_r           ;    //only write

// Registers of each Channel include:
// 1. source address register 
// 2. destination address register
// 3. control register
// 4. config register
// 5. descriptor index register     
   // Registers of Channel 0         
reg  [31:0] DMACC0SrcAddr_r           ;    // 1. read and write
reg  [31:0] DMACC0DestAddr_r          ;    // 2. read and write
reg  [25:0] DMACC0Control_r           ;    // 3. read and write
reg  [19:0] DMACC0Configuration_r     ;    // 4. read and write
reg  [31:0] DMACC0_Descriptor_Index_r ;    // 5. read and write
   // Registers of Channel 1
reg  [31:0] DMACC1SrcAddr_r           ;    // 1. read and write
reg  [31:0] DMACC1DestAddr_r          ;    // 2. read and write
reg  [25:0] DMACC1Control_r           ;    // 3. read and write
reg  [19:0] DMACC1Configuration_r     ;    // 4. read and write
reg  [31:0] DMACC1_Descriptor_Index_r ;    // 5. read and write
   // Registers of Channel 2
reg  [31:0] DMACC2SrcAddr_r           ;    // 1. read and write
reg  [31:0] DMACC2DestAddr_r          ;    // 2. read and write
reg  [25:0] DMACC2Control_r           ;    // 3. read and write
reg  [19:0] DMACC2Configuration_r     ;    // 4. read and write
reg  [31:0] DMACC2_Descriptor_Index_r ;    // 5. read and write
   // Registers of Channel 3
reg  [31:0] DMACC3SrcAddr_r           ;    // 1. read and write
reg  [31:0] DMACC3DestAddr_r          ;    // 2. read and write
reg  [25:0] DMACC3Control_r           ;    // 3. read and write
reg  [19:0] DMACC3Configuration_r     ;    // 4. read and write
reg  [31:0] DMACC3_Descriptor_Index_r ;    // 5. read and write
   // Registers of Channel 4
reg  [31:0] DMACC4SrcAddr_r           ;    // 1. read and write
reg  [31:0] DMACC4DestAddr_r          ;    // 2. read and write
reg  [25:0] DMACC4Control_r           ;    // 3. read and write
reg  [19:0] DMACC4Configuration_r     ;    // 4. read and write
reg  [31:0] DMACC4_Descriptor_Index_r ;    // 5. read and write
   // Registers of Channel 5
reg  [31:0] DMACC5SrcAddr_r           ;    // 1. read and write
reg  [31:0] DMACC5DestAddr_r          ;    // 2. read and write
reg  [25:0] DMACC5Control_r           ;    // 3. read and write
reg  [19:0] DMACC5Configuration_r     ;    // 4. read and write
reg  [31:0] DMACC5_Descriptor_Index_r ;    // 5. read and write

// Current Transfering Channel's configed Registers
reg   [31:0] DMAC_Src_Addr_r                  ; // 1.
reg   [31:0] DMAC_Dest_Addr_r                 ; // 2.
reg   [19:0] DMAC_Configuration_r             ; // 3.
reg   [25:0] DMAC_Control_r                   ; // 4.
reg   [31:0] DMAC_Descriptor_Index_r          ; // 5.
// delay one cycle of Descriptor_Index  
reg   [31:0] DMAC_Descriptor_Index_later_r    ;
// indicate Descriptor whether to changed 
reg          Descriptor_Changed               ;
// to FSM for Descriptor Control
reg   [31:0] out_Descriptor_Index             ;
// counter to read config information from memory when DMA as AHB master
wire  [2:0]  in_descriptor_counter            ;
// when signal high to read information 
wire         in_read_en                       ;
// signal to FSM indicate Request from external or internal 
reg   [1:0]  out_ext_req                 ;
// indicate read registers ready
wire             BusReadyToRead               ;
//reg              ReadyToRead_1;
reg              ReadyToRead;
// indicate write registers ready
wire             BusReadyToWrite              ;
// signal to FSM module to start the transfering
// signal to FIFO module to clear the fifo for new transfering
wire             out_EnableDmac               ;
// all input single request 
wire  [9:0]      DMACSREQ_in                  ;
// all output burst request
wire  [9:0]      DMACSREQ_out                 ;
// all output single request
wire  [9:0]      DMACBREQ_in                  ;
// all output burst request
wire  [9:0]      DMACBREQ_out                 ;
// the  periperal equipment number register of each channel's
reg   [3:0]      P_Number_0                   ;
reg   [3:0]      P_Number_1                   ;
reg   [3:0]      P_Number_2                   ;
reg   [3:0]      P_Number_3                   ;
reg   [3:0]      P_Number_4                   ;
reg   [3:0]      P_Number_5                   ;
// module slave send the transfer information which software configed 
		  // to the control FSM module
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
reg   [31:0]     out_SourceAddr               ;// 1.
reg   [31:0]     out_DestAddr                 ;// 2.
reg   [11:0]     out_TransferSize             ;// 3.
reg              out_DestinationInc           ;// 4.
reg              out_SourceInc                ;// 5.
reg   [2:0]      out_SourceSize               ;// 6.
reg   [2:0]      out_DestinationSize          ;// 7.
reg   [2:0]      out_DestinationBurst         ;// 8.
reg   [2:0]      out_SourceBurst              ;// 9.
reg              out_Control_DorP             ;// 10.
reg   [1:0]      out_FlowControl              ;// 11.

// current channel finished register to restar a new transfer
reg   [5:0]      TransStart_r                 ;
// current channel request register 
reg   [5:0]      BurstOrSingleReq_r           ;
// current requested channels
reg   [5:0]      out_ShortTimeEnableChannel   ;
// one cycle later of BusReadyToWrite
reg              ReadyToWrite                 ;
//reg              ReadyToWrite_1;
// hold one cycle Address
reg   [31:0]     OneHclkLaterAddr             ;
//reg   [15:0]     OneHclkLaterAddr_1           ;
// signal for handle with nand booting 
reg              out_NandTransComplete        ;
// one block transfering finished
wire             out_TransferCompletedInt     ;

///  programmed bus hard_coded 32 bits  in_Hsize_s == 3'b010
  // write DMAC Regiters ready when DMAC as a slave 
  assign BusReadyToWrite = (in_HSIZE_s==3'b010) & in_HSEL_s & (in_HTRANS_s == 2'b10) & in_HWRITE_s   ;
  // read DMAC Registers ready when DMAC as a slave 
  assign BusReadyToRead  = (in_HSIZE_s==3'b010) & in_HSEL_s & (in_HTRANS_s != 2'b00) & (!in_HWRITE_s);
  // response is ok
  assign out_HRESP_s     =  2'b00 ;
  // the slave always ready
  assign out_HREADY_s    =  1'b1  ;
  // start a new DMA transfer 
  assign out_EnableDmac  =  out_ShortTimeEnableChannel[0] ||
                            out_ShortTimeEnableChannel[1] ||
                            out_ShortTimeEnableChannel[2] ||
                            out_ShortTimeEnableChannel[3] ||
                            out_ShortTimeEnableChannel[4] ||
                            out_ShortTimeEnableChannel[5] ;
  // transfer completed signal  to INTC module 
  assign  out_TransferCompletedInt = | DMACIntTCStatus_r      ;
  // transfer error signal to INTC module
  assign  out_DmacIntErrorInt      = | DMACIntErrorStatus_r   ;

  // current configed channels
  assign DMACEnbldChns_r = { DMACC5Configuration_r[0],
                             DMACC4Configuration_r[0],
                             DMACC3Configuration_r[0],
                             DMACC2Configuration_r[0],
                             DMACC1Configuration_r[0],
                             DMACC0Configuration_r[0]
                            };
			    
// delay one cycle for some control signal 
  always @ (posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn)
        begin                   // clear reigisters when reset_n is low
          ReadyToWrite                  <= 1'b0;
          //ReadyToWrite_1                <= 1'b0;
          OneHclkLaterAddr              <= 32'b0   ; 
          DMAC_Descriptor_Index_later_r <= 32'b0; 
        end
      else
        begin
            ReadyToWrite                <= BusReadyToWrite ; 
            OneHclkLaterAddr            <= in_HADDR_s ; 
            ReadyToRead                 <= BusReadyToRead ; 
          //ReadyToWrite_1                <= BusReadyToWrite ; 
          //ReadyToWrite                  <= ReadyToWrite_1;
          //OneHclkLaterAddr_1            <= in_HADDR_s ; 
          //OneHclkLaterAddr              <= OneHclkLaterAddr_1;
          //ReadyToRead_1                <= BusReadyToRead ; 
          //ReadyToRead                  <= ReadyToRead_1;
          DMAC_Descriptor_Index_later_r <= DMAC_Descriptor_Index_r; 
        end
    end


//============ When to Reload the Transfer Information =========
  always @ (posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn)
        Descriptor_Changed <= 0;// clear reigisters when reset_n is low
      else
        begin // compare current reg with the later reg  
          if( DMAC_Descriptor_Index_r == DMAC_Descriptor_Index_later_r )
            Descriptor_Changed <= 0 ;
          else
            Descriptor_Changed <= 1 ;
        end
    end
//==============================================================

//============== Generate the Output Finished Signal =============  
  always @ (posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn)
         out_NandTransComplete <= 0;
      else if(in_TransferCompleted)
             out_NandTransComplete <= 1;
    end
//================================================================


//================================================================
  always @ (posedge HCLK or negedge HRESETn)
    begin
      if (!HRESETn)
        begin                    // clear reigisters when reset_n is low
          DMACIntTCClear_r           <=  6'b0              ;
          DMACIntErrClr_r            <=  6'b0              ;
          DMACC0SrcAddr_r            <=  32'b0             ;
          DMACC0DestAddr_r           <=  32'b0             ;
          DMACC0Control_r            <=  26'b0             ;
          DMACC0Configuration_r      <=  20'b0             ;
          DMACC1SrcAddr_r            <=  32'b0             ;
          DMACC1DestAddr_r           <=  32'b0             ;
          DMACC1Control_r            <=  26'b0             ;
          DMACC1Configuration_r      <=  20'b0             ;
          DMACC2SrcAddr_r            <=  32'b0             ;
          DMACC2DestAddr_r           <=  32'b0             ;
          DMACC2Control_r            <=  26'b0             ;
          DMACC2Configuration_r      <=  20'b0             ;
          DMACC3SrcAddr_r            <=  32'b0             ;
          DMACC3DestAddr_r           <=  32'b0             ;
          DMACC3Control_r            <=  26'b0             ;
          DMACC3Configuration_r      <=  20'b0             ;
          DMACC4SrcAddr_r            <=  32'b0             ;
          DMACC4DestAddr_r           <=  32'b0             ;
          DMACC4Control_r            <=  26'b0             ;
          DMACC4Configuration_r      <=  20'b0             ;
          DMACC5SrcAddr_r            <=  32'b0             ;
          DMACC5DestAddr_r           <=  32'b0             ;
          DMACC5Control_r            <=  26'b0             ;
          DMACC5Configuration_r      <=  20'b0             ;
          DMACC0_Descriptor_Index_r  <=  32'b0             ;
          DMACC1_Descriptor_Index_r  <=  32'b0             ;
          DMACC2_Descriptor_Index_r  <=  32'b0             ;
          DMACC3_Descriptor_Index_r  <=  32'b0             ;
          DMACC4_Descriptor_Index_r  <=  32'b0             ;
          DMACC5_Descriptor_Index_r  <=  32'b0             ;
          DMAC_Configuration_r       <=  20'b0             ;
          DMAC_Control_r             <=  26'b0             ;
          DMAC_Src_Addr_r            <=  32'b0             ;
          DMAC_Dest_Addr_r           <=  32'b0             ;
          DMAC_Descriptor_Index_r    <=  32'b0             ;
          out_HRDATA_s               <=  32'b0             ;
        end
      else
        begin  
          //if((~out_NandTransComplete) && in_bootnand)
            //DMACC0Configuration_r[0]  <= 1'b1; // for boot config the start
          case(in_DMACActivedChannel) 
     // reload config information to the current channel which selected by arbit  
            3'b000:begin
                     if(in_TransferCompleted)                                //  when to clear the start flag 
                       DMACC0Configuration_r[0] <= 1'b0;                     //  channel 1 disabled
                     if(in_WriteSourceAddressRegisterAgain)
                       DMACC0SrcAddr_r <= in_CurrentSourceAddrressLog ;      // source addr reload
                     if(in_WriteDestinationAddressRegisterAgain)
                       DMACC0DestAddr_r <= in_CurrentDestinationAddrressLog ;  // dest addr reload
                     if(in_WriteTransferSizeAgain)
                       DMACC0Control_r[25:14] <= in_CurrentChannelTransferSizeLog ;   //transfer number reload
                   end
            3'b001:begin
                     if(in_TransferCompleted)                               //  when to clear the start flag 
                       DMACC1Configuration_r[0] <= 1'b0;                    //  channel 2 disabled
                     if(in_WriteSourceAddressRegisterAgain)                 
                       DMACC1SrcAddr_r <= in_CurrentSourceAddrressLog ;     // source addr reload
                     if(in_WriteDestinationAddressRegisterAgain)
                       DMACC1DestAddr_r <= in_CurrentDestinationAddrressLog ; // dest addr reload
                     if(in_WriteTransferSizeAgain)
                       DMACC1Control_r[25:14] <= in_CurrentChannelTransferSizeLog ;//transfer number reload
                   end
            3'b010:begin
                     if(in_TransferCompleted)                            //  when to clear the start flag 
                       DMACC2Configuration_r[0] <= 1'b0;                   //  channel 3 disabled
                     if(in_WriteSourceAddressRegisterAgain)
                       DMACC2SrcAddr_r <= in_CurrentSourceAddrressLog ;  // source addr reload
                     if(in_WriteDestinationAddressRegisterAgain)
                       DMACC2DestAddr_r <= in_CurrentDestinationAddrressLog ; // dest addr reload
                     if(in_WriteTransferSizeAgain)
                       DMACC2Control_r[25:14] <= in_CurrentChannelTransferSizeLog ;//transfer number reload
                   end
            3'b011:begin
                     if(in_TransferCompleted)                             //  when to clear the start flag 
                       DMACC3Configuration_r[0] <= 1'b0;                   //  channel 4 disabled
                     if(in_WriteSourceAddressRegisterAgain)
                       DMACC3SrcAddr_r <= in_CurrentSourceAddrressLog ;   // source addr reload
                     if(in_WriteDestinationAddressRegisterAgain)
                       DMACC3DestAddr_r <= in_CurrentDestinationAddrressLog ; // dest addr reload
                     if(in_WriteTransferSizeAgain)
                       DMACC3Control_r[25:14] <= in_CurrentChannelTransferSizeLog ;//transfer number reload
                   end
            3'b100:begin
                     if(in_TransferCompleted)                               //  when to clear the start flag
                       DMACC4Configuration_r[0] <= 1'b0;                     //  channel 5 disabled
                     if(in_WriteSourceAddressRegisterAgain)
                       DMACC4SrcAddr_r <= in_CurrentSourceAddrressLog ;  // source addr reload
                     if(in_WriteDestinationAddressRegisterAgain)
                       DMACC4DestAddr_r <= in_CurrentDestinationAddrressLog ; // dest addr reload
                     if(in_WriteTransferSizeAgain)
                       DMACC4Control_r[25:14] <= in_CurrentChannelTransferSizeLog ;//transfer number reload
                   end
            3'b101:begin
                     if(in_TransferCompleted)                           //  when to clear the start flag
                       DMACC5Configuration_r[0] <= 1'b0;                 //  channel 6 disabled
                     if(in_WriteSourceAddressRegisterAgain)
                       DMACC5SrcAddr_r <= in_CurrentSourceAddrressLog ;  // source addr reload
                     if(in_WriteDestinationAddressRegisterAgain)
                       DMACC5DestAddr_r <= in_CurrentDestinationAddrressLog ;  // dest addr reload
                     if(in_WriteTransferSizeAgain)
                       DMACC5Control_r[25:14] <= in_CurrentChannelTransferSizeLog ;//transfer number reload
                   end
          endcase
          if (ReadyToRead )
              //read the registers 
                   case(in_HADDR_s)
                     `ADDRESS_CHANNEL_00_SOURCEADDR :        out_HRDATA_s <= DMACC0SrcAddr_r              ;
                     `ADDRESS_CHANNEL_01_SOURCEADDR :        out_HRDATA_s <= DMACC1SrcAddr_r              ;
                     `ADDRESS_CHANNEL_02_SOURCEADDR :        out_HRDATA_s <= DMACC2SrcAddr_r              ;
                     `ADDRESS_CHANNEL_03_SOURCEADDR :        out_HRDATA_s <= DMACC3SrcAddr_r              ;
                     `ADDRESS_CHANNEL_04_SOURCEADDR :        out_HRDATA_s <= DMACC4SrcAddr_r              ;
                     `ADDRESS_CHANNEL_05_SOURCEADDR :        out_HRDATA_s <= DMACC5SrcAddr_r              ;
                     `ADDRESS_CHANNEL_00_DESTINATIONADDR :   out_HRDATA_s <= DMACC0DestAddr_r             ;
                     `ADDRESS_CHANNEL_01_DESTINATIONADDR :   out_HRDATA_s <= DMACC1DestAddr_r             ;
                     `ADDRESS_CHANNEL_02_DESTINATIONADDR :   out_HRDATA_s <= DMACC2DestAddr_r             ;
                     `ADDRESS_CHANNEL_03_DESTINATIONADDR :   out_HRDATA_s <= DMACC3DestAddr_r             ;
                     `ADDRESS_CHANNEL_04_DESTINATIONADDR :   out_HRDATA_s <= DMACC4DestAddr_r             ;
                     `ADDRESS_CHANNEL_05_DESTINATIONADDR :   out_HRDATA_s <= DMACC5DestAddr_r             ;
                     `ADDRESS_CHANNEL_00_CONTROL :           out_HRDATA_s <= {6'b0,DMACC0Control_r}       ;
                     `ADDRESS_CHANNEL_01_CONTROL :           out_HRDATA_s <= {6'b0,DMACC1Control_r}       ;
                     `ADDRESS_CHANNEL_02_CONTROL :           out_HRDATA_s <= {6'b0,DMACC2Control_r}       ;
                     `ADDRESS_CHANNEL_03_CONTROL :           out_HRDATA_s <= {6'b0,DMACC3Control_r}       ;
                     `ADDRESS_CHANNEL_04_CONTROL :           out_HRDATA_s <= {6'b0,DMACC4Control_r}       ;
                     `ADDRESS_CHANNEL_05_CONTROL :           out_HRDATA_s <= {6'b0,DMACC5Control_r}       ;
                     `ADDRESS_CHANNEL_00_CONFIGURATION :     out_HRDATA_s <= {12'b0,DMACC0Configuration_r};
                     `ADDRESS_CHANNEL_01_CONFIGURATION :     out_HRDATA_s <= {12'b0,DMACC1Configuration_r};
                     `ADDRESS_CHANNEL_02_CONFIGURATION :     out_HRDATA_s <= {12'b0,DMACC2Configuration_r};
                     `ADDRESS_CHANNEL_03_CONFIGURATION :     out_HRDATA_s <= {12'b0,DMACC3Configuration_r};
                     `ADDRESS_CHANNEL_04_CONFIGURATION :     out_HRDATA_s <= {12'b0,DMACC4Configuration_r};
                     `ADDRESS_CHANNEL_05_CONFIGURATION :     out_HRDATA_s <= {12'b0,DMACC5Configuration_r};
                     `ADDRESS_INT_STATUS :                   out_HRDATA_s <= {26'b0,DMACIntStatus_r}      ;
                     `ADDRESS_INT_TC_STATUS :                out_HRDATA_s <= {26'b0,DMACIntTCStatus_r}    ;
                     `ADDRESS_INT_ERROR_STATUS :             out_HRDATA_s <= {26'b0,DMACIntErrorStatus_r} ;
                     `ADDRESS_CHANNEL_00_DESCRIPTOR :        out_HRDATA_s <= DMACC0_Descriptor_Index_r    ;
		             `ADDRESS_CHANNEL_01_DESCRIPTOR :        out_HRDATA_s <= DMACC1_Descriptor_Index_r    ;
		             `ADDRESS_CHANNEL_02_DESCRIPTOR :        out_HRDATA_s <= DMACC2_Descriptor_Index_r    ;
		             `ADDRESS_CHANNEL_03_DESCRIPTOR :        out_HRDATA_s <= DMACC3_Descriptor_Index_r    ;
		             `ADDRESS_CHANNEL_04_DESCRIPTOR :        out_HRDATA_s <= DMACC4_Descriptor_Index_r    ;
		             `ADDRESS_CHANNEL_05_DESCRIPTOR :        out_HRDATA_s <= DMACC5_Descriptor_Index_r    ;
                     `ADDRESS_ENABLE_CHANNEL:                out_HRDATA_s <= {26'b0,DMACEnbldChns_r}      ;
                     default :                               out_HRDATA_s      <= 32'b0                   ;
                   endcase
          else if ((!BusReadyToWrite) & ReadyToWrite )
              //write the register
                   case(OneHclkLaterAddr)
                     `ADDRESS_CHANNEL_00_SOURCEADDR :        DMACC0SrcAddr_r <= in_HWDATA_s                 ;
                     `ADDRESS_CHANNEL_01_SOURCEADDR :        DMACC1SrcAddr_r <= in_HWDATA_s                 ;
                     `ADDRESS_CHANNEL_02_SOURCEADDR :        DMACC2SrcAddr_r <= in_HWDATA_s                 ;
                     `ADDRESS_CHANNEL_03_SOURCEADDR :        DMACC3SrcAddr_r <= in_HWDATA_s                 ;
                     `ADDRESS_CHANNEL_04_SOURCEADDR :        DMACC4SrcAddr_r <= in_HWDATA_s                 ;
                     `ADDRESS_CHANNEL_05_SOURCEADDR :        DMACC5SrcAddr_r <= in_HWDATA_s                 ;
                     `ADDRESS_CHANNEL_00_DESTINATIONADDR :   DMACC0DestAddr_r <= in_HWDATA_s                ;
                     `ADDRESS_CHANNEL_01_DESTINATIONADDR :   DMACC1DestAddr_r <= in_HWDATA_s                ;
                     `ADDRESS_CHANNEL_02_DESTINATIONADDR :   DMACC2DestAddr_r <= in_HWDATA_s                ;
                     `ADDRESS_CHANNEL_03_DESTINATIONADDR :   DMACC3DestAddr_r <= in_HWDATA_s                ;
                     `ADDRESS_CHANNEL_04_DESTINATIONADDR :   DMACC4DestAddr_r <= in_HWDATA_s                ;
                     `ADDRESS_CHANNEL_05_DESTINATIONADDR :   DMACC5DestAddr_r <= in_HWDATA_s                ;
                     `ADDRESS_CHANNEL_00_CONTROL :           DMACC0Control_r <= in_HWDATA_s[25:0]           ;
                     `ADDRESS_CHANNEL_01_CONTROL :           DMACC1Control_r <= in_HWDATA_s[25:0]           ;
                     `ADDRESS_CHANNEL_02_CONTROL :           DMACC2Control_r <= in_HWDATA_s[25:0]           ;
                     `ADDRESS_CHANNEL_03_CONTROL :           DMACC3Control_r <= in_HWDATA_s[25:0]           ;
                     `ADDRESS_CHANNEL_04_CONTROL :           DMACC4Control_r <= in_HWDATA_s[25:0]           ;
                     `ADDRESS_CHANNEL_05_CONTROL :           DMACC5Control_r <= in_HWDATA_s[25:0]           ;
                     `ADDRESS_CHANNEL_00_CONFIGURATION :     DMACC0Configuration_r <= in_HWDATA_s[19:0]     ;
                     `ADDRESS_CHANNEL_01_CONFIGURATION :     DMACC1Configuration_r <= in_HWDATA_s[19:0]     ;
                     `ADDRESS_CHANNEL_02_CONFIGURATION :     DMACC2Configuration_r <= in_HWDATA_s[19:0]     ;
                     `ADDRESS_CHANNEL_03_CONFIGURATION :     DMACC3Configuration_r <= in_HWDATA_s[19:0]     ;
                     `ADDRESS_CHANNEL_04_CONFIGURATION :     DMACC4Configuration_r <= in_HWDATA_s[19:0]     ;
                     `ADDRESS_CHANNEL_05_CONFIGURATION :     DMACC5Configuration_r <= in_HWDATA_s[19:0]     ;
                     `ADDRESS_INT_TC_CLEAR :                 DMACIntTCClear_r <= in_HWDATA_s[5:0]           ;
                     `ADDRESS_INT_ERROR_CLEAR :              DMACIntErrClr_r  <= in_HWDATA_s[5:0]           ;
                     `ADDRESS_CHANNEL_00_DESCRIPTOR :        DMACC0_Descriptor_Index_r <= in_HWDATA_s       ;
                     `ADDRESS_CHANNEL_01_DESCRIPTOR :        DMACC1_Descriptor_Index_r <= in_HWDATA_s       ;
                     `ADDRESS_CHANNEL_02_DESCRIPTOR :        DMACC2_Descriptor_Index_r <= in_HWDATA_s       ;
                     `ADDRESS_CHANNEL_03_DESCRIPTOR :        DMACC3_Descriptor_Index_r <= in_HWDATA_s       ;
                     `ADDRESS_CHANNEL_04_DESCRIPTOR :        DMACC4_Descriptor_Index_r <= in_HWDATA_s       ;
                     `ADDRESS_CHANNEL_05_DESCRIPTOR :        DMACC5_Descriptor_Index_r <= in_HWDATA_s       ;
                   endcase

          else if(in_read_en)  // when to read descriptor from memory
            begin                                                                                 
              case(in_descriptor_counter)// indicate which word to which reg
                3'b100:     DMAC_Configuration_r      <=  in_HRDATA_m[19:0]     ; // the last one to start
                3'b011:     DMAC_Control_r            <=  in_HRDATA_m[25:0]     ;
                3'b010:     DMAC_Src_Addr_r           <=  in_HRDATA_m           ;
                3'b001:     DMAC_Dest_Addr_r          <=  in_HRDATA_m           ;
                3'b000:     DMAC_Descriptor_Index_r   <=  in_HRDATA_m           ;
              endcase
            end

          else 
            begin
              out_HRDATA_s  <= 32'b0            ;
              if( Descriptor_Changed == 1'b1 )      // when to read descriptor
                case( DMAC_Configuration_r[17:15] ) // read to which channel
		// one descriptor include with :
		// 1. source address 2. destination address 3. control information 
		// 4. config information 5. next descriptor index
		  // channel 1
                  3'b001:begin
                           DMACC0SrcAddr_r             <=           DMAC_Src_Addr_r          ;// 1
                           DMACC0DestAddr_r            <=           DMAC_Dest_Addr_r         ;// 2
                           DMACC0Control_r             <=           DMAC_Control_r           ;// 3
                           DMACC0Configuration_r       <=           DMAC_Configuration_r     ;// 4
                           DMACC0_Descriptor_Index_r   <=           DMAC_Descriptor_Index_r  ;// 5
                         end
                  // channel 2
		  3'b010:begin
                           DMACC1SrcAddr_r             <=           DMAC_Src_Addr_r          ;// 1
                           DMACC1DestAddr_r            <=           DMAC_Dest_Addr_r         ;// 2
                           DMACC1Control_r             <=           DMAC_Control_r           ;// 3
                           DMACC1Configuration_r       <=           DMAC_Configuration_r     ;// 4
                           DMACC1_Descriptor_Index_r   <=           DMAC_Descriptor_Index_r  ;// 5
                         end
                  // channel 3
		  3'b011:begin
                           DMACC2SrcAddr_r             <=           DMAC_Src_Addr_r          ;// 1
                           DMACC2DestAddr_r            <=           DMAC_Dest_Addr_r         ;// 2
                           DMACC2Control_r             <=           DMAC_Control_r           ;// 3
                           DMACC2Configuration_r       <=           DMAC_Configuration_r     ;// 4
                           DMACC2_Descriptor_Index_r   <=           DMAC_Descriptor_Index_r  ;// 5
                         end
                  // channel 4
		  3'b100:begin
                           DMACC3SrcAddr_r             <=           DMAC_Src_Addr_r          ;// 1
                           DMACC3DestAddr_r            <=           DMAC_Dest_Addr_r         ;// 2
                           DMACC3Control_r             <=           DMAC_Control_r           ;// 3
                           DMACC3Configuration_r       <=           DMAC_Configuration_r     ;// 4
                           DMACC3_Descriptor_Index_r   <=           DMAC_Descriptor_Index_r  ;// 5
                         end
                 // channel 5
		 3'b101:begin
                          DMACC4SrcAddr_r              <=           DMAC_Src_Addr_r          ;// 1
                          DMACC4DestAddr_r             <=           DMAC_Dest_Addr_r         ;// 2
                          DMACC4Control_r              <=           DMAC_Control_r           ;// 3
                          DMACC4Configuration_r        <=           DMAC_Configuration_r     ;// 4
                          DMACC4_Descriptor_Index_r    <=           DMAC_Descriptor_Index_r  ;// 5
                        end
                 // channel 6
		 3'b110:begin
                          DMACC5SrcAddr_r              <=           DMAC_Src_Addr_r          ;// 1
                          DMACC5DestAddr_r             <=           DMAC_Dest_Addr_r         ;// 2
                          DMACC5Control_r              <=           DMAC_Control_r           ;// 3
                          DMACC5Configuration_r        <=           DMAC_Configuration_r     ;// 4
                          DMACC5_Descriptor_Index_r    <=           DMAC_Descriptor_Index_r  ;// 5
                        end
                endcase
            end
        end
    end

   reg   DMACBREQ_EXTERNAL_1;

   always @ (posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn)
         DMACBREQ_EXTERNAL_1 <= 1'b0;
      else  
        DMACBREQ_EXTERNAL_1  <=  in_DMACBREQ_EXTERNAL_1;
    end
    

assign out_external_req[0] = DMACBREQ_EXTERNAL_1 &  out_ext_req[0];
assign out_external_req[1] = 0;

// all Burst requests for peripheral equipments data in  
  assign DMACBREQ_in  = { in_DMACBREQ_EXTERNAL_2, 
                             DMACBREQ_EXTERNAL_1,
                          in_DMACBREQ_MMCin     ,
                          in_DMACBREQ_NANDin    ,
                          in_DMACBREQ_SPIin     ,
                          in_DMACBREQ_AC97in    ,
                          in_DMACBREQ_UART2in   ,
                          in_DMACBREQ_UART1in   ,
                          in_DMACBREQ_USBin     ,
                          1'b0
                        };
// all Burst requests for peripheral equipments data out 
  assign DMACBREQ_out = { in_DMACBREQ_EXTERNAL_2, 
                             DMACBREQ_EXTERNAL_1,
                          in_DMACBREQ_MMCout    ,
                          in_DMACBREQ_NANDout   ,
                          in_DMACBREQ_SPIout    ,
                          in_DMACBREQ_AC97out   ,
                          in_DMACBREQ_UART2out  ,
                          in_DMACBREQ_UART1out  ,
                          in_DMACBREQ_USBout    ,
                          1'b0
                        };
// all Single requests for peripheral equipments data in 
  assign DMACSREQ_in  = { 2'b0                 ,
                          in_DMACSREQ_MMCin    ,
                          in_DMACSREQ_NANDin   ,
                          in_DMACSREQ_SPIin    ,
                          in_DMACSREQ_AC97in   ,
                          in_DMACSREQ_UART2in  ,
                          in_DMACSREQ_UART1in  ,
                          in_DMACSREQ_USBin    ,
                          1'b0
                        };
// all Single requests for peripheral equipments data out
  assign DMACSREQ_out = { 2'b0                 ,
                          in_DMACSREQ_MMCout   ,
                          in_DMACSREQ_NANDout  ,
                          in_DMACSREQ_SPIout   ,
                          in_DMACSREQ_AC97out  ,
                          in_DMACSREQ_UART2out ,
                          in_DMACSREQ_UART1out ,
                          in_DMACSREQ_USBout   ,
                          1'b0
                        };

//============================================================
// load the peripheral equipment's number to P_number register
  always @ (DMACC0Configuration_r or
            DMACC1Configuration_r or
            DMACC2Configuration_r or
            DMACC3Configuration_r or
            DMACC4Configuration_r or
            DMACC5Configuration_r
            )
    begin
      if(DMACC0Configuration_r[0])// when to load 
        begin
          case(DMACC0Configuration_r[2:1])
	   // data from M 2 P, P_number in [14:11]
            2'b01:  P_Number_0 = DMACC0Configuration_r[14:11] ;
	   // data from P 2 M, P_number in [10:7] 
            2'b10:  P_Number_0 = DMACC0Configuration_r[10:7]  ;
            default:P_Number_0 = 4'b0;
          endcase
        end
      else
        P_Number_0 = 4'b0;
      if(DMACC1Configuration_r[0])// when to load 
        begin
          case(DMACC1Configuration_r[2:1])
	   // data from M 2 P, P_number in [14:11]	  
            2'b01:  P_Number_1 = DMACC1Configuration_r[14:11] ;
	    // data from P 2 M, P_number in [10:7] 
            2'b10:  P_Number_1 = DMACC1Configuration_r[10:7]  ;
            default:P_Number_1 = 4'b0;
          endcase
        end
      else
        P_Number_1 = 4'b0;
      if(DMACC2Configuration_r[0])// when to load 
        begin
          case(DMACC2Configuration_r[2:1])
	   // data from M 2 P, P_number in [14:11]	  
            2'b01:  P_Number_2 = DMACC2Configuration_r[14:11] ;
	    // data from P 2 M, P_number in [10:7] 
            2'b10:  P_Number_2 = DMACC2Configuration_r[10:7]  ;
            default:P_Number_2 = 4'b0;
          endcase
        end
      else
        P_Number_2 = 4'b0;
      if(DMACC3Configuration_r[0])// when to load 
        begin
          case(DMACC3Configuration_r[2:1])
	   // data from M 2 P, P_number in [14:11]	  
            2'b01:  P_Number_3 = DMACC3Configuration_r[14:11] ;
	    // data from P 2 M, P_number in [10:7] 
            2'b10:  P_Number_3 = DMACC3Configuration_r[10:7]  ;
            default:P_Number_3 = 4'b0;
          endcase
        end
      else
        P_Number_3 = 4'b0;
      if(DMACC4Configuration_r[0])// when to load 
        begin
          case(DMACC4Configuration_r[2:1])
	   // data from M 2 P, P_number in [14:11]	  
            2'b01:  P_Number_4 = DMACC4Configuration_r[14:11] ;
	    // data from P 2 M, P_number in [10:7] 
            2'b10:  P_Number_4 = DMACC4Configuration_r[10:7]  ;
            default:P_Number_4 = 4'b0;
          endcase
        end
      else
        P_Number_4 = 4'b0;
      if(DMACC5Configuration_r[0])// when to load 
        begin
          case(DMACC5Configuration_r[2:1])
	   // data from M 2 P, P_number in [14:11]	  
            2'b01:  P_Number_5 = DMACC5Configuration_r[14:11] ;
	    // data from P 2 M, P_number in [10:7] 
            2'b10:  P_Number_5 = DMACC5Configuration_r[10:7]  ;
            default:P_Number_5 = 4'b0;
          endcase
        end
      else
        P_Number_5 = 4'b0;
    end
//===========================================================================

//============== Generate the number of the configed channel with the request =========
//=================== Generate the signal indicate Request is comming =================  
  always @(posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn) 
        begin // clear reigisters when reset_n is low
          out_ShortTimeEnableChannel    <= 6'b0;
          BurstOrSingleReq_r            <= 6'b0;
        end
      else 
        begin
          if(DMACC0Configuration_r[0]==1'b0) // when to start a new DMA transfer
             out_ShortTimeEnableChannel[0] <= 1'b0;
          else  begin
              case(P_Number_0)  // select this channel,but select which peripheral number 
	       // Generate the signal indicate Request is comming
                `P_ONE   : if(DMACBREQ_out[1] || DMACSREQ_out[1] || DMACBREQ_in[1] || DMACSREQ_in[1])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0; 
                `P_TWO   : if(DMACBREQ_out[2] || DMACSREQ_out[2] || DMACBREQ_in[2] || DMACSREQ_in[2])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0;
                `P_THREE : if(DMACBREQ_out[3] || DMACSREQ_out[3] || DMACBREQ_in[3] || DMACSREQ_in[3])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0;
                `P_FOUR  : if(DMACBREQ_out[4] || DMACSREQ_out[4] || DMACBREQ_in[4] || DMACSREQ_in[4])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0;
                `P_FIVE  : if(DMACBREQ_out[5] || DMACSREQ_out[5] || DMACBREQ_in[5] || DMACSREQ_in[5])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0;
                `P_SIX   : if(DMACBREQ_out[6] || DMACSREQ_out[6] || DMACBREQ_in[6] || DMACSREQ_in[6])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0;
                `P_SEVEN : if(DMACBREQ_out[7] || DMACSREQ_out[7] || DMACBREQ_in[7] || DMACSREQ_in[7])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0;
                `P_EIGHT : if(DMACBREQ_out[8] || DMACSREQ_out[8] || DMACBREQ_in[8] || DMACSREQ_in[8])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0;
		        `P_NINE  : if(DMACBREQ_out[9] || DMACSREQ_out[9] || DMACBREQ_in[9] || DMACSREQ_in[9])
                           BurstOrSingleReq_r[0] <= 1'b1;
                         else
                           BurstOrSingleReq_r[0] <= 1'b0;	   
                default:   BurstOrSingleReq_r[0] <= 1'b0;
              endcase
              case(DMACC0Configuration_r[2:1]) 
                2'b01: begin // flow direction  M 2 P
		      // Generate the number of the configed channel with the request
		      // select this channel,but select which peripheral number 
                         case(P_Number_0)
                           `P_ONE  :if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[1] || DMACSREQ_out[1] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;
                           `P_TWO  :if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[2] || DMACSREQ_out[2] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;
                           `P_THREE:if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[3] || DMACSREQ_out[3] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;
                           `P_FOUR :if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[4] || DMACSREQ_out[4] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;
                           `P_FIVE :if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[5] || DMACSREQ_out[5] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;
                           `P_SIX  :if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[6] || DMACSREQ_out[6] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;
                           `P_SEVEN:if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[7] || DMACSREQ_out[7] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;
                           `P_EIGHT:if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[8] || DMACSREQ_out[8] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;
			   `P_NINE :if(TransStart_r[0] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[9] || DMACSREQ_out[9] )
                                        out_ShortTimeEnableChannel[0] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[0] <= 1'b0;	    
                         endcase
                       end
                2'b10: begin   // flow direction P 2 M
		 // select this channel,but select which peripheral number
                          case(P_Number_0)
                            `P_ONE   :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[1] || DMACSREQ_in[1] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
                            `P_TWO   :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[2] || DMACSREQ_in[2] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
                            `P_THREE :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[3] || DMACSREQ_in[3] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
                            `P_FOUR  :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[4] || DMACSREQ_in[4] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
                            `P_FIVE  :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[5] || DMACSREQ_in[5] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
                            `P_SIX   :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[6] || DMACSREQ_in[6] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
                            `P_SEVEN :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[7] || DMACSREQ_in[7] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
                            `P_EIGHT :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[8] || DMACSREQ_in[8] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
		            `P_NINE  :if(TransStart_r[0] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[9] || DMACSREQ_in[9] )
                                          out_ShortTimeEnableChannel[0] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[0] <= 1'b0;
                          endcase
                        end  
	     // M 2 M without request,so when configed this channel,transfer will be start
                2'b00: out_ShortTimeEnableChannel[0] <= 1'b1;
              endcase           
            end
        
      if(DMACC1Configuration_r[0]==1'b0) // when to start a new DMA transfer
        out_ShortTimeEnableChannel[1] <= 1'b0;
      else  begin
              case(P_Number_1) // select this channel,but select which peripheral number 
	       // Generate the signal indicate Request is comming
                `P_ONE   : if(DMACBREQ_out[1] || DMACSREQ_out[1] || DMACBREQ_in[1] || DMACSREQ_in[1])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0; 
                `P_TWO   : if(DMACBREQ_out[2] || DMACSREQ_out[2] || DMACBREQ_in[2] || DMACSREQ_in[2])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0;
                `P_THREE : if(DMACBREQ_out[3] || DMACSREQ_out[3] || DMACBREQ_in[3] || DMACSREQ_in[3])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0;
                `P_FOUR  : if(DMACBREQ_out[4] || DMACSREQ_out[4] || DMACBREQ_in[4] || DMACSREQ_in[4])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0;
                `P_FIVE  : if(DMACBREQ_out[5] || DMACSREQ_out[5] || DMACBREQ_in[5] || DMACSREQ_in[5])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0;
                `P_SIX   : if(DMACBREQ_out[6] || DMACSREQ_out[6] || DMACBREQ_in[6] || DMACSREQ_in[6])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0;
                `P_SEVEN : if(DMACBREQ_out[7] || DMACSREQ_out[7] || DMACBREQ_in[7] || DMACSREQ_in[7])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0;
                `P_EIGHT : if(DMACBREQ_out[8] || DMACSREQ_out[8] || DMACBREQ_in[8] || DMACSREQ_in[8])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0;
                `P_NINE  : if(DMACBREQ_out[9] || DMACSREQ_out[9] || DMACBREQ_in[9] || DMACSREQ_in[9])
                           BurstOrSingleReq_r[1] <= 1'b1;
                         else
                           BurstOrSingleReq_r[1] <= 1'b0;
              endcase
              case(DMACC1Configuration_r[2:1])
                2'b01: begin// flow direction  M 2 P
		      // Generate the number of the configed channel with the request
		      // select this channel,but select which peripheral number 
                         case(P_Number_1)
                           `P_ONE  :if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[1] || DMACSREQ_out[1] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
                           `P_TWO  :if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[2] || DMACSREQ_out[2] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
                           `P_THREE:if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[3] || DMACSREQ_out[3] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
                           `P_FOUR :if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[4] || DMACSREQ_out[4] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
                           `P_FIVE :if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[5] || DMACSREQ_out[5] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
                           `P_SIX  :if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[6] || DMACSREQ_out[6] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
                           `P_SEVEN:if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[7] || DMACSREQ_out[7] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
                           `P_EIGHT:if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[8] || DMACSREQ_out[8] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
	                   `P_NINE :if(TransStart_r[1] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[9] || DMACSREQ_out[9] )
                                        out_ShortTimeEnableChannel[1] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[1] <= 1'b0;
                         endcase
                       end
                2'b10: begin// flow direction P 2 M
		 // select this channel,but select which peripheral number
                          case(P_Number_1)
                            `P_ONE   :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[1] || DMACSREQ_in[1] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
                            `P_TWO   :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[2] || DMACSREQ_in[2] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
                            `P_THREE :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[3] || DMACSREQ_in[3] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
                            `P_FOUR  :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[4] || DMACSREQ_in[4] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
                            `P_FIVE  :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[5] || DMACSREQ_in[5] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
                            `P_SIX   :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[6] || DMACSREQ_in[6] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
                            `P_SEVEN :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[7] || DMACSREQ_in[7] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
                            `P_EIGHT :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[8] || DMACSREQ_in[8] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
			    `P_NINE  :if(TransStart_r[1] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[9] || DMACSREQ_in[9] )
                                          out_ShortTimeEnableChannel[1] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[1] <= 1'b0;
                          endcase
                        end    
		// M 2 M without request,so when configed this channel,transfer will be start 	                    
                2'b00: out_ShortTimeEnableChannel[1] <= 1'b1;
              endcase           
            end 
              
      if(DMACC2Configuration_r[0]==1'b0)// when to start a new DMA transfer
        out_ShortTimeEnableChannel[2] <= 1'b0;
      else  begin
              case(P_Number_2) // select this channel,but select which peripheral number 
	       // Generate the signal indicate Request is comming
                `P_ONE   : if(DMACBREQ_out[1] || DMACSREQ_out[1] || DMACBREQ_in[1] || DMACSREQ_in[1])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0; 
                `P_TWO   : if(DMACBREQ_out[2] || DMACSREQ_out[2] || DMACBREQ_in[2] || DMACSREQ_in[2])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0;
                `P_THREE : if(DMACBREQ_out[3] || DMACSREQ_out[3] || DMACBREQ_in[3] || DMACSREQ_in[3])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0;
                `P_FOUR  : if(DMACBREQ_out[4] || DMACSREQ_out[4] || DMACBREQ_in[4] || DMACSREQ_in[4])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0;
                `P_FIVE  : if(DMACBREQ_out[5] || DMACSREQ_out[5] || DMACBREQ_in[5] || DMACSREQ_in[5])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0;
                `P_SIX   : if(DMACBREQ_out[6] || DMACSREQ_out[6] || DMACBREQ_in[6] || DMACSREQ_in[6])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0;
                `P_SEVEN : if(DMACBREQ_out[7] || DMACSREQ_out[7] || DMACBREQ_in[7] || DMACSREQ_in[7])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0;
                `P_EIGHT : if(DMACBREQ_out[8] || DMACSREQ_out[8] || DMACBREQ_in[8] || DMACSREQ_in[8])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0;
		`P_NINE  : if(DMACBREQ_out[9] || DMACSREQ_out[9] || DMACBREQ_in[9] || DMACSREQ_in[9])
                           BurstOrSingleReq_r[2] <= 1'b1;
                         else
                           BurstOrSingleReq_r[2] <= 1'b0;	   
                default:   BurstOrSingleReq_r[2] <= 1'b0;
              endcase
              case(DMACC2Configuration_r[2:1])
                2'b01: begin// flow direction  M 2 P
		      // Generate the number of the configed channel with the request
		      // select this channel,but select which peripheral number 
                         case(P_Number_2)
                           `P_ONE  :if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[1] || DMACSREQ_out[1] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;
                           `P_TWO  :if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[2] || DMACSREQ_out[2] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;
                           `P_THREE:if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[3] || DMACSREQ_out[3] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;
                           `P_FOUR :if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[4] || DMACSREQ_out[4] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;
                           `P_FIVE :if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[5] || DMACSREQ_out[5] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;
                           `P_SIX  :if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[6] || DMACSREQ_out[6] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;
                           `P_SEVEN:if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[7] || DMACSREQ_out[7] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;
                           `P_EIGHT:if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[8] || DMACSREQ_out[8] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;
			   `P_NINE :if(TransStart_r[2] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[9] || DMACSREQ_out[9] )
                                        out_ShortTimeEnableChannel[2] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[2] <= 1'b0;	    
                         endcase
                       end
                2'b10: begin // flow direction P 2 M
		 // select this channel,but select which peripheral number
                          case(P_Number_2)
                            `P_ONE   :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[1] || DMACSREQ_in[1] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;
                            `P_TWO   :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[2] || DMACSREQ_in[2] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;
                            `P_THREE :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[3] || DMACSREQ_in[3] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;
                            `P_FOUR  :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[4] || DMACSREQ_in[4] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;
                            `P_FIVE  :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[5] || DMACSREQ_in[5] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;
                            `P_SIX   :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[6] || DMACSREQ_in[6] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;
                            `P_SEVEN :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[7] || DMACSREQ_in[7] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;
                            `P_EIGHT :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[8] || DMACSREQ_in[8] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;
	                    `P_NINE  :if(TransStart_r[2] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[9] || DMACSREQ_in[9] )
                                          out_ShortTimeEnableChannel[2] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[2] <= 1'b0;      
                          endcase
                        end   
		// M 2 M without request,so when configed this channel,transfer will be start 	            
                2'b00: out_ShortTimeEnableChannel[2] <= 1'b1;
              endcase           
            end 

      if(DMACC3Configuration_r[0]==1'b0) // when to start a new DMA transfer
        out_ShortTimeEnableChannel[3] <= 1'b0;
      else  begin
              case(P_Number_3)// select this channel,but select which peripheral number 
	       // Generate the signal indicate Request is comming
                `P_ONE   : if(DMACBREQ_out[1] || DMACSREQ_out[1] || DMACBREQ_in[1] || DMACSREQ_in[1])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0; 
                `P_TWO   : if(DMACBREQ_out[2] || DMACSREQ_out[2] || DMACBREQ_in[2] || DMACSREQ_in[2])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0;
                `P_THREE : if(DMACBREQ_out[3] || DMACSREQ_out[3] || DMACBREQ_in[3] || DMACSREQ_in[3])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0;
                `P_FOUR  : if(DMACBREQ_out[4] || DMACSREQ_out[4] || DMACBREQ_in[4] || DMACSREQ_in[4])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0;
                `P_FIVE  : if(DMACBREQ_out[5] || DMACSREQ_out[5] || DMACBREQ_in[5] || DMACSREQ_in[5])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0;
                `P_SIX   : if(DMACBREQ_out[6] || DMACSREQ_out[6] || DMACBREQ_in[6] || DMACSREQ_in[6])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0;
                `P_SEVEN : if(DMACBREQ_out[7] || DMACSREQ_out[7] || DMACBREQ_in[7] || DMACSREQ_in[7])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0;
                `P_EIGHT : if(DMACBREQ_out[8] || DMACSREQ_out[8] || DMACBREQ_in[8] || DMACSREQ_in[8])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0;
	        `P_NINE  : if(DMACBREQ_out[9] || DMACSREQ_out[9] || DMACBREQ_in[9] || DMACSREQ_in[9])
                           BurstOrSingleReq_r[3] <= 1'b1;
                         else
                           BurstOrSingleReq_r[3] <= 1'b0;	   
                default:   BurstOrSingleReq_r[3] <= 1'b0;
              endcase
              case(DMACC3Configuration_r[2:1])
                2'b01: begin// flow direction  M 2 P
		      // Generate the number of the configed channel with the request
		      // select this channel,but select which peripheral number 
                         case(P_Number_3)
                           `P_ONE  :if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[1] || DMACSREQ_out[1] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
                           `P_TWO  :if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[2] || DMACSREQ_out[2] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
                           `P_THREE:if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[3] || DMACSREQ_out[3] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
                           `P_FOUR :if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[4] || DMACSREQ_out[4] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
                           `P_FIVE :if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[5] || DMACSREQ_out[5] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
                           `P_SIX  :if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[6] || DMACSREQ_out[6] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
                           `P_SEVEN:if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[7] || DMACSREQ_out[7] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
                           `P_EIGHT:if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[8] || DMACSREQ_out[8] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
	                   `P_NINE :if(TransStart_r[3] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[9] || DMACSREQ_out[9] )
                                        out_ShortTimeEnableChannel[3] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[3] <= 1'b0;
                         endcase
                       end
                2'b10: begin// flow direction P 2 M
		 // select this channel,but select which peripheral number
                          case(P_Number_3)
                            `P_ONE   :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[1] || DMACSREQ_in[1] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
                            `P_TWO   :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[2] || DMACSREQ_in[2] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
                            `P_THREE :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[3] || DMACSREQ_in[3] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
                            `P_FOUR  :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[4] || DMACSREQ_in[4] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
                            `P_FIVE  :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[5] || DMACSREQ_in[5] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
                            `P_SIX   :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[6] || DMACSREQ_in[6] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
                            `P_SEVEN :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[7] || DMACSREQ_in[7] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
                            `P_EIGHT :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[8] || DMACSREQ_in[8] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
		            `P_NINE :if(TransStart_r[3] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[9] || DMACSREQ_in[9] )
                                          out_ShortTimeEnableChannel[3] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[3] <= 1'b0;
                          endcase
                        end  
		// M 2 M without request,so when configed this channel,transfer will be start 	                
                2'b00: out_ShortTimeEnableChannel[3] <= 1'b1;
              endcase           
            end 
            
      if(DMACC4Configuration_r[0]==1'b0)// when to start a new DMA transfer
        out_ShortTimeEnableChannel[4] <= 1'b0;
      else  begin
              case(P_Number_4)// select this channel,but select which peripheral number 
	       // Generate the signal indicate Request is comming
                `P_ONE   : if(DMACBREQ_out[1] || DMACSREQ_out[1] || DMACBREQ_in[1] || DMACSREQ_in[1])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0; 
                `P_TWO   : if(DMACBREQ_out[2] || DMACSREQ_out[2] || DMACBREQ_in[2] || DMACSREQ_in[2])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0;
                `P_THREE : if(DMACBREQ_out[3] || DMACSREQ_out[3] || DMACBREQ_in[3] || DMACSREQ_in[3])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0;
                `P_FOUR  : if(DMACBREQ_out[4] || DMACSREQ_out[4] || DMACBREQ_in[4] || DMACSREQ_in[4])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0;
                `P_FIVE  : if(DMACBREQ_out[5] || DMACSREQ_out[5] || DMACBREQ_in[5] || DMACSREQ_in[5])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0;
                `P_SIX   : if(DMACBREQ_out[6] || DMACSREQ_out[6] || DMACBREQ_in[6] || DMACSREQ_in[6])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0;
                `P_SEVEN : if(DMACBREQ_out[7] || DMACSREQ_out[7] || DMACBREQ_in[7] || DMACSREQ_in[7])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0;
	        `P_EIGHT : if(DMACBREQ_out[8] || DMACSREQ_out[8] || DMACBREQ_in[8] || DMACSREQ_in[8])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0;
	        `P_NINE  : if(DMACBREQ_out[9] || DMACSREQ_out[9] || DMACBREQ_in[9] || DMACSREQ_in[9])
                           BurstOrSingleReq_r[4] <= 1'b1;
                         else
                           BurstOrSingleReq_r[4] <= 1'b0;
                default:   BurstOrSingleReq_r[4] <= 1'b0;
              endcase
              case(DMACC4Configuration_r[2:1])
                2'b01: begin// flow direction  M 2 P
		      // Generate the number of the configed channel with the request
		      // select this channel,but select which peripheral number 
                         case(P_Number_4)
                           `P_ONE  :if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[1] || DMACSREQ_out[1] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
                           `P_TWO  :if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[2] || DMACSREQ_out[2] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
                           `P_THREE:if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[3] || DMACSREQ_out[3] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
                           `P_FOUR :if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[4] || DMACSREQ_out[4] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
                           `P_FIVE :if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[5] || DMACSREQ_out[5] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
                           `P_SIX  :if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[6] || DMACSREQ_out[6] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
                           `P_SEVEN:if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[7] || DMACSREQ_out[7] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
                           `P_EIGHT:if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[8] || DMACSREQ_out[8] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
		           `P_NINE :if(TransStart_r[4] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[9] || DMACSREQ_out[9] )
                                        out_ShortTimeEnableChannel[4] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[4] <= 1'b0;
                         endcase
                       end
                2'b10: begin// flow direction P 2 M
		 // select this channel,but select which peripheral number
                          case(P_Number_4)
                            `P_ONE   :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[1] || DMACSREQ_in[1] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
                            `P_TWO   :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[2] || DMACSREQ_in[2] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
                            `P_THREE :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[3] || DMACSREQ_in[3] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
                            `P_FOUR  :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[4] || DMACSREQ_in[4] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
                            `P_FIVE  :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[5] || DMACSREQ_in[5] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
                            `P_SIX   :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[6] || DMACSREQ_in[6] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
                            `P_SEVEN :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[7] || DMACSREQ_in[7] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
                            `P_EIGHT :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[8] || DMACSREQ_in[8] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
			    `P_NINE  :if(TransStart_r[4] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[9] || DMACSREQ_in[9] )
                                          out_ShortTimeEnableChannel[4] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[4] <= 1'b0;
                          endcase
                        end    
		// M 2 M without request,so when configed this channel,transfer will be start 	             
                2'b00: out_ShortTimeEnableChannel[4] <= 1'b1;
              endcase           
            end 
            
      if(DMACC5Configuration_r[0]==1'b0) // when to start a new DMA transfer
        out_ShortTimeEnableChannel[5] <= 1'b0;
      else  begin
              case(P_Number_5)// select this channel,but select which peripheral number 
	       // Generate the signal indicate Request is comming
                `P_ONE   : if(DMACBREQ_out[1] || DMACSREQ_out[1] || DMACBREQ_in[1] || DMACSREQ_in[1])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0; 
                `P_TWO   : if(DMACBREQ_out[2] || DMACSREQ_out[2] || DMACBREQ_in[2] || DMACSREQ_in[2])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0;
                `P_THREE : if(DMACBREQ_out[3] || DMACSREQ_out[3] || DMACBREQ_in[3] || DMACSREQ_in[3])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0;
                `P_FOUR  : if(DMACBREQ_out[4] || DMACSREQ_out[4] || DMACBREQ_in[4] || DMACSREQ_in[4])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0;
                `P_FIVE  : if(DMACBREQ_out[5] || DMACSREQ_out[5] || DMACBREQ_in[5] || DMACSREQ_in[5])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0;
                `P_SIX   : if(DMACBREQ_out[6] || DMACSREQ_out[6] || DMACBREQ_in[6] || DMACSREQ_in[6])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0;
                `P_SEVEN : if(DMACBREQ_out[7] || DMACSREQ_out[7] || DMACBREQ_in[7] || DMACSREQ_in[7])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0;
                `P_EIGHT : if(DMACBREQ_out[8] || DMACSREQ_out[8] || DMACBREQ_in[8] || DMACSREQ_in[8])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0;
		`P_NINE  : if(DMACBREQ_out[9] || DMACSREQ_out[9] || DMACBREQ_in[9] || DMACSREQ_in[9])
                           BurstOrSingleReq_r[5] <= 1'b1;
                         else
                           BurstOrSingleReq_r[5] <= 1'b0;	   
                default:   BurstOrSingleReq_r[5] <= 1'b0;
              endcase
              case(DMACC5Configuration_r[2:1])
                2'b01: begin// flow direction  M 2 P
		      // Generate the number of the configed channel with the request
		      // select this channel,but select which peripheral number 
                         case(P_Number_5)
                           `P_ONE  :if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[1] || DMACSREQ_out[1] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;
                           `P_TWO  :if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[2] || DMACSREQ_out[2] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;
                           `P_THREE:if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[3] || DMACSREQ_out[3] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;
                           `P_FOUR :if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[4] || DMACSREQ_out[4] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;
                           `P_FIVE :if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[5] || DMACSREQ_out[5] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;
                           `P_SIX  :if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[6] || DMACSREQ_out[6] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;
                           `P_SEVEN:if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[7] || DMACSREQ_out[7] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;
                           `P_EIGHT:if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[8] || DMACSREQ_out[8] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;
			   `P_NINE :if(TransStart_r[5] == 1'b0)
                                    begin
                                      if( DMACBREQ_out[9] || DMACSREQ_out[9] )
                                        out_ShortTimeEnableChannel[5] <= 1'b1;
                                    end
                                  else
                                    out_ShortTimeEnableChannel[5] <= 1'b0;	    
                         endcase
                       end
                2'b10: begin// flow direction P 2 M
		 // select this channel,but select which peripheral number
                          case(P_Number_5)
                            `P_ONE   :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[1] || DMACSREQ_in[1] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
                            `P_TWO   :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[2] || DMACSREQ_in[2] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
                            `P_THREE :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[3] || DMACSREQ_in[3] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
                            `P_FOUR  :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[4] || DMACSREQ_in[4] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
                            `P_FIVE  :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[5] || DMACSREQ_in[5] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
                            `P_SIX   :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[6] || DMACSREQ_in[6] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
                            `P_SEVEN :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[7] || DMACSREQ_in[7] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
                            `P_EIGHT :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[8] || DMACSREQ_in[8] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
			    `P_NINE  :if(TransStart_r[5] == 1'b0)
                                      begin
                                        if( DMACBREQ_in[9] || DMACSREQ_in[9] )
                                          out_ShortTimeEnableChannel[5] <= 1'b1;
                                      end
                                    else
                                      out_ShortTimeEnableChannel[5] <= 1'b0;
                          endcase
                        end 
		// M 2 M without request,so when configed this channel,transfer will be start
                2'b00: out_ShortTimeEnableChannel[5] <= 1'b1;
              endcase           
            end          
        end
    end
//=========================================================================================

//===================== Load the Transfer information for the next enabled channel ================= 
//============================ Load Control Information for transfer ===============================
  always @ (posedge HCLK or negedge HRESETn)
    begin
      if (!HRESETn)
      begin                        // clear the signals when reset is low
          out_TransferSize         <= 12'b0   ; 
          out_DestinationInc       <= 1'b0    ;
          out_SourceInc            <= 1'b0    ; 
          out_DestinationSize      <= 3'b0    ;
          out_SourceSize           <= 3'b0    ;
          out_DestinationBurst     <= 3'b0    ;
          out_SourceBurst          <= 3'b0    ;
          out_Control_DorP         <= 1'b0    ;
          out_FlowControl          <= 2'b0    ;
          TransStart_r             <= 6'b0    ;
          out_SourceAddr           <= 32'b0   ;
          out_DestAddr             <= 32'b0   ; 
	  out_Descriptor_Index     <= 32'b0   ;
	  out_ext_req         <= 2'b0    ;
        end
      else
      if(!out_EnableDmac)        // when no channel to transfer next step
        begin                    // clear the signals                    
          out_TransferSize         <= 12'b0   ;
          out_DestinationInc       <= 1'b0    ;
          out_SourceInc            <= 1'b0    ;
          out_DestinationSize      <= 3'b0    ;
          out_SourceSize           <= 3'b0    ;
          out_DestinationBurst     <= 3'b0    ;
          out_SourceBurst          <= 3'b0    ;
          out_Control_DorP         <= 1'b0    ;
          out_FlowControl          <= 2'b0    ;
          TransStart_r             <= 6'b0    ;
          out_SourceAddr           <= 32'b0   ;
          out_DestAddr             <= 32'b0   ;
          out_Descriptor_Index     <= 32'b0   ;
	  out_ext_req         <= 2'b0    ;
        end
      else
        case(in_DMACActivedChannel)   // load information for next enabled channel
	  // channel 1 
          3'b000: begin
	            // source address 
                    out_SourceAddr           <=   DMACC0SrcAddr_r               ;
		    // destination address
                    out_DestAddr             <=   DMACC0DestAddr_r              ;
		    // destination address increased 
                    out_DestinationInc       <=   DMACC0Control_r[13]           ;
		    // source address increased 
                    out_SourceInc            <=   DMACC0Control_r[12]           ;
		    // transfer control by DMAC or Peripheral Equipment 
                    out_Control_DorP         <=   DMACC0Configuration_r[6]      ;
		    // M2P,P2M or M2M 
                    out_FlowControl          <=   DMACC0Configuration_r[2:1]    ;
		    // External Req flag 
		    out_ext_req         <=   DMACC0Configuration_r[17] | DMACC0Configuration_r[14];
		    // Descriptor Index
                    out_Descriptor_Index     <=   DMACC0_Descriptor_Index_r     ;
                    if(in_TransStart)  TransStart_r[5:0] <= 6'b000001;
                    case({DMACC0Configuration_r[6],BurstOrSingleReq_r[0]})  
		      // control by peripheral Equipment
		      // transfer number is countered by peripheral Equipment 
                      2'b11   : case(DMACC0Control_r[2:0])
                                  `DMAC_SINGLE: out_TransferSize <=  {11'b0,1'b1}     ;
                                  `DMAC_INCR4 : out_TransferSize <=  {9'b0,3'b100}    ;
                                  `DMAC_INCR8 : out_TransferSize <=  {8'b0,4'b1000}   ;
                                  `DMAC_INCR16: out_TransferSize <=  {7'b0,5'b10000}  ;
                                  default: out_TransferSize <=  12'b0;
                                endcase
                      2'b10   : out_TransferSize <= {11'b0,1'b1};    
		      // control by DMAC
		      // transfer number is countered by DMAC      
                      default : out_TransferSize <= DMACC0Control_r[25:14] ;
                    endcase
                    case({DMACC0Configuration_r[2:1],BurstOrSingleReq_r[0]})//synopsys full_case parallel_case
                      3'b011:begin     //   m to p, channel 0
                             case(P_Number_0)
                             `P_ONE  : 
                               begin
                                 if( DMACBREQ_out[1] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[1] ) // Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
                             `P_TWO  : 
                               begin
                                 if( DMACBREQ_out[2] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[2] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
                             `P_THREE  : 
                               begin
                                 if( DMACBREQ_out[3] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[3] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
                             `P_FOUR  : 
                               begin
                                 if( DMACBREQ_out[4] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[4] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
                             `P_FIVE  : 
                               begin
                                 if( DMACBREQ_out[5] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[5] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
                             `P_SIX  : 
                               begin
                                 if( DMACBREQ_out[6] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[6] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
                             `P_SEVEN  : 
                               begin
                                 if( DMACBREQ_out[7] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[7] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
                             `P_EIGHT  : 
                               begin
                                 if( DMACBREQ_out[8] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[8] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
			       `P_NINE  : 
                               begin
                                 if( DMACBREQ_out[9] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[9] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC0Control_r[11:9]  ;
                                   end
                               end
                             endcase 
                             end
                      3'b101:begin //p to m, channel 0
                             case(P_Number_0)
                             `P_ONE :
                               begin
                                if( DMACBREQ_in[1] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[1] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end
                             `P_TWO :
                               begin
                                if( DMACBREQ_in[2] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[2] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end
                             `P_THREE :
                               begin
                                if( DMACBREQ_in[3] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[3] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end
                             `P_FOUR :
                               begin
                                if( DMACBREQ_in[4] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[4] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end
                             `P_FIVE :
                               begin
                                if( DMACBREQ_in[5] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[5] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end
                             `P_SIX :
                               begin
                                if( DMACBREQ_in[6] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[6] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end
                             `P_SEVEN :
                               begin
                                if( DMACBREQ_in[7] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[7] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end
                             `P_EIGHT :
                               begin
                                if( DMACBREQ_in[8] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[8] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end
			      `P_NINE :
                               begin
                                if( DMACBREQ_in[9] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC0Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC0Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC0Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[9] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC0Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC0Control_r[8:6]   ;
                                 end
                               end 
                             endcase
                             end
                      3'b000,3'b001: 
		        // M 2 M, transfer information load as configed information by software
                             begin
                               out_DestinationSize      <= DMACC0Control_r[11:9]  ;
                               out_SourceSize           <= DMACC0Control_r[8:6]   ;
                               out_DestinationBurst     <= DMACC0Control_r[5:3]   ;
                               out_SourceBurst          <= DMACC0Control_r[2:0]   ;
                             end
                    endcase
                  end
           // channel 2 
          3'b001: begin
	            // source address
                    out_SourceAddr           <=   DMACC1SrcAddr_r               ;
		    // destination address
                    out_DestAddr             <=   DMACC1DestAddr_r              ;
		    // destination address increased
                    out_DestinationInc       <=   DMACC1Control_r[13]           ;
		     // source address increased
                    out_SourceInc            <=   DMACC1Control_r[12]           ;
		    // transfer by DMAC or Peripheral Equipment
                    out_Control_DorP         <=   DMACC1Configuration_r[6]      ;
		    // Flow control 
                    out_FlowControl          <=   DMACC1Configuration_r[2:1]    ;
		    // External Req flag
		    out_ext_req         <=   DMACC1Configuration_r[17] | DMACC1Configuration_r[14];
		     // Descriptor Index
                    out_Descriptor_Index     <=   DMACC1_Descriptor_Index_r     ;
                    if(in_TransStart)  TransStart_r[5:0] <= 6'b000010;
                    case({DMACC1Configuration_r[6],BurstOrSingleReq_r[1]})
		      // control by peripheral Equipment
		      // transfer number is countered by peripheral Equipment 
                      2'b11   : case(DMACC1Control_r[2:0])
                                  `DMAC_SINGLE: out_TransferSize <=  {11'b0,1'b1}     ;
                                  `DMAC_INCR4 : out_TransferSize <=  {9'b0,3'b100}    ;
                                  `DMAC_INCR8 : out_TransferSize <=  {8'b0,4'b1000}   ;
                                  `DMAC_INCR16: out_TransferSize <=  {7'b0,5'b10000}  ;
                                  default: out_TransferSize <=  12'b0;
                                endcase
                      2'b10   : out_TransferSize <= {11'b0,1'b1};         
		      // control by DMAC
		      // transfer number is countered by DMAC  
                      default : out_TransferSize <= DMACC1Control_r[25:14] ;
                    endcase

                    case({DMACC1Configuration_r[2:1],BurstOrSingleReq_r[1]})//synopsys full_case parallel_case 
                      3'b011:begin     //   m to p 
                             case(P_Number_1)
                             `P_ONE  : 
                               begin
                                 if( DMACBREQ_out[1] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end                                                    
                                 if( DMACSREQ_out[1] )// Single Request
				                       // config information changed by P 
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end                                                    
                               end
                             `P_TWO  : 
                               begin                                                      
                                 if( DMACBREQ_out[2] )  // Burst Request 
                                   begin                                                  
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end                                                    
                                 if( DMACSREQ_out[2] )// Single Request
				                       // config information changed by P
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end                                                    
                               end
                             `P_THREE  : 
                               begin                                                      
                                 if( DMACBREQ_out[3] ) // Burst Request 
                                   begin                                                  
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end                                                    
                                 if( DMACSREQ_out[3] )// Single Request
				                       // config information changed by P
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end                                                    
                               end
                             `P_FOUR  : 
                               begin                                                      
                                 if( DMACBREQ_out[4] ) // Burst Request
                                   begin                                                  
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end                                                    
                                 if( DMACSREQ_out[4] )// Single Request
				                       // config information changed by P
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end                                                    
                               end
                             `P_FIVE  : 
                               begin                                                      
                                 if( DMACBREQ_out[5] )  // Burst Request
                                   begin                                                  
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end                                                    
                                 if( DMACSREQ_out[5] )// Single Request
				                       // config information changed by P
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end                                                    
                               end
                             `P_SIX  : 
                               begin                                                      
                                 if( DMACBREQ_out[6] )  // Burst Request
                                   begin                                                  
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end                                                    
                                 if( DMACSREQ_out[6] )// Single Request
				                       // config information changed by P
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end                                                    
                               end
                             `P_SEVEN  : 
                               begin                                                      
                                 if( DMACBREQ_out[7] ) // Burst Request
                                   begin                                                  
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end 
                                 if( DMACSREQ_out[7] )// Single Request
				                       // config information changed by P
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end                                                    
                               end
                             `P_EIGHT  : 
                               begin                                                      
                                 if( DMACBREQ_out[8] ) // Burst Request
                                   begin                                                  
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end                                                    
                                 if( DMACSREQ_out[8] )// Single Request
				                       // config information changed by P
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end                                                 
                               end
			     `P_NINE   : 
                               begin                                                      
                                 if( DMACBREQ_out[9] ) // Burst Request
                                   begin                                                  
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[8:6]   ; 
                                     out_DestinationBurst   <=   DMACC1Control_r[5:3]   ; 
                                     out_SourceBurst        <=   DMACC1Control_r[2:0]   ; 
                                   end                                                    
                                 if( DMACSREQ_out[9] )// Single Request
				                       // config information changed by P
                                   begin                                                  
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ; 
                                     out_SourceBurst        <=   `DMAC_SINGLE           ; 
                                     out_DestinationSize    <=   DMACC1Control_r[11:9]  ; 
                                     out_SourceSize         <=   DMACC1Control_r[11:9]  ; 
                                   end
                               end
                             endcase 
                             end
                      3'b101:begin
                             case(P_Number_1)
                             `P_ONE :
                               begin
                                if( DMACBREQ_in[1] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[1] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end                                 
                               end                                   
                             `P_TWO :
                               begin
                                if( DMACBREQ_in[2] ) // Burst Request
                                 begin                                                 
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end                                                   
                                if( DMACSREQ_in[2] )// Single Request
				                       // config information changed by P
                                 begin                                                 
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end
                               end
                             `P_THREE :
                               begin
                                if( DMACBREQ_in[3] ) // Burst Request
                                 begin                                                 
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end                                                   
                                if( DMACSREQ_in[3] )// Single Request
				                       // config information changed by P
                                 begin                                                 
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end
                               end
                             `P_FOUR :
                               begin                                                   
                                if( DMACBREQ_in[4] ) // Burst Request
                                 begin                                                 
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end                                                   
                                if( DMACSREQ_in[4] )// Single Request
				                       // config information changed by P
                                 begin                                                 
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end
                               end
                             `P_FIVE :
                               begin                                                   
                                if( DMACBREQ_in[5] ) // Burst Request
                                 begin                                                 
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end                                                   
                                if( DMACSREQ_in[5] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end
                               end
                             `P_SIX :
                               begin
                                if( DMACBREQ_in[6] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[6] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end
                               end
                             `P_SEVEN :
                               begin
                                if( DMACBREQ_in[7] )  // Burst Request
                                 begin                                                 
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end                                                   
                                if( DMACSREQ_in[7] )// Single Request
				                       // config information changed by P
                                 begin                                                 
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end
                               end
                             `P_EIGHT :
                               begin                                                   
                                if( DMACBREQ_in[8] )   // Burst Request 
                                 begin                                                 
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end                                                   
                                if( DMACSREQ_in[8] )// Single Request
				                       // config information changed by P
                                 begin                                                 
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end
                               end
			     `P_NINE :
                               begin                                                   
                                if( DMACBREQ_in[9] ) // Burst Request
                                 begin                                                 
                                   out_DestinationSize    <=   DMACC1Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC1Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC1Control_r[2:0]   ;
                                 end                                                   
                                if( DMACSREQ_in[9] )// Single Request
				                       // config information changed by P
                                 begin                                                 
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC1Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC1Control_r[8:6]   ;
                                 end
                               end
                             endcase                                                   
                             end                                                       
                      3'b000,3'b001:                                                   
                             begin 
		  // M 2 M, transfer information load as configed information by software
                               out_DestinationSize      <= DMACC1Control_r[11:9]  ;    
                               out_SourceSize           <= DMACC1Control_r[8:6]   ;    
                               out_DestinationBurst     <= DMACC1Control_r[5:3]   ;    
                               out_SourceBurst          <= DMACC1Control_r[2:0]   ;    
                             end                                                       
                    endcase                                                            
                  end                                                                  
        // channel 3                                                                               
          3'b010: begin  
	            // source address                                                              
                    out_SourceAddr           <= DMACC2SrcAddr_r               ; 
		    // destination address       
                    out_DestAddr             <= DMACC2DestAddr_r              ; 
		    // destination address increased        
                    out_DestinationInc       <= DMACC2Control_r[13]           ; 
		    // destination address increased       
                    out_SourceInc            <= DMACC2Control_r[12]           ; 
		    // transfer control by DMAC or Peripheral Equipment        
                    out_Control_DorP         <= DMACC2Configuration_r[6]      ; 
		    // M2P,P2M or M2M        
                    out_FlowControl          <= DMACC2Configuration_r[2:1]    ;
		    // External Req flag
		    out_ext_req         <= DMACC2Configuration_r[17] | DMACC2Configuration_r[14];
		    // Descriptor Index       
                    out_Descriptor_Index     <= DMACC2_Descriptor_Index_r     ;        
                    if(in_TransStart)                                                  
                      TransStart_r[5:0] <= 6'b000100;                                  
                    case({DMACC2Configuration_r[6],BurstOrSingleReq_r[2]})
		      // control by peripheral Equipment
		      // transfer number is countered by peripheral Equipment             
                      2'b11   : case(DMACC2Control_r[2:0])                             
                                  `DMAC_SINGLE: out_TransferSize <= {11'b0,1'b1};      
                                  `DMAC_INCR4 : out_TransferSize <= {9'b0,3'b100};     
                                  `DMAC_INCR8 : out_TransferSize <= {8'b0,4'b1000};    
                                  `DMAC_INCR16: out_TransferSize <= {7'b0,5'b10000};   
                                  default: out_TransferSize <=  12'b0;                 
                                endcase                                                
                      2'b10   : out_TransferSize <= {11'b0,1'b1};
		      // control by DMAC
		      // transfer number is countered by DMAC                       
                      default : out_TransferSize <= DMACC2Control_r[25:14] ;           
                    endcase                                                            
                    case({DMACC2Configuration_r[2:1],BurstOrSingleReq_r[2]})//synopsys full_case parallel_case 
                      3'b011:begin//   m to p
                             case(P_Number_2)
                             `P_ONE  : 
                               begin
                                 if( DMACBREQ_out[1] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[1] ) // Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
                             `P_TWO  : 
                               begin
                                 if( DMACBREQ_out[2] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[2] ) // Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
                             `P_THREE  : 
                               begin
                                 if( DMACBREQ_out[3] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[3] )// Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
                             `P_FOUR  : 
                               begin
                                 if( DMACBREQ_out[4] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[4] )// Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
                             `P_FIVE  : 
                               begin
                                 if( DMACBREQ_out[5] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[5] )// Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
                             `P_SIX  : 
                               begin
                                 if( DMACBREQ_out[6] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[6] )// Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
                             `P_SEVEN  : 
                               begin
                                 if( DMACBREQ_out[7] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[7] )// Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
                             `P_EIGHT  : 
                               begin
                                 if( DMACBREQ_out[8] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[8] )// Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
			     `P_NINE   : 
                               begin
                                 if( DMACBREQ_out[9] )// Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[9] )// Single Request
				                       // config information changed by P
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC2Control_r[11:9]  ;
                                   end
                               end
                             endcase
                             end
                      3'b101:begin //  p 2 m 
                             case(P_Number_2)
                             `P_ONE :
                               begin
                                if( DMACBREQ_in[1] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[1] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
                             `P_TWO :
                               begin
                                if( DMACBREQ_in[2] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[2] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
                             `P_THREE :
                               begin
                                if( DMACBREQ_in[3] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[3] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
                             `P_FOUR :
                               begin
                                if( DMACBREQ_in[4] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[4] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
                             `P_FIVE :
                               begin
                                if( DMACBREQ_in[5] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[5] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
                             `P_SIX :
                               begin
                                if( DMACBREQ_in[6] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[6] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
                             `P_SEVEN :
                               begin
                                if( DMACBREQ_in[7] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[7] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
                             `P_EIGHT :
                               begin
                                if( DMACBREQ_in[8] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[8] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
			     `P_NINE :
                               begin
                                if( DMACBREQ_in[9] )// Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC2Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC2Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC2Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[9] )// Single Request
				                       // config information changed by P
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC2Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC2Control_r[8:6]   ;
                                 end
                               end
                             endcase
                             end
                      3'b000,3'b001: 
		        // M 2 M, transfer information load as configed information by software
                             begin
                               out_DestinationSize      <= DMACC2Control_r[11:9]  ;
                               out_SourceSize           <= DMACC2Control_r[8:6]   ;
                               out_DestinationBurst     <= DMACC2Control_r[5:3]   ;
                               out_SourceBurst          <= DMACC2Control_r[2:0]   ;
                             end
                    endcase
                  end
          // channel 4 
          3'b011: begin
	            // source address
                    out_SourceAddr           <= DMACC3SrcAddr_r               ;
		     // destination address
                    out_DestAddr             <= DMACC3DestAddr_r              ;
		    // destination address increased 
                    out_DestinationInc       <= DMACC3Control_r[13]           ;
		    // source address increased 
                    out_SourceInc            <= DMACC3Control_r[12]           ;
		    // transfer control by DMAC or Peripheral Equipment 
                    out_Control_DorP         <= DMACC3Configuration_r[6]      ;
		    // External Req flag 
		    out_ext_req         <= DMACC3Configuration_r[17] | DMACC3Configuration_r[14];
		    // M2P,P2M or M2M 
                    out_FlowControl          <= DMACC3Configuration_r[2:1]    ;
		    // Descriptor Index
                    out_Descriptor_Index     <= DMACC3_Descriptor_Index_r     ;
                    if(in_TransStart)
                      TransStart_r[5:0] <= 6'b001000;
                    case({DMACC3Configuration_r[6],BurstOrSingleReq_r[3]})
		      // control by peripheral Equipment
		      // transfer number is countered by peripheral Equipment
                      2'b11   : case(DMACC3Control_r[2:0])
                                  `DMAC_SINGLE: out_TransferSize <= {11'b0,1'b1};
                                  `DMAC_INCR4 : out_TransferSize <= {9'b0,3'b100};
                                  `DMAC_INCR8 : out_TransferSize <= {8'b0,4'b1000};
                                  `DMAC_INCR16: out_TransferSize <= {7'b0,5'b10000};
                                  default: out_TransferSize <=  12'b0;
                                endcase
                      2'b10   : out_TransferSize <= {11'b0,1'b1};
		      // control by DMAC
		      // transfer number is countered by DMAC
                      default : out_TransferSize <= DMACC3Control_r[25:14] ;
                    endcase
                    case({DMACC3Configuration_r[2:1],BurstOrSingleReq_r[3]})//synopsys full_case parallel_case
                      3'b011:begin //   m to p                                                      
                             case(P_Number_3)
                             `P_ONE  : 
                               begin                                                     
                                 if( DMACBREQ_out[1] ) // Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[1] ) // Single Request
				                       // config information changed by P                                   
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
                             `P_TWO  : 
                               begin                                                     
                                 if( DMACBREQ_out[2] )// Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[2] )  // Single Request
				                       // config information changed by P
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
                             `P_THREE  : 
                               begin                                                     
                                 if( DMACBREQ_out[3] )// Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[3] ) // Single Request
				                       // config information changed by P
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
                             `P_FOUR  : 
                               begin                                                     
                                 if( DMACBREQ_out[4] )// Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[4] )// Single Request
				                       // config information changed by P 
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
                             `P_FIVE  : 
                               begin                                                     
                                 if( DMACBREQ_out[5] )// Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[5] )// Single Request
				                       // config information changed by P 
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
                             `P_SIX  : 
                               begin                                                     
                                 if( DMACBREQ_out[6] )// Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[6] )// Single Request
				                       // config information changed by P 
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
                             `P_SEVEN  : 
                               begin
                                 if( DMACBREQ_out[7] )// Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[7] )// Single Request
				                       // config information changed by P 
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
                             `P_EIGHT  : 
                               begin                                                     
                                 if( DMACBREQ_out[8] )// Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[8] )// Single Request
				                       // config information changed by P 
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
			     `P_NINE  : 
                               begin                                                     
                                 if( DMACBREQ_out[9] )// Burst Request
                                   begin                                                 
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC3Control_r[2:0]   ;
                                   end                                                   
                                 if( DMACSREQ_out[9] )// Single Request
				                       // config information changed by P 
                                   begin                                                 
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC3Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC3Control_r[11:9]  ;
                                   end                                                   
                               end
                             endcase                                                     
                             end                                                         
                      3'b101:begin                                                       
                             case(P_Number_3)
                             `P_ONE :
                               begin
                                if( DMACBREQ_in[1] )// Burst Request
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[1] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
                             `P_TWO :
                               begin 
                                if( DMACBREQ_in[2] )// Burst Request
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[2] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
                             `P_THREE :
                               begin 
                                if( DMACBREQ_in[3] )// Burst Request
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[3] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
                             `P_FOUR :
                               begin 
                                if( DMACBREQ_in[4] )// Burst Request
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[4] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
                             `P_FIVE :
                               begin 
                                if( DMACBREQ_in[5] )// Burst Request
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[5] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
                             `P_SIX :
                               begin 
                                if( DMACBREQ_in[6] )// Burst Request
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[6] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
                             `P_SEVEN :
                               begin 
                                if( DMACBREQ_in[7] )// Burst Request
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[7] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
                             `P_EIGHT :
                               begin 
                                if( DMACBREQ_in[8] )// Burst Request
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[8] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
			     `P_NINE :
                               begin                                                     
                                if( DMACBREQ_in[9] ) // Burst Request                                    
                                 begin                                                   
                                   out_DestinationSize    <=   DMACC3Control_r[11:9]  ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                   out_DestinationBurst   <=   DMACC3Control_r[5:3]   ;  
                                   out_SourceBurst        <=   DMACC3Control_r[2:0]   ;  
                                 end                                                     
                                if( DMACSREQ_in[9] )// Single Request
				                       // config information changed by P 
                                 begin                                                   
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;  
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;  
                                   out_DestinationSize    <=   DMACC3Control_r[8:6]   ;  
                                   out_SourceSize         <=   DMACC3Control_r[8:6]   ;  
                                 end
                               end
                             endcase 
                             end  
		       // M 2 M, transfer information load as configed information by software
                      3'b000,3'b001: 
                             begin 
                               out_DestinationSize      <= DMACC3Control_r[11:9]  ;      
                               out_SourceSize           <= DMACC3Control_r[8:6]   ;      
                               out_DestinationBurst     <= DMACC3Control_r[5:3]   ;      
                               out_SourceBurst          <= DMACC3Control_r[2:0]   ;      
                             end 
                    endcase 
                  end 
           // channel 5 
          3'b100: begin 
	            // source address
                    out_SourceAddr           <= DMACC4SrcAddr_r        ; 
		     // destination address                
                    out_DestAddr             <= DMACC4DestAddr_r       ; 
		     // destination address increased                
                    out_DestinationInc       <= DMACC4Control_r[13]    ; 
		    // source address increased                 
                    out_SourceInc            <= DMACC4Control_r[12]    ; 
		     // transfer control by DMAC or Peripheral Equipment                
                    out_Control_DorP         <= DMACC4Configuration_r[6] ; 
		    // External Req flag
		    out_ext_req         <= DMACC4Configuration_r[17] | DMACC4Configuration_r[14];
		    // M2P,P2M or M2M 
                    out_FlowControl          <= DMACC4Configuration_r[2:1]; 
		    // Descriptor Index 
                    out_Descriptor_Index     <= DMACC4_Descriptor_Index_r     ; 
                    if(in_TransStart) 
                      TransStart_r[5:0] <= 6'b010000;                                    
                    case({DMACC4Configuration_r[6],BurstOrSingleReq_r[4]}) 
		      // control by peripheral Equipment
		      // transfer number is countered by peripheral Equipment 
                      2'b11   : case(DMACC4Control_r[2:0]) 
                                  `DMAC_SINGLE: out_TransferSize <= {11'b0,1'b1};        
                                  `DMAC_INCR4 : out_TransferSize <= {9'b0,3'b100};       
                                  `DMAC_INCR8 : out_TransferSize <= {8'b0,4'b1000};      
                                  `DMAC_INCR16: out_TransferSize <= {7'b0,5'b10000};     
                                  default: out_TransferSize <=  12'b0; 
                                endcase 
                      2'b10   : out_TransferSize <= {11'b0,1'b1}; 
		      // control by DMAC
		      // transfer number is countered by DMAC 
                      default : out_TransferSize <= DMACC4Control_r[25:14] ;             
                    endcase                                                              
                    case({DMACC4Configuration_r[2:1],BurstOrSingleReq_r[4]})//synopsys full_case parallel_case 
                      3'b011:begin //   m to p 
                              case(P_Number_4)
                             `P_ONE  : 
                               begin
                                 if( DMACBREQ_out[1] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[1] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
                             `P_TWO  : 
                               begin
                                 if( DMACBREQ_out[2] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[2] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
                             `P_THREE  : 
                               begin
                                 if( DMACBREQ_out[3] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[3] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
                             `P_FOUR  : 
                               begin
                                 if( DMACBREQ_out[4] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[4] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
                             `P_FIVE  : 
                               begin
                                 if( DMACBREQ_out[5] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[5] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
                             `P_SIX  : 
                               begin
                                 if( DMACBREQ_out[6] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[6] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
                             `P_SEVEN  : 
                               begin
                                 if( DMACBREQ_out[7] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[7] ) // Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
                             `P_EIGHT  : 
                               begin
                                 if( DMACBREQ_out[8] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[8] ) // Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
			      `P_NINE  : 
                               begin
                                 if( DMACBREQ_out[9] ) // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[9] ) // Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC4Control_r[11:9]  ;
                                   end
                               end
                             endcase
                             end
                      3'b101:begin
                             case(P_Number_4)
                             `P_ONE :
                               begin
                                if( DMACBREQ_in[1] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[1] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
                             `P_TWO :
                               begin
                                if( DMACBREQ_in[2] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[2] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
                             `P_THREE :
                               begin
                                if( DMACBREQ_in[3] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[3] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
                             `P_FOUR :
                               begin
                                if( DMACBREQ_in[4] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[4] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
                             `P_FIVE :
                               begin
                                if( DMACBREQ_in[5] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[5] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
                             `P_SIX :
                               begin
                                if( DMACBREQ_in[6] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[6] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
                             `P_SEVEN :
                               begin
                                if( DMACBREQ_in[7] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[7] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
                             `P_EIGHT :
                               begin
                                if( DMACBREQ_in[8] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[8] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
			     `P_NINE :
                               begin
                                if( DMACBREQ_in[9] ) // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC4Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC4Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC4Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[9] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC4Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC4Control_r[8:6]   ;
                                 end
                               end
                             endcase
                             end
		   // M 2 M, transfer information load as configed information by software
                      3'b000,3'b001:
                             begin
                               out_DestinationSize      <= DMACC4Control_r[11:9]  ;
                               out_SourceSize           <= DMACC4Control_r[8:6]   ;
                               out_DestinationBurst     <= DMACC4Control_r[5:3]   ;
                               out_SourceBurst          <= DMACC4Control_r[2:0]   ;
                             end
                    endcase
                  end
           // channel 6
          3'b101: begin
	             // source address
                    out_SourceAddr           <= DMACC5SrcAddr_r               ;
		     // destination address
                    out_DestAddr             <= DMACC5DestAddr_r              ;
		    // destination address increased 
                    out_DestinationInc       <= DMACC5Control_r[13]           ;
		     // source address increased 
                    out_SourceInc            <= DMACC5Control_r[12]           ; 
		     // External Req flag 
		    out_ext_req         <= DMACC5Configuration_r[17] | DMACC5Configuration_r[14];
		     // transfer control by DMAC or Peripheral Equipment 
                    out_Control_DorP         <= DMACC5Configuration_r[6]      ;
		    // M2P,P2M or M2M 
                    out_FlowControl          <= DMACC5Configuration_r[2:1]    ;
		    // Descriptor Index
                    out_Descriptor_Index     <= DMACC5_Descriptor_Index_r     ;
                    if(in_TransStart)
                      TransStart_r[5:0] <= 6'b100000;
                    case({DMACC5Configuration_r[6],BurstOrSingleReq_r[5]})
		      // control by peripheral Equipment
		      // transfer number is countered by peripheral Equipment 
                      2'b11   : case(DMACC5Control_r[2:0])
                                  `DMAC_SINGLE: out_TransferSize <= {11'b0,1'b1};
                                  `DMAC_INCR4 : out_TransferSize <= {9'b0,3'b100};
                                  `DMAC_INCR8 : out_TransferSize <= {8'b0,4'b1000};
                                  `DMAC_INCR16: out_TransferSize <= {7'b0,5'b10000};
                                  default: out_TransferSize <=  12'b0;
                                endcase
                      2'b10   : out_TransferSize <= {11'b0,1'b1};
		      // control by DMAC
		      // transfer number is countered by DMAC 
                      default : out_TransferSize <= DMACC5Control_r[25:14] ;
                    endcase
                    case({DMACC5Configuration_r[2:1],BurstOrSingleReq_r[5]})//synopsys full_case parallel_case
                      3'b011:begin  //   m to p 
                               case(P_Number_5)
                             `P_ONE  : 
                               begin
                                 if( DMACBREQ_out[1] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[1] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
                             `P_TWO  : 
                               begin
                                 if( DMACBREQ_out[2] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[2] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
                             `P_THREE  : 
                               begin
                                 if( DMACBREQ_out[3] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[3] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
                             `P_FOUR  : 
                               begin
                                 if( DMACBREQ_out[4] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[4] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
                             `P_FIVE  : 
                               begin
                                 if( DMACBREQ_out[5] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[5] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
                             `P_SIX  : 
                               begin
                                 if( DMACBREQ_out[6] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[6] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
                             `P_SEVEN  : 
                               begin
                                 if( DMACBREQ_out[7] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[7] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
                             `P_EIGHT  : 
                               begin
                                 if( DMACBREQ_out[8] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[8] ) // Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
			     `P_NINE  : 
                               begin
                                 if( DMACBREQ_out[9] )  // Burst Request
                                   begin
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                     out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                     out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                   end
                                 if( DMACSREQ_out[9] )// Single Request
				                       // config information changed by P 
                                   begin
                                     out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                     out_SourceBurst        <=   `DMAC_SINGLE           ;
                                     out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                     out_SourceSize         <=   DMACC5Control_r[11:9]  ;
                                   end
                               end
                             endcase
                             end
                      3'b101:begin // p 2 m
                             case(P_Number_5)
                             `P_ONE :
                               begin
                                if( DMACBREQ_in[1] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[1] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
                             `P_TWO :
                               begin
                                if( DMACBREQ_in[2] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[2] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
                             `P_THREE :
                               begin
                                if( DMACBREQ_in[3] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[3] )// Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
                             `P_FOUR :
                               begin
                                if( DMACBREQ_in[4] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[4] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
                             `P_FIVE :
                               begin
                                if( DMACBREQ_in[5] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[5] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
                             `P_SIX :
                               begin
                                if( DMACBREQ_in[6] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[6] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
                             `P_SEVEN :
                               begin
                                if( DMACBREQ_in[7] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[7] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
                             `P_EIGHT :
                               begin
                                if( DMACBREQ_in[8] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[8] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
			     `P_NINE :
                               begin
                                if( DMACBREQ_in[9] )  // Burst Request
                                 begin
                                   out_DestinationSize    <=   DMACC5Control_r[11:9]  ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                   out_DestinationBurst   <=   DMACC5Control_r[5:3]   ;
                                   out_SourceBurst        <=   DMACC5Control_r[2:0]   ;
                                 end
                                if( DMACSREQ_in[9] ) // Single Request
				                       // config information changed by P 
                                 begin
                                   out_DestinationBurst   <=   `DMAC_SINGLE           ;
                                   out_SourceBurst        <=   `DMAC_SINGLE           ;
                                   out_DestinationSize    <=   DMACC5Control_r[8:6]   ;
                                   out_SourceSize         <=   DMACC5Control_r[8:6]   ;
                                 end
                               end
                             endcase
                             end
		        // M 2 M, transfer information load as configed information by software
                      3'b000,3'b001:
                             begin
                               out_DestinationSize      <= DMACC5Control_r[11:9]  ;
                               out_SourceSize           <= DMACC5Control_r[8:6]   ;
                               out_DestinationBurst     <= DMACC5Control_r[5:3]   ;
                               out_SourceBurst          <= DMACC5Control_r[2:0]   ;
                             end
                    endcase
                  end
          default:begin
                    out_SourceAddr           <= 32'b0        ;
                    out_DestAddr             <= 32'b0        ;
                    out_DestinationInc       <= 1'b1         ;
                    out_SourceInc            <= 1'b1         ;
                    out_Control_DorP         <= 1'b0         ;
                    out_FlowControl          <= 2'b00        ;
                    out_TransferSize         <= 12'b0        ;
                    out_DestinationInc       <= 1'b0         ;
                    out_SourceInc            <= 1'b0         ;
                    out_DestinationSize      <= 3'b0         ;
		            out_ext_req         <= 2'b0         ;
                    out_SourceSize           <= 3'b0         ;
                    out_DestinationBurst     <= 3'b0         ;
                    out_SourceBurst          <= 3'b0         ;
                    out_Control_DorP         <= 1'b0         ;
                    out_FlowControl          <= 2'b0         ;
                    out_Descriptor_Index     <= 32'b0        ;
                  end
        endcase
    end
//===========================================================================================


//======================= Generate the INT status of each channel =======================
// each channel INT include :transfer completed or transfer error  
  assign DMACIntStatus_r = {DMACIntTCStatus_r[5] | DMACIntErrorStatus_r[5],
                            DMACIntTCStatus_r[4] | DMACIntErrorStatus_r[4],
                            DMACIntTCStatus_r[3] | DMACIntErrorStatus_r[3],
                            DMACIntTCStatus_r[2] | DMACIntErrorStatus_r[2],
                            DMACIntTCStatus_r[1] | DMACIntErrorStatus_r[1],
                            DMACIntTCStatus_r[0] | DMACIntErrorStatus_r[0]
                           };
//=======================================================================================



//================== Generate Transfer Error and Completed INT ==========================
  always @ (posedge HCLK or negedge HRESETn )
    begin
      if(!HRESETn)   // clear registers when reset is low  
        begin
          DMACIntTCStatus_r <= 6'b0;     //   Transfer Completed INT REG
          DMACIntErrorStatus_r <= 6'b0;  //  Transfer Error INT REG
        end
      else
        begin
	  //Channel 0
	  // when No clearing and No masking 
          if((~DMACIntTCClear_r[0])&&(~DMACC0Configuration_r[4]))
            begin // when current channel is selected and transfer completed 
              if(in_TransferCompleted && (in_DMACActivedChannel==3'b000))
                DMACIntTCStatus_r[0] <= 1'b1 ;
            end
          else
            DMACIntTCStatus_r[0] <= 1'b0 ;
	    // when No clearing and No masking 
          if((~DMACIntErrClr_r[0]) && (~DMACC0Configuration_r[3]))
            begin// when current channel is selected and transfer error 
              if(in_AHBResponseError && (in_DMACActivedChannel==3'b000))
                DMACIntErrorStatus_r[0] <= 1'b1 ;
            end
          else
            DMACIntErrorStatus_r[0] <= 1'b0 ; 
	   
		// Channel 1
	   // when No clearing and No masking  
          if((~DMACIntTCClear_r[1])&&(~DMACC1Configuration_r[4]))
            begin // when current channel is selected and transfer completed 
              if(in_TransferCompleted && (in_DMACActivedChannel==3'b001))
                DMACIntTCStatus_r[1] <= 1'b1 ;
            end
          else
            DMACIntTCStatus_r[1] <= 1'b0 ;
	    // when No clearing and No masking 
          if((~DMACIntErrClr_r[1]) && (~DMACC1Configuration_r[3]))
            begin// when current channel is selected and transfer error
              if(in_AHBResponseError && (in_DMACActivedChannel==3'b001))
                DMACIntErrorStatus_r[1] <= 1'b1 ;
            end
          else
            DMACIntErrorStatus_r[1] <= 1'b0 ;
	    
		 //Channel 2
	    // when No clearing and No masking 
          if((~DMACIntTCClear_r[2])&&(~DMACC2Configuration_r[4]))
            begin// when current channel is selected and transfer completed 
              if(in_TransferCompleted && (in_DMACActivedChannel==3'b010))
                DMACIntTCStatus_r[2] <= 1'b1 ;
            end
          else
            DMACIntTCStatus_r[2] <= 1'b0 ;
	    // when No clearing and No masking 
          if((~DMACIntErrClr_r[2]) && (~DMACC2Configuration_r[3]))
            begin// when current channel is selected and transfer error
              if(in_AHBResponseError && (in_DMACActivedChannel==3'b010))
                DMACIntErrorStatus_r[2] <= 1'b1 ;
            end
          else
            DMACIntErrorStatus_r[2] <= 1'b0 ; 
	    
		 //Channel 3
	    // when No clearing and No masking 
          if((~DMACIntTCClear_r[3])&&(~DMACC3Configuration_r[4]))
            begin// when current channel is selected and transfer completed 
              if(in_TransferCompleted && (in_DMACActivedChannel==3'b011))
                DMACIntTCStatus_r[3] <= 1'b1 ;
            end
          else
            DMACIntTCStatus_r[3] <= 1'b0 ;
	    // when No clearing and No masking 
          if((~DMACIntErrClr_r[3]) && (~DMACC3Configuration_r[3]))
            begin// when current channel is selected and transfer error
              if(in_AHBResponseError && (in_DMACActivedChannel==3'b011))
                DMACIntErrorStatus_r[3] <= 1'b1 ;
            end
          else
            DMACIntErrorStatus_r[3] <= 1'b0 ;
	    
		 //Channel 4
	    // when No clearing and No masking 
          if((~DMACIntTCClear_r[4])&&(~DMACC4Configuration_r[4]))
            begin// when current channel is selected and transfer completed 
              if(in_TransferCompleted && (in_DMACActivedChannel==3'b100))
                DMACIntTCStatus_r[4] <= 1'b1 ;
            end
          else
            DMACIntTCStatus_r[4] <= 1'b0 ;
	    // when No clearing and No masking 
          if((~DMACIntErrClr_r[4]) && (~DMACC4Configuration_r[3]))
            begin// when current channel is selected and transfer error
              if(in_AHBResponseError && (in_DMACActivedChannel==3'b100))
                DMACIntErrorStatus_r[4] <= 1'b1 ;
            end
          else
            DMACIntErrorStatus_r[4] <= 1'b0 ;
	    
		 //Channel 5
	    // when No clearing and No masking 
          if((~DMACIntTCClear_r[5])&&(~DMACC5Configuration_r[4]))
            begin// when current channel is selected and transfer completed 
              if(in_TransferCompleted && (in_DMACActivedChannel==3'b101))
                DMACIntTCStatus_r[5] <= 1'b1 ;
            end
          else
            DMACIntTCStatus_r[5] <= 1'b0 ;
	    // when No clearing and No masking 
          if((~DMACIntErrClr_r[5]) && (~DMACC5Configuration_r[3]))
            begin// when current channel is selected and transfer error
              if(in_AHBResponseError && (in_DMACActivedChannel==3'b101))
                DMACIntErrorStatus_r[5] <= 1'b1 ;
            end
          else
            DMACIntErrorStatus_r[5] <= 1'b0 ;
        end      
    end 
 //=======================================================================================
 
 
endmodule 
