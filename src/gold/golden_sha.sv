



class golden_sha;

  
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


  function new( virtual coreInputsIfc in );
    configure( in );
  endfunction

  
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


  function reset();
    // what else should be emulated here

    _h = {
      32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
    };
  endfunction   

  //function set_h( bit [31:0] h[8] );
    //_h = h;
  //endfunction


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


  function evaluate();

    bit message_1[];
    bit[639:0] message_1_bits;

    bit message_2[];

    bit [255:0] result1;
    bit [255:0] result2;

    $display( "w1=%h, w2=%h, w3=%h", _w1, _w2, _w3 );    

    if ( _valid && _newBlock )
      _nonce = 0;
    else
      _nonce += 1;

    
    $display( "nonce=%d", _nonce );

    message_1_bits = { _firstChunk, _w1, _w2, _w3, _nonce };
    
    message_1 = new[640];

    // converting from arrays to dynamic arrays is "very sophisticated" in SystemVerilog
    for ( int i = 0; i < 640; i++ )
      message_1[i] = message_1_bits[i];

    result1 = golden_sha256( _h, message_1 );

    $display( "First SHA256=%h", result1 );

    message_2 = new[256];

    // converting from arrays to dynamic arrays is "very sophisticated" in SystemVerilog
    for ( int i = 0; i < 256; i++ )
      message_2[i] = result1[i];

    // perform a full SHA256 the second time
    _h = {
      32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
    };

    result2 = golden_sha256( _h, message_2 );

    $display( "Second SHA256=%h", result2 );
    
    _result = result2; 

  endfunction

  function bit[255:0] getResult();
    // should only make result available after a particular time
    return _result;
  endfunction

endclass

