module dma(
//input
//system hclk
input   wire    		  hclk,
//system resetn
input   wire    		  hresetn,

//ahb to master
input   wire    		  hgrant_m,
input   wire           hready_m,
input   wire           hresp_m,
input   wire    [1:0]  htrans_s_h,
input	  wire           in_BridgeReq,//req apb bridge


//ahb to slave
input	  wire	 		  hsel_s,
input   wire    [31:0] haddr_s,
input	  wire 	 		  hwrite_s,
input   wire    [1:0]  htrans_s,
input   wire	 [2:0]  hsize_s,
input	  wire    [31:0] hwdata_s, 

//ahb to fifo
input   wire    [31:0] hrdata_m,

//apb to master
input	  wire 	 PSEL,
input	  wire 	 PENABLE,

// DMA REQUEST From Internal Module 
                // From USB Module
input           in_DMACBREQ_USBin                             ,// Burst   in 
input           in_DMACSREQ_USBin                             ,// Single  in 
input           in_DMACBREQ_USBout                            ,// Burst   out 
input           in_DMACSREQ_USBout                            ,// Single  out
                // From NAND Module
input           in_DMACBREQ_NANDin                            ,// Burst   in 
input           in_DMACSREQ_NANDin                            ,// Single  in
input           in_DMACBREQ_NANDout                           ,// Burst   out 
input           in_DMACSREQ_NANDout                           ,// Single  out
                // From UART1 Module
input           in_DMACBREQ_UART1in                           ,// Burst   in 
input           in_DMACSREQ_UART1in                           ,// Single  in
input           in_DMACBREQ_UART1out                          ,// Burst   out
input           in_DMACSREQ_UART1out                          ,// Single  out
                 // From UART2 Module
input           in_DMACBREQ_UART2in                           ,// Burst   in
input           in_DMACSREQ_UART2in                           ,// Single  in
input           in_DMACBREQ_UART2out                          ,// Burst   out
input           in_DMACSREQ_UART2out                          ,// Single  out
                 // From AC97 Module
input           in_DMACBREQ_AC97in                            ,// Burst   in
input           in_DMACSREQ_AC97in                            ,// Single  in
input           in_DMACBREQ_AC97out                           ,// Burst   out
input           in_DMACSREQ_AC97out                           ,// Single  out
                // From SPI Module
input           in_DMACBREQ_SPIin                             ,// Burst   in
input           in_DMACSREQ_SPIin                             ,// Single  in
input           in_DMACBREQ_SPIout                            ,// Burst   out
input           in_DMACSREQ_SPIout                            ,// Single  out
                // From MMC Module
input           in_DMACBREQ_MMCin                             ,// Burst   in
input           in_DMACSREQ_MMCin                             ,// Single  in
input           in_DMACBREQ_MMCout                            ,// Burst   out
input           in_DMACSREQ_MMCout                            ,// Single  out

//output
//from master to ahb
output   wire	  		 hbusreq_m,
output	wire			 hlock_m,
output	wire	  [1:0] htrans_m,
output	wire    [31:0] haddr_m,
output	wire    		  hwrite_m,
output   wire    [2:0] hsize_m,
output   wire    [2:0] hburst_m,
output	wire			  DMAC_EXTERNAL_ACK_1,
output	wire			  DMAC_EXTERNAL_ACK_2,
//	  hport


//from slave to ahb
output  wire 	 		  hready_s,
output  wire     		  hresp_s,
output  wire	 [31:0] hrdata_s,

//from mux6_1 to ahb
output  wire    [31:0] hwdata_m,


//from master to apb
output	wire	 PSELen,
output	wire	 PENABLEen,
output	wire 	 PWRITEen,
output	wire 	 out_DmacAck,
output	wire 	 out_Bridgeing,
output	wire 	 out_DmacState, 

// to INTC module indicate transfering completed  
output          out_TransferCompletedInt ,
  // to INTC module indicate transfer error 
output          out_DmacIntErrorInt                           
);

wire [31:0] SourceAddr;
wire [31:0] DestAddr;
wire [11:0] TransferSize;
wire  DestinationInc;
wire  [2:0] DestinationSize;
wire SourceInc;
wire [2:0] SourceSize;
wire [2:0] DestinationBurst;
wire [2:0] SourceBurst;
wire Control_DroP;
wire [1:0] FlowControl;
wire EnableDmac;
wire NandTransComplete;
wire bootnand;
wire FIFOReset;
wire AHBResponseError;
wire [31:0] CurrentSourceAddressLog;
wire [31:0] CurrentDestinationAddressLog;
wire [11:0] CurrentChannelTransferSizeLog;
wire WriteSourceAddressRegisterAgain;
wire WriteDestinationAddressRegisterAgain;
wire WriteTransferSizeAgain;
wire RequestNextChannel;
wire WriteDataEnable;
wire ReadDataEnable;
wire TransStart;
wire TransferCompleted;
wire [31:0] Descriptor_Index;
wire read_en;
wire [2:0] descriptor_counter;
wire [1:0]external_req;
wire [2:0]DMACActivedChannel;
wire NextChannelReady;

wire [5:0] ShortTimeEnableChannel;

wire FIFOReset_0;
wire FIFOReset_1;
wire FIFOReset_2;
wire FIFOReset_3;
wire FIFOReset_4;
wire FIFOReset_5;

wire ReadDataEnable_0;
wire ReadDataEnable_1;
wire ReadDataEnable_2;
wire ReadDataEnable_3;
wire ReadDataEnable_4;
wire ReadDataEnable_5;

wire WriteDataEnable_0;
wire WriteDataEnable_1;
wire WriteDataEnable_2;
wire WriteDataEnable_3;
wire WriteDataEnable_4;
wire WriteDataEnable_5;

wire [31:0] hwdata_m_0;
wire [31:0] hwdata_m_1;
wire [31:0] hwdata_m_2;
wire [31:0] hwdata_m_3;
wire [31:0] hwdata_m_4;
wire [31:0] hwdata_m_5;


dmac_ahbmaster u_dmac_ahbmaster(
// system HCLK
							 .HCLK                                     (hclk),
		      // system reset
                      .HRESETn                                  (hresetn),
		      // AMBA AHB Interface
                      .in_HGRANT_m                              (hgrant_m),
                      .in_HREADY_m                              (hready_m),
                      .in_HRESP_m                               (hresp_m),
                      .in_HTRANS_s_h                            (htrans_s_h),
                      .out_HBUSREQ_m                            (hbusreq_m),
                      .out_HLOCK_m                              (hlock_m),
                      .out_HTRANS_m                             (htrans_m),
                      .out_HADDR_m                              (haddr_m),
                      .out_HWRITE_m                             (hwrite_m),
                      .out_HSIZE_m                              (hsize_m),
                      .out_HBURST_m                             (hburst_m),
		      // AMBA APB Interface
                      .out_PSELen                               (PSELen),
                      .out_PENABLEen                            (PENABLEen),
                      .out_PWRITEen                             (PWRITEen),
                      .in_PSEL                                  (PSEL),
                      .in_PENABLE                               (PENABLE),
		      // next channel ready from arbit
                      .in_NextChannelReady                      (NextChannelReady),
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
                      .in_SourceAddr                            (SourceAddr), // 1.
                      .in_DestAddr                              (DestAddr), // 2.
                      .in_TransferSize                          (TransferSize), // 3.
                      .in_DestinationInc                        (DestinationInc), // 4.
                      .in_SourceInc                             (SourceInc), // 5.
                      .in_DestinationSize                       (DestinationSize), // 6.
                      .in_SourceSize                            (SourceSize), // 7.
                      .in_DestinationBurst                      (DestinationBurst), // 8.
                      .in_SourceBurst                           (SourceBurst), // 9.
                      .in_Control_DorP                          (Control_DorP), // 10.
					  		 .in_FlowControl                           (FlowControl), // 11.
		   // FSM enabled when req 
                      .in_EnableDmac               				 (EnableDmac),
		   // req APB bus from AMBA
                      .in_BridgeReq                   (in_BridgeReq)          ,
		   // for nand boot 
                      .in_NandTransComplete 							 (NandTransComplete),
		   // for nand boot (del now)
                      .in_bootnand              	  (bootnand),
		   // response for APB bridge req
                      .out_DmacAck                     (out_DmacAck)         ,
		   // signal to AMBA for APB bridge
                      .out_Bridgeing                   (out_Bridgeing)         ,
		   // after a transfer
                      .out_FIFOReset                    			 (FIFOReset),
		   // for INTC to slave
                      .out_AHBResponseError                     (AHBResponseError),
		   // register the transfer information after a B TRANs , to dmac_slave
		      // 1. source addr
		      // 2. dest addr
		      // 3. num of data need to trans
                      .out_CurrentSourceAddrressLog             (CurrentSourceAddrressLog), // 1.
                      .out_CurrentDestinationAddrressLog        (CurrentDestinationAddrressLog), // 2.
                      .out_CurrentChannelTransferSizeLog        (CurrentChannelTransferSizeLog), // 3.
		   // after a B trans cntrl signal 
		      // 1, for src addr
                      .out_WriteSourceAddressRegisterAgain      (WriteSourceAddressRegisterAgain),
		      // 2. for dest sddr
                      .out_WriteDestinationAddressRegisterAgain (WriteDestinationAddressRegisterAgain),
		      // 3. for num of data
                      .out_WriteTransferSizeAgain               (WriteTransferSizeAgain),
		      // 4. to start a trans again
                      .out_RequestNextChannel                   (RequestNextChannel),
		   // ctrl signal for fifo data 
		      // 1. for read
                      .out_WriteDataEnable                      (WriteDataEnable),
		      // 2. for write
                      .out_ReadDataEnable                       (ReadDataEnable),
		   // to slave trans again
                      .out_TransStart                           (TransStart),
		   // to slave INTC 
                      .out_TransferCompleted                    (TransferCompleted),
		   // to APB If for timing
                      .out_DmacState                            (out_DmacState ),
		   // to fifo sel data from
                      .out_SourceBus                            (out_SourceBus),
		   // LLI index
                      .in_Descriptor_Index							 (Descriptor_Index),
		   //  for LLI load
                      .out_read_en           						 (read_en),
		   // for LLI load
                      .out_descriptor_counter  						 (descriptor_counter),
		   // for external req
                      .in_external_req           					 (external_req),
		   // response for external req
		      // 1.
                      .out_DMAC_EXTERNAL_ACK_1                  (DMAC_EXTERNAL_ACK_1),
		      // 2.
                      .out_DMAC_EXTERNAL_ACK_2						 (DMAC_EXTERNAL_ACK_2)
                      );

assign out_SourceBus=1'b1;	
assign bootnand=1'b1;						 
							 
dmac_ahbslave u_dmac_ahbslave(
// system HCLK
                     .HCLK                                     (hclk), 
		  // system reset
                     .HRESETn                                  (hresetn), 
		  // can delete
                     .in_bootnand                              (bootnand), 
		  // AMBA SLAVE INTERFACE
                     .in_HSEL_s                                (hsel_s),
                     .in_HADDR_s                               (haddr_s),
                     .in_HWRITE_s                              (hwrite_s),
                     .in_HTRANS_s                              (htrans_s),
                     .in_HSIZE_s                               (hsize_s),
                     .in_HWDATA_s                              (hwdata_s), 
                     .out_HREADY_s                             (hready_s),
                     .out_HRESP_s                              (hresp_s),
                     .out_HRDATA_s                             (hrdata_s),
        // from arbit indicate which channel is in transfering
                     .in_DMACActivedChannel                    (DMACActivedChannel),
		  // from FSM indicate next transfer can start
                     .in_TransStart                            (TransStart),
		  // register the current channle's transfer information, from dmac_master
	             // include: 1.source address 
	             //          2.destination address 
	             //          3.number of data need to transfer 
                     .in_CurrentSourceAddrressLog              (CurrentSourceAddrressLog), // 1.
                     .in_CurrentDestinationAddrressLog         (CurrentDestinationAddrressLog), // 2.
                     .in_CurrentChannelTransferSizeLog         (CurrentChannelTransferSizeLog), // 3.
		  // signal indicate to reload the informations from FSM
	              // reload source addres
                     .in_WriteSourceAddressRegisterAgain       (WriteSourceAddressRegisterAgain),
		      // reload destination address
                     .in_WriteDestinationAddressRegisterAgain  (WriteDestinationAddressRegisterAgain),
		      // reload number of data need to transfer 
                     .in_WriteTransferSizeAgain                (WriteTransferSizeAgain),
		     // signal indicate current transfer completed 
                     .in_TransferCompleted                     (TransferCompleted),
		     // indicate transfer error
                     .in_AHBResponseError                      (AHBResponseError),
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
                     .out_SourceAddr                           (SourceAddr), // 1
                     .out_DestAddr                             (DestAddr), // 2
                     .out_TransferSize                         (TransferSize), // 3
                     .out_DestinationInc                       (DestinationInc), // 4
                     .out_SourceInc                            (SourceInc), // 5
                     .out_DestinationSize                      (DestinationSize), // 6
                     .out_SourceSize                           (SourceSize), // 7
                     .out_DestinationBurst                     (DestinationBurst), // 8
                     .out_SourceBurst                          (SourceBurst), // 9
                     .out_Control_DorP                         (Control_DorP), // 10
                     .out_FlowControl                          (FlowControl), // 11
		  // signal to FSM module to start the transfering
		  // signal to FIFO module to clear the fifo for new transfering
                     .out_EnableDmac              					(EnableDmac),
		  // signal indicate which channel has request to arbit module
                     .out_ShortTimeEnableChannel               (ShortTimeEnableChannel),
		  // signal to FSM for nandboot control when booting
                     .out_NandTransComplete   						(NandTransComplete),
		  // to INTC module indicate transfering completed 
                     .out_TransferCompletedInt   					(out_TransferCompletedInt),
		  // to INTC module indicate transfer error 
                     .out_DmacIntErrorInt       					(out_DmacIntErrorInt ),
		  // counter for reading descriptor  
                     .in_descriptor_counter							(descriptor_counter),
		  // read descriptor enable
                     .in_read_en  						  	  			(read_en),
		  // data when DMAC as ahb Master read from memory
                     .in_HRDATA_m							   		(hrdata_m),
		  // descriptor Index to FSM module to judge whether to read descriptor
                     .out_Descriptor_Index     						(Descriptor_Index), 
		  // to FSM indicate the current transfer for external request
							.out_external_req				   				(external_req),
		  // DMA REQUEST From Internal Module 
		     // From USB Module
                     .in_DMACBREQ_USBin     (in_DMACBREQ_USBin), // Burst  in 
                     .in_DMACSREQ_USBin     (in_DMACSREQ_USBin), // Single in
                     .in_DMACBREQ_USBout    (in_DMACBREQ_USBout), // Burst  out
                     .in_DMACSREQ_USBout    (in_DMACSREQ_USBout), // Single out
		     // From NAND Module
                     .in_DMACBREQ_NANDin    (in_DMACBREQ_NANDin), // Burst  in 
                     .in_DMACSREQ_NANDin    (in_DMACSREQ_NANDin), // Single in
                     .in_DMACBREQ_NANDout   (in_DMACBREQ_NANDout), // Burst  out
                     .in_DMACSREQ_NANDout   (in_DMACSREQ_NANDout), // Single out
		      // From Uart1 Module
                     .in_DMACBREQ_UART1in   (in_DMACBREQ_UART1in ), // Burst  in 
                     .in_DMACSREQ_UART1in   (in_DMACSREQ_UART1in), // Single in
                     .in_DMACBREQ_UART1out  (in_DMACBREQ_UART1out), // Burst  out
                     .in_DMACSREQ_UART1out  (in_DMACSREQ_UART1out), // Single out
		     // From Uart2 Module
                     .in_DMACBREQ_UART2in   (in_DMACBREQ_UART2in), // Burst  in 
                     .in_DMACSREQ_UART2in   (in_DMACSREQ_UART2in), // Single in
                     .in_DMACBREQ_UART2out  (in_DMACBREQ_UART2out), // Burst  out
                     .in_DMACSREQ_UART2out  (in_DMACSREQ_UART2out), // Single out
		     // From AC97 Mudule
                     .in_DMACBREQ_AC97in    (in_DMACBREQ_AC97in), // Burst  in 
                     .in_DMACSREQ_AC97in    (in_DMACSREQ_AC97in ), // Single in
                     .in_DMACBREQ_AC97out   (in_DMACBREQ_AC97out), // Burst  out
                     .in_DMACSREQ_AC97out   (in_DMACSREQ_AC97out), // Single out
		     // From SPI Module
                     .in_DMACBREQ_SPIin     (in_DMACBREQ_SPIin), // Burst  in 
                     .in_DMACSREQ_SPIin     (in_DMACSREQ_SPIin), // Single in
                     .in_DMACBREQ_SPIout    (in_DMACBREQ_SPIout), // Burst  out
                     .in_DMACSREQ_SPIout    (in_DMACSREQ_SPIout ), // Single out
		      // From MMC Module
                     .in_DMACBREQ_MMCin     (in_DMACBREQ_MMCin), // Burst  in 
                     .in_DMACSREQ_MMCin     (in_DMACSREQ_MMCin ), // Single in
                     .in_DMACBREQ_MMCout    (in_DMACBREQ_MMCout), // Burst  out
                     .in_DMACSREQ_MMCout    (in_DMACSREQ_MMCout), // Single out
		  // External Request from PCB board 
		     .in_DMACBREQ_EXTERNAL_1   (in_DMACBREQ_EXTERNAL_1), 
		     .in_DMACBREQ_EXTERNAL_2	(in_DMACBREQ_EXTERNAL_2)
                     );

							
sync_fifo	u_sync_fifo_0(
								.HCLK						(hclk),
								.FIFOReset				(FIFOReset_0),
								.in_HRDATA_m			(hrdata_m),
								.ReadDataEnable		(ReadDataEnable_0),
								.WriteDataEnable		(WriteDataEnable_0),
 
								.empty					(),
								.full						(),
								.out_HWDATA_m			(hwdata_m_0)
 );
 
sync_fifo	u_sync_fifo_1(
								.HCLK						(hclk),
								.FIFOReset				(FIFOReset_1),
								.in_HRDATA_m			(hrdata_m),
								.ReadDataEnable		(ReadDataEnable_1),
								.WriteDataEnable		(WriteDataEnable_1),
 
								.empty					(),
								.full						(),
								.out_HWDATA_m			(hwdata_m_1)
 );
 
sync_fifo	u_sync_fifo_2(
								.HCLK						(hclk),
								.FIFOReset				(FIFOReset_2),
								.in_HRDATA_m			(hrdata_m),
								.ReadDataEnable		(ReadDataEnable_2),
								.WriteDataEnable		(WriteDataEnable_2),
 
								.empty					(),
								.full						(),
								.out_HWDATA_m			(hwdata_m_2)
 );
 
sync_fifo	u_sync_fifo_3(
								.HCLK						(hclk),
								.FIFOReset				(FIFOReset_3),
								.in_HRDATA_m			(hrdata_m),
								.ReadDataEnable		(ReadDataEnable_3),
								.WriteDataEnable		(WriteDataEnable_3),
 
								.empty					(),
								.full						(),
								.out_HWDATA_m			(hwdata_m_3)
 );

sync_fifo	u_sync_fifo_4(
								.HCLK						(hclk),
								.FIFOReset				(FIFOReset_4),
								.in_HRDATA_m			(hrdata_m),
								.ReadDataEnable		(ReadDataEnable_4),
								.WriteDataEnable		(WriteDataEnable_4),
 
								.empty					(),
								.full						(),
								.out_HWDATA_m			(hwdata_m_4)
 );
 
sync_fifo	u_sync_fifo_5(
								.HCLK						(hclk),
								.FIFOReset				(FIFOReset_5),
								.in_HRDATA_m			(hrdata_m),
								.ReadDataEnable		(ReadDataEnable_5),
								.WriteDataEnable		(WriteDataEnable_5),
 
								.empty					(),
								.full						(),
								.out_HWDATA_m			(hwdata_m_5)
 );

decoder	u_decoder(
						.FIFOReset						(FIFOReset),
						.ReadDataEnable				(ReadDataEnable),
						.WriteDataEnable				(WriteDataEnable),
						.DMACActivedChannel			(DMACActivedChannel), 


						.ReadDataEnable_0				(ReadDataEnable_0),
						.ReadDataEnable_1				(ReadDataEnable_1),
						.ReadDataEnable_2				(ReadDataEnable_2),
						.ReadDataEnable_3				(ReadDataEnable_3),
						.ReadDataEnable_4				(ReadDataEnable_4),
						.ReadDataEnable_5				(ReadDataEnable_5),
						.FIFOReset_0					(FIFOReset_0),
						.FIFOReset_1					(FIFOReset_1),
						.FIFOReset_2					(FIFOReset_2),
						.FIFOReset_3					(FIFOReset_3),
						.FIFOReset_4					(FIFOReset_4),
						.FIFOReset_5					(FIFOReset_5),

						.WriteDataEnable_0			(WriteDataEnable_0),
						.WriteDataEnable_1			(WriteDataEnable_1),
						.WriteDataEnable_2			(WriteDataEnable_2),
						.WriteDataEnable_3			(WriteDataEnable_3),
						.WriteDataEnable_4			(WriteDataEnable_4),
						.WriteDataEnable_5			(WriteDataEnable_5)
						);
						
mux6_1	u_mux6_1(
						.hwdata_m_0						(hwdata_m_0),
						.hwdata_m_1						(hwdata_m_1),
						.hwdata_m_2						(hwdata_m_2),
						.hwdata_m_3						(hwdata_m_3),
						.hwdata_m_4						(hwdata_m_4),
						.hwdata_m_5						(hwdata_m_5),
						.DMACActivedChannel			(DMACActivedChannel),

						.hwdata_m						(hwdata_m)
						);
 
arbit		u_arbit(
	.clk 							(hclk),
	.rst_n						(hresetn),
	.ShortTimeEnableChannel	(ShortTimeEnableChannel),//全0默认使能0通道，剩下的优先级0最高，5最低
	.DMACActivedChannel		(DMACActivedChannel),
	.NextChannelReady			(NextChannelReady)
	);
 
endmodule
