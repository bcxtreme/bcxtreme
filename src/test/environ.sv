
class environ;

	integer max_cycles;
	real density_reset;

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
		fd = $fopen("config.ini", "r");
		if (fd == 0) error("Could not open or find config.ini");

		while (!$feof(fd)) begin
			string param;

			param = read_string(fd);
			case (param)
				"max_cycles": begin
					max_cycles = read_int(fd);
					$display("* max_cycles = %d", max_cycles);
				end
				"density_reset": begin
					density_reset = read_real(fd);
					$display("* density_reset = %f", density_reset);
				end
				"": /* Skip blanks */;
				default: error({"Unknown config parameter: '", param, "'"});
			endcase
		end

		$fclose(fd);
		$display("* * * * * * * * * * * * * * * * * * * * * * *");
	endtask

endclass
			
		
