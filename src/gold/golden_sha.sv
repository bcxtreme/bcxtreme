
class golden_sha;

  bit[31:0] _h[8] = {
    32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
  };

  bit _valid;
  bit _newBlock;
  bit [544:0] _initialState;

  bit [31:0] _timestamp;
  bit [31:0] _target;
  bit [31:0] _nonce;


  bit [255:0] _result;

  
  function set_h( bit [31:0] h[8] );
    _h = h;
  endfunction


  function setValid( bit valid );
    _valid = valid;
  endfunction


  function setNewBlock( bit newBlock );
    _newBlock = newBlock;
  endfunction  


  function setInitialState( bit[544:0] initialState );
    _initialState = initialState;
  endfunction


  function setTimestamp( bit[31:0] timestamp );
    _timestamp = timestamp;
  endfunction


  function setTarget( bit[31:0] target );
    _target = target;
  endfunction


  function evaluate( int round_number = 1 );

    bit message[];
    bit[639:0] message_bits;

    if ( _valid && _newBlock )
      _nonce = 0;
    else
      _nonce += 1;

    message_bits = { _initialState, _timestamp, _target, _nonce };
    
    message = new[640];

    // converting from arrays to dynamic arrays is "very sophisticated" in SystemVerilog
    for ( int i = 0; i < 640; i++ )
      message[i] = message_bits[i];


    // if you want to skip a round _h will need to contain the results of the first round
    _result = bitcoin_sha256( _h, message, round_number );
  endfunction

  function getResult();
    // should only make result available after a particular time
    return _result;
  endfunction

endclass

