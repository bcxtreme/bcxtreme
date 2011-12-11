class blockstorage_test;
	bit rst;

	bit writeValid;
	bit [7:0] blockData;

	bit writeReady;		
	
	bit [7:0] storedBlocks [351:0];//should be 352 bits
	bit [31:0] index = 0;

	bit newblock;
	bit validOut;
	bit [351:0] initialState;
	
	
	function reset;
		writeReady = 1;
		for(int i=0; i< 2^352; i++) begin
			stored_blocks[i] = 0; //set all stored block data to 0;
		end
	endfunction
	

	function acceptblock;
		writeReady = 0;
		if(writeValid) begin
			storedblocks[index] = blockdata;
			index = index + 1;
		end
		newblock = 1;
	endfunction

	
	function blockstorage_golden;
		if(rst) begin
			reset();
		end

		else begin
			if (writeReady) begin
				acceptblock();
			end
		end

		writeReady = 1;
	endfunction
endclass
