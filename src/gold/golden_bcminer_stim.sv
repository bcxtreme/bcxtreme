
module golden_bcminer_stim();

	golden_bcminer gb;

	initial begin
		bit cum_xor;

		gb = new();

		$display("Resetting BCMINER...");
		gb.rst_i = 1;
		gb.cycle();
		gb.rst_i = 0;
		gb.cycle();

		$display("Check that writeReady has gone high");
		if (gb.writeReady_o != 1) begin
			$display("ERROR: Expected writeReady to go high immediately after reset");
		end

		$display("Write 44 chunks: write the numbers 101-144...");
		cum_xor = 0;
		for (int i = 0; i < 44; i++) begin
			gb.writeValid_i = 1;
			gb.blockData_i = (101 + i);
			cum_xor = (^ (101 + i)) ^ cum_xor;
			gb.cycle();
		end

		$display("XOR of 101-144 is %b", cum_xor);

		$display("Check that resultValid is high...");
		if (gb.resultValid_o != 1) begin
			$display("ERROR: Expected resultValid to go high after 44th chunk was written");
		end

		$display("Check that success is the XOR of 101-144's bits...");
		if (gb.success_o != cum_xor) begin
			$display("ERROR: gb.success was %b", gb.success_o);
		end

		$display("Now, run while constantly writing. Check that we alternate on 44/16");
		for (int i = 1; i < 300; i++) begin
			gb.writeValid_i = 1;
			gb.blockData_i = 7;
			gb.cycle();
			$display("%d: resultValid: %b; success: %b", i, gb.resultValid_o, gb.success_o);
		end
		
	end
endmodule
