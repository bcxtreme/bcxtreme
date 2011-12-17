
class golden_sha;

  bit[31:0] _h[8] = {
    32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
  };

  int _nonce;

  bit _valid;
  bit _newBlock;
  bit _initialState[];

  bit [255:0] _result;

  function setValid( bit valid );
    _valid = valid;
  endfunction

  function setNewBlock( bit newBlock );
    _newBlock = newBlock;
  endfunction  

  function setInitialState( bit initialState[] );
    _initialState = initialState;
  endfunction

  function evaluate();

    int round_number = 1;  

    if ( _valid && _newBlock )
      _nonce = 0;
    else
      _nonce += 1;

    // if you want to skip a round _h will need to contain the results of the first round
    _result = bitcoin_sha256( _h, _initialState, round_number );
  endfunction

  function getResult();
    // should only make result available after a particular time
    return _result;
  endfunction

endclass

