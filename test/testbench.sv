int CONSTANT_DENSITY_SCALE = 1000;

class transaction;
		
endclass


class rst_test;
	bit rst;
	
	int stored [31:0];
	bit lookup [31:0];
	
	function void golden_result;
		if(rst) begin
			for(int i = 0; i < 32; i++) begin
				stored[i] = 0;
				lookup[i] = 0;
			end
		end	
	endfunction
endclass


class sha_test;
		
endclass

class all_test;
		

endclass


class checker;
	function bit check_result ( int dut_search_valid, int bench_search_valid,
					int dut_search_index, int bench_search_index,
					int dut_read_valid, int bench_read_valid,
					int dut_read_value, int bench_read_value,
					bit verbose); 
        bit passed = 	(dut_search_valid == bench_search_valid) &&
			(dut_search_index == bench_search_index) &&
			(dut_read_valid == bench_read_valid) &&
			(dut_read_value == bench_read_value); 
        if(verbose) begin
			$display("dut_search_valid: %d\n", dut_search_valid);
			$display("dut_search_index: %d\n", dut_search_index);
			$display("dut_read_valid: %d\n", dut_read_valid);
			$display("dut_read_value: %d\n", dut_read_value);
		end
        if(passed) begin
            if(verbose) $display("%t : pass \n", $realtime);
        end
        else begin
            $display("%t : fail \n", $realtime);
            $display("dut_search_valid: %d\n", dut_search_valid);
			$display("bench_search_valid: %d\n", bench_search_valid);
			$display("dut_search_index: %d\n", dut_search_index);
			$display("bench_search_index: %d\n", bench_search_index);
			$display("dut_read_valid: %d\n", dut_read_valid);
			$display("bench_read_valid: %d\n", bench_read_valid);
			$display("dut_read_value: %d\n", dut_read_value);
			$display("bench_read_value: %d\n", bench_read_value);
			           
         //   $exit();
        end
        return passed;
    endfunction   
endclass

class env;
	int cycle = 0;
	bit verbose = 1;	
	int warmup_time = 2;	
	int max_transactions = 10000;
	real density_read = 0;
	real density_write = 0;
	real density_search = 0;
	real density_reset = 0;
	
	bit [4:0] index_mask_read = 0;
	bit [4:0] index_mask_write = 0;
	bit [31:0] data_mask_write = 0;
	bit [31:0] data_mask_search = 0;
	
	
	function configure(string filename);
	real value;
	int file, seed, chars_returned;
        string param;
        file = $fopen(filename, "r");
        while(!$feof(file)) begin
            chars_returned = $fscanf(file, "%s %f", param, value);
            if("max_cycles" == param) begin
                max_transactions = value;
            end
			else if("density_read" == param) begin
				$display("density_read set: %d", value * CONSTANT_DENSITY_SCALE);				
				density_read = value * CONSTANT_DENSITY_SCALE;
			end
			else if("density_write" == param) begin
				$display("density_write set: %d", value * CONSTANT_DENSITY_SCALE);
				density_write = value * CONSTANT_DENSITY_SCALE;
			end
			else if("density_search" == param) begin
				$display("density_search set: %d", value * CONSTANT_DENSITY_SCALE);
				density_search = value * CONSTANT_DENSITY_SCALE;
			end
			else if("density_reset" == param) begin
				$display("density_reset set: %d", value * CONSTANT_DENSITY_SCALE);
				density_reset = value * CONSTANT_DENSITY_SCALE;
			end
			else if("index_mask_read" == param) begin
				index_mask_read = value;
			end
			else if("index_mask_write" == param) begin
				index_mask_write = value;
			end
			else if("data_mask_write" == param) begin

				data_mask_write = value;
			end
			else if("data_mask_search" == param) begin
				data_mask_search = value;
			end
            else begin
                $display("Never heard of a: %s", param);
                $exit();
            end
        end
    endfunction
endclass

program tb (all_ifc.bench all_ds);
    all_test test;
    transaction packet; 
    checker checker;
    env env;
    int cycle; // For DVE

    task do_cycle;
		//Increament the cycle
		env.cycle++;
		cycle = env.cycle;
		//Create a new transaction
		//packet = new();
		//Configure transaction
		packet.density_read <= env.density_read;
		packet.density_write <= env.density_write;
		packet.density_search <= env.density_search;
		packet.density_reset <= env.density_reset;
		
		packet.index_mask_read <= env.index_mask_read;
		packet.index_mask_write <= env.index_mask_write;
		packet.data_mask_write <= env.data_mask_write;
		packet.data_mask_search <= env.data_mask_search;
		
		//Randomize
		packet.randomize();
		
		//Set the ports for test
		test.rst <= packet.rst;
		test.read <= packet.read;
		test.write <= packet.write;
		test.search <= packet.search;
		test.read_index <= packet.read_index;
		test.write_index <= packet.write_index;
		test.write_data <= packet.write_data;
		test.search_data <= packet.search_data;
				
		//Set the ports for interfaces
		
		/*//interface 1 (rst_rs)
		rst_ds.cb.rst <= packet.rst;
				
		//interface 2 (rw_rs)
		rw_ds.cb.read <= packet.read;
		rw_ds.cb.rst <= packet.rst;
		rw_ds.cb.write <= packet.write;
		rw_ds.cb.read_index <= packet.read_index;
		rw_ds.cb.write_index <= packet.write_index;
		rw_ds.cb.write_data <= packet.write_data;
		
		//interface 3 (s_rs)
		s_ds.cb.search <= packet.search;
		s_ds.cb.rst <= packet.rst;
		s_ds.cb.search_data <= packet.search_data;*/
		
		//interface 4 all
		all_ds.cb.rst <= packet.rst;
		all_ds.cb.read <= packet.read;
		all_ds.cb.write <= packet.write;
		all_ds.cb.search <= packet.search;
		all_ds.cb.read_index <= packet.read_index;
		all_ds.cb.write_index <= packet.write_index;
		all_ds.cb.write_data <= packet.write_data;
		all_ds.cb.search_data <= packet.search_data;
		
		
		
		//Gen the results call golden results
		/*@(rst_ds.cb);
		@(rw_ds.cb);
		@(s_ds.cb);*/
		@(all_ds.cb);
        	test.golden_result();
    endtask

    initial begin
        test = new();
        checker = new();
        packet = new();
        env = new();
        env.configure("params.cfg");

        // warm up
        repeat (env.warmup_time) begin
            do_cycle();
        end

        // testing
        repeat (env.max_transactions) begin
            do_cycle();
            checker.check_result(all_ds.cb.search_valid, test.search_valid, 
					all_ds.cb.search_index, test.search_index,
					all_ds.cb.read_valid, test.read_valid,
					all_ds.cb.read_value, test.read_value,
					env.verbose);
		/*checker.check_result(1,1,
					1,1,
					all_ds.cb.read_valid, test.read_valid,
					all_ds.cb.read_value, test.read_value,
					env.verbose);*/
        end
    end
endprogram 
