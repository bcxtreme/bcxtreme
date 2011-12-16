
class environ;

	bit verbose;
	int max_cycles;
	real density_rst;
	real density_valid;

	task error(string m);
		$display({"* Error: ", m});
		$exit;
	endtask

	function string read_string(int fd);
		string ret;
		if (!($fscanf(fd, "%s", ret))) error("Could not read string");
		return ret;
	endfunction

	function int read_int(int fd);
		int ret;
		if (!($fscanf(fd, "%d", ret))) error("Could not read integer");
		return ret;
	endfunction

	function real read_real(int fd);
		real ret;
		if (!($fscanf(fd, "%f", ret))) error("Could not read float");
		return ret;
	endfunction

	task initialize;
		int fd;

		$display("* * * * * * * * * * * * * * * * * * * * * * *");
		$display("* Reading config.ini...");
		fd = $fopen("config_shacore.ini", "r");
		if (fd == 0) error("Could not open or find config.ini");

		while (!$feof(fd)) begin
			string param, dummy_string;

			param = read_string(fd);
			case (param)
				"max_cycles": max_cycles = read_int(fd);
				"density_rst": density_rst = read_real(fd);
				"density_valid": density_valid = read_real(fd);
				"verbose": verbose = read_int(fd);
				"/*": /* skip comments */ while ("*/" != read_string(fd));
				"#": /* skip lines with comments */ while ($fgetc(fd) != "\n");
				"": /* skip blanks */;
				default: error({"Unknown config parameter: '", param, "'"});
			endcase
		end

		$fclose(fd);

		$display("* max_cycles = %d", max_cycles);
		$display("* density_rst = %f", density_rst);
		$display("* density_valid = %f", density_writeValid);
		$display("* verbose = %b", verbose);
		$display("* * * * * * * * * * * * * * * * * * * * * * *");
	endtask

endclass
			
		
