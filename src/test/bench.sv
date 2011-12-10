

program bench
(
	input clk,
	output logic rst,
	blockStoreIfc.writer blkWrt,
	input resultValid,
	input success,
	nonceBufferIfc.reader nonBufRd
);

	environ env;

	initial begin
		
		env = new();
		env.initialize();
		
		rst <= 1;
		@(posedge clk)
		rst <= 0;

		blkWrt.writeValid <= 1;

		blkWrt.blockData <= 1;
		@(posedge clk)

		$display("ResultValid: %b; Success: %b", resultValid, success);

		blkWrt.blockData <= 3;
		@(posedge clk)
		$display("ResultValid: %b; Success: %b", resultValid, success);

		blkWrt.blockData <= 7;
		@(posedge clk)
		$display("ResultValid: %b; Success: %b", resultValid, success);
	end
		


endprogram
