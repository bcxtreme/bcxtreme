class Model;

	bit reset;
  bit read;
  bit [4:0] read_index;
  bit write;
  bit [4:0] write_index;
  bit [31:0] write_data;
	bit [31:0] read_valid;
	int i;

  // associative array for storage
  bit[31:0] assoc[bit[4:0]];


  function new();
  endfunction : new

	function void rst();
		if (reset)
			for (i=0; i<32; i++) begin
				assoc[i] = 0;
				read_valid[i] = 0;
			end;
	endfunction;

  function bit readValid();
    return (read_valid[read_index] && (!reset) && read) ;
  endfunction : readValid


  function bit[31:0] readValue();
    if ( read )
      return assoc[read_index];
    else
      return 0;
  endfunction : readValue


  function void execute();
    if ( write && (!reset) ) begin
      assoc[write_index] = write_data;
			read_valid[write_index] = 1;
		end;
  endfunction : execute


endclass : Model
 
