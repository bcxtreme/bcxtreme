class blockstorage_test;
	bit rst;
	bit writeValid;

	bit writeReady;
	
	bit newblock;
	
	bit [7:0] blockData;
	bit [7:0] storedBlocks [351:0];//should be 352 bits
	
	bit [31:0] index = 0;
	
	function reset;
		for(int i=0; i<352; i++) begin
			stored_blocks[i] = 0; //set all stored block data to 0;
		end
	endfunction
	

	function acceptblock;
		storedblocks[index] = blockdata;
		newblock = 1;
	endfunction

	
	function blockstorage_golden;
		if(rst) begin
			reset();
		end

		else begin
			if (writeReady) begin
				acceptblocks();
			end
		end

		writeReady = 1;
	endfunction
endclass
