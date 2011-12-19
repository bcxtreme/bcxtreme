
class golden_sha #(parameter DELAY_C = 10, parameter PROCESSORINDEX=0, parameter NUMPROCESSORS=1);

	// Inputs
	bit validIn_i;
	bit newBlockIn_i;
	bit[351:0] initialState_i;

	// Outputs
	bit validOut_o;
	bit newBlockOut_o;
	bit[255:0] hash_o;
	bit[31:0] difficulty_o;

	// Internal State
	local bit[255:0] hash_buf[DELAY_C + 1];
	local bit[31:0] dif_buf[DELAY_C + 1];
	local bit valid_buf[DELAY_C + 1];
	local bit new_buf[DELAY_C + 1];
	local bit[31:0] nonce;

/*
	bit[31:0] _h[8] = {
   	 32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
 	 };
  
 	 //coreInputsIfc.reader in

	bit _valid;
	bit _newBlock;
 	bit [511:0] _firstChunk;

 	bit [31:0] _w1;
 	bit [31:0] _w2;
	bit [31:0] _w3;
 	bit [31:0] _nonce;


  	bit [255:0] _result;
*/

	function new();
		// Initialize buffers
		for (int i = 0; i <= DELAY_C; i++) begin
			hash_buf[i] = 0;
			dif_buf[i] = 0;
			valid_buf[i] = 1'b0;
			new_buf[i] = 1'b0;
		end
		nonce = PROCESSORINDEX;
	endfunction

  
/*
  function configure( virtual coreInputsIfc in );
    _valid = in.valid;
    _newBlock = in.newblock;
    
    _h[0] = in.hashstate.a;
    _h[1] = in.hashstate.b;
    _h[2] = in.hashstate.c;
    _h[3] = in.hashstate.d;
    _h[4] = in.hashstate.e;
    _h[5] = in.hashstate.f;
    _h[6] = in.hashstate.g;
    _h[7] = in.hashstate.h;
    
    _w1 = in.w1;
    _w2 = in.w2;
    _w3 = in.w3;
  endfunction
*/



/*
  function new( virtual coreInputsIfc in );
    configure( in );
  endfunction
*/

  
/*
  function set_hashstate( HashState in );
    _h[0] = in.a;
    _h[1] = in.b;
    _h[2] = in.c;
    _h[3] = in.d;
    _h[4] = in.e;
    _h[5] = in.f;
    _h[6] = in.g;
    _h[7] = in.h;
  endfunction 


  function HashState get_hashstate();
    HashState result;
    
    result.a = _h[0];
    result.b = _h[1];
    result.c = _h[2];
    result.d = _h[3];
    result.e = _h[4];
    result.f = _h[5];
    result.g = _h[6];
    result.h = _h[7]; 

    return result;
  endfunction
*/

/*
  function setValid( bit valid );
    _valid = valid;
  endfunction


  function setNewBlock( bit newBlock );
    _newBlock = newBlock;
  endfunction  


  function set_and_evaluate( virtual coreInputsIfc in );
    configure( in );
    evaluate();
  endfunction
*/

	

	local function bit[255:0] evaluate(bit[31:0] hs[8], bit[31:0] w1, bit[31:0] w2, bit[31:0] w3);
		bit[639:0] msg1;
		bit[255:0] middleHash;
		bit[31:0] _h[8];
		bit arr[];


		// Note: 512 bits of 0 are just for padding: They are not used in our algorithm
		// Note: sha256 function must be passed a dynamic array
		// Note: sha256 expects the bits in the opposite order, so we reverse them
		msg1 = { 512'b0, w1, w2, w3, nonce };
		arr = new[640];
		for (int i = 0; i < 640; i++)
			arr[i] = msg1[639 - i];
		middleHash = golden_sha256( hs, arr );

		// This is SHA-specific hard-coded hash state
		_h = {
			32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a,
			32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
		};

		arr = new[256];
		for (int i = 0; i < 256; i++)
			arr[i] = middleHash[255 - i];
		return golden_sha256( _h, arr);
	endfunction

/*
  function bit[255:0] getResult();
    // should only make result available after a particular time
    return _result;
  endfunction
*/

	task cycle();
		bit[31:0] hs[8];
		bit[31:0] w1, w2, w3;
		bit[255:0] out;

		// Advance buffers
		for (int i = DELAY_C; i > 0; i--) begin
			valid_buf[i] = valid_buf[i - 1];
			dif_buf[i] = dif_buf[i - 1];
			hash_buf[i] = hash_buf[i - 1];
			new_buf[i] = new_buf[i - 1];
		end

		// Advance nonce
		if (validIn_i) begin
			if (newBlockIn_i)
				nonce = PROCESSORINDEX;
			else
				nonce += NUMPROCESSORS;
		end

		// Format input
		w3 = initialState_i[31:0];
		w2 = initialState_i[63:32];
		w1 = initialState_i[95:64];

		hs[7] = initialState_i[127:96];
		hs[6] = initialState_i[159:128];
		hs[5] = initialState_i[191:160];
		hs[4]= initialState_i[223:192];
		hs[3]= initialState_i[255:224];
		hs[2]= initialState_i[287:256];
		hs[1]= initialState_i[319:288];
		hs[0] = initialState_i[351:320];

		// Do SHA Logic
		out = evaluate(hs, w1, w2, w3);

		// Queue data in buffers
		valid_buf[0] = validIn_i;
		dif_buf[0] = w3;
		new_buf[0] = newBlockIn_i;
		hash_buf[0] = out;

		// Pull outputs from the other side of buffers
		validOut_o = valid_buf[DELAY_C];
		difficulty_o = dif_buf[DELAY_C];
		newBlockOut_o = new_buf[DELAY_C];
		hash_o = hash_buf[DELAY_C];
	endtask

endclass

