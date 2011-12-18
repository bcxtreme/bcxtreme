
// convert to binary inputs (move string stuff outside) 

// also allow _h as parameter and number of remaining rounds

// only three words in the 2nd chunk are needed. nonce is the 4th word and the rest are padding - remember the last word of padding is the length - 640 (80 bytes) if newBlock and valid high then nonce is 0, else previous + 1 eh? 

/*
function automatic bit[255:0] little_endian_sha256( bit[31:0] _h[8], bit data[], int round_number );

  bit [0:31] _h_be[8];
  bit data_be[];

  bit[0:255] result_be;
  bit[255:0] result;

  // convert data
  data_be = new[data.size()];
  for ( int i = 0; i < data.size(); i++ ) begin
    data_be[i] = data[(data.size() -1) - i];
  end

  // convert _h
  for ( int j = 0; j < 8; j++ ) begin
    for ( int i = 0; i < 32; i++ ) begin
      _h_be[i] = _h[i][(31) - i];
    end   
  end

  // now do it all in big-endian
  result_be = bitcoin_sha256( _h_be, data_be, round_number );

  // convert result
  for ( int i = 0; i < 256; i++ ) begin
    result[i] = result_be[255 - i];
  end  

  return result;

endfunction : little_endian_sha256
*/


function bit [0:31] little_endian_to_big( bit[31:0] in );

  bit[0:31] b0, b1, b2, b3;

  b0 = ( in & 8'hff ) >> 0;
  b1 = ( in & 16'hff00 ) >> 8;
  b2 = ( in & 24'hff0000 ) >> 16;
  b3 = ( in & 32'hff000000 ) >> 24;

  return (( b0 << 24 ) | ( b1 << 16 ) | (b2 << 8 ) | ( b3 << 0 ) );

endfunction


function automatic bit[0:255] golden_sha256( bit[0:31] _h[8], bit data[] );

  int start_chunk;

  bit[0:255] result;
  bit _data[];
  int _data_size;
  bit[0:63] _original_data_size;

  int minus;
  int padding;

  bit [0:31] _k[64] = {
    32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
    32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
    32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
    32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
    32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
    32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
    32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
    32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
  };

  _data = data;

  // resize and add trailing 1
  _data_size = _data.size();
  _original_data_size = _data_size;
  _data = new[_data_size + 1](_data);
  _data[_data_size] = 1;

  // calculate padding, resize and add it
  padding = 512 - ( _data.size() % 512 );
  if ( padding < 64 ) begin
    minus = 64 - padding;
    padding = 512 - minus; 
  end
  else
    padding = padding - 64;
  
  //$display( "size=%d, minus=%d, padding=%d",binary_message_size, minus, padding );

  _data_size = _data.size();
  _data = new[_data_size + padding](_data);

  // unnecessary because automatically initializes to 0
  for ( int pad = 0; pad < padding; pad++ ) begin
    _data[_data_size + 1 + pad] = 0;
  end

  // resize and add size of message prior to pre-processing
  _data = new[_data.size() + 64](_data);
  //_data_size_original = ;

  //$display( binary_message_size );

  for ( int append = 0; append < 64; append++ ) begin
    _data[_data.size() - 64 + append] = _original_data_size[append];
  end

  //$display( _data );

  $display( "golden_sha256 : Original data size = %d", _original_data_size );  

  //$display( binary_array_to_string( binary_message ) );
  //$display( binary_message.size() );

  // if we were passed some intermediate _h assume that we are started on the second chunk
  if ( _h[0] != 32'h6a09e667 ) begin 
    start_chunk = 1;
    $display( "golden_sha256 : Skipping 1st CHUNK" );
  end
  else
    start_chunk = 0;

  //Process the message in successive 512-bit chunks:
  //break message into 512-bit chunks
  //for each chunk
  //  break chunk into sixteen 32-bit big-endian words w[0..15]
  for ( int chunk = start_chunk; chunk < _data.size() / 512; chunk++ ) begin
    
    bit[0:31] a = _h[0];
    bit[0:31] b = _h[1];
    bit[0:31] c = _h[2];
    bit[0:31] d = _h[3];
    bit[0:31] e = _h[4];
    bit[0:31] f = _h[5];
    bit[0:31] g = _h[6];
    bit[0:31] h = _h[7];

    bit [0:31] w[64];
    for ( int word = 0; word < 16; word++ ) begin
      for ( int _bit = 0; _bit < 32; _bit++ ) begin
        w[word][_bit] = _data[chunk*512 + word*32 + _bit]; 
        //$display( "chunk=%d,word=%d,bit=%d ->%d", chunk, word, _bit, _data[chunk*512 + word*32 + _bit] ); 
      end
    end

    //Extend the sixteen 32-bit words into sixty-four 32-bit words:
    //for i from 16 to 63
    //  s0 := (w[i-15] rightrotate 7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift 3)
    //  s1 := (w[i-2] rightrotate 17) xor (w[i-2] rightrotate 19) xor (w[i-2] rightshift 10)
    //  w[i] := w[i-16] + s0 + w[i-7] + s1
    for ( int extend = 16; extend < 64; extend++ ) begin
      int s0 = rightrotate( w[extend-15], 7 ) ^ rightrotate( w[extend-15], 18 ) ^ ( w[extend-15] >> 3 );
      int s1 = rightrotate( w[extend-2], 17 ) ^ rightrotate( w[extend-2], 19 ) ^ ( w[extend-2] >> 10 );
      w[extend] = w[extend-16] + s0 + w[extend-7] + s1;
    end 

    //$display( "...actually processing chunk" );

    //Initialize hash value for this chunk:
    //a := h0
    //b := h1
    //c := h2
    //d := h3
    //e := h4
    //f := h5
    //g := h6
    //h := h7
    // (see at start of loop)

    //Main loop:
    //for i from 0 to 63
    //  s0 := (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
    //  maj := (a and b) xor (a and c) xor (b and c)
    //  t2 := s0 + maj
    //  s1 := (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
    //  ch := (e and f) xor ((not e) and g)
    //  t1 := h + s1 + ch + k[i] + w[i]

    //  h := g
    //  g := f
    //  f := e
    //  e := d + t1
    //  d := c
    //  c := b
    //  b := a
    //  a := t1 + t2

    for ( int i = 0; i < 64; i++ ) begin
      /*
      int s0 = rightrotate( a, 2 ) ^ rightrotate( a, 13 ) ^ rightrotate( a, 22 );
      int maj = (a & b) ^ (a & c) ^ (b & c);
      int t2 = s0 + maj;
      int s1 = rightrotate( e, 6 ) ^ rightrotate( e, 11 ) ^ rightrotate( e, 25);
      int ch = (e & f) ^ ((~ e) & g);
      int t1 = h + s1 + ch + _k[i] + w[i];

      h = g;
      g = f;
      f = e;
      e = d + t1;
      d = c;
      c = b;
      b = a;
      a = t1 + t2;
      */
      single_round( a, b, c, d, e, f, g, h, i, w[i] );
    end


    //Add this chunk's hash to result so far:
    //h0 := h0 + a
    //h1 := h1 + b
    //h2 := h2 + c
    //h3 := h3 + d
    //h4 := h4 + e
    //h5 := h5 + f
    //h6 := h6 + g
    //h7 := h7 + h
    _h[0] += a;
    _h[1] += b;
    _h[2] += c;
    _h[3] += d;
    _h[4] += e;
    _h[5] += f;
    _h[6] += g;
    _h[7] += h;

  end
 
  result = { _h[0], _h[1], _h[2], _h[3], _h[4], _h[5], _h[6], _h[7] };
  
  //$display( result );

  return result;


endfunction  




// round_number is 1 based!
function automatic bit[0:255] bitcoin_sha256( bit[0:31] _h[8], bit data[], int round_number ); //, bit[0:31] w1, bit[0:31] w2, bit[0:31] w3, int round_number ) {

  int start_point;

  bit[0:255] result;
  bit _data[];
  int _data_size;
  bit[0:63] _original_data_size;

  int minus;
  int padding;

  bit [0:31] _k[64] = {
    32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
    32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
    32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
    32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
    32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
    32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
    32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
    32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
  };

  // just in case the function can skip some of the rounds
  /*
  if ( round_number == 1 ) begin
    _h = {
      32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
    };
  end
  */

  _data = data;

  // resize and add trailing 1
  _data_size = _data.size();
  _original_data_size = _data_size;
  _data = new[_data_size + 1](_data);
  _data[_data_size] = 1;

  // calculate padding, resize and add it
  padding = 512 - ( _data.size() % 512 );
  if ( padding < 64 ) begin
    minus = 64 - padding;
    padding = 512 - minus; 
  end
  else
    padding = padding - 64;
  
  //$display( "size=%d, minus=%d, padding=%d",binary_message_size, minus, padding );

  _data_size = _data.size();
  _data = new[_data_size + padding](_data);

  // unnecessary because automatically initializes to 0
  for ( int pad = 0; pad < padding; pad++ ) begin
    _data[_data_size + 1 + pad] = 0;
  end

  // resize and add size of message prior to pre-processing
  _data = new[_data.size() + 64](_data);
  //_data_size_original = ;

  //$display( binary_message_size );

  for ( int append = 0; append < 64; append++ ) begin
    _data[_data.size() - 64 + append] = _original_data_size[append];
  end

  //$display( binary_array_to_string( binary_message ) );
  //$display( binary_message.size() );



  //Process the message in successive 512-bit chunks:
  //break message into 512-bit chunks
  //for each chunk
  //  break chunk into sixteen 32-bit big-endian words w[0..15]
  for ( int chunk = 0; chunk < _data.size() / 512; chunk++ ) begin
    
    bit[0:31] a = _h[0];
    bit[0:31] b = _h[1];
    bit[0:31] c = _h[2];
    bit[0:31] d = _h[3];
    bit[0:31] e = _h[4];
    bit[0:31] f = _h[5];
    bit[0:31] g = _h[6];
    bit[0:31] h = _h[7];

    bit [0:31] w[64];
    for ( int word = 0; word < 16; word++ ) begin
      for ( int _bit = 0; _bit < 32; _bit++ ) begin
        w[word][_bit] = _data[chunk*512 + word*32 + _bit]; 
        //$display( "chunk=%d,word=%d,bit=%d ->%d", chunk, word, _bit, binary_message[chunk*512 + word*32 + _bit] ); 
      end
    end

    //Extend the sixteen 32-bit words into sixty-four 32-bit words:
    //for i from 16 to 63
    //  s0 := (w[i-15] rightrotate 7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift 3)
    //  s1 := (w[i-2] rightrotate 17) xor (w[i-2] rightrotate 19) xor (w[i-2] rightshift 10)
    //  w[i] := w[i-16] + s0 + w[i-7] + s1
    for ( int extend = 16; extend < 64; extend++ ) begin
      int s0 = rightrotate( w[extend-15], 7 ) ^ rightrotate( w[extend-15], 18 ) ^ ( w[extend-15] >> 3 );
      int s1 = rightrotate( w[extend-2], 17 ) ^ rightrotate( w[extend-2], 19 ) ^ ( w[extend-2] >> 10 );
      w[extend] = w[extend-16] + s0 + w[extend-7] + s1;
    end 

    //Initialize hash value for this chunk:
    //a := h0
    //b := h1
    //c := h2
    //d := h3
    //e := h4
    //f := h5
    //g := h6
    //h := h7
    // (see at start of loop)

    //Main loop:
    //for i from 0 to 63
    //  s0 := (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
    //  maj := (a and b) xor (a and c) xor (b and c)
    //  t2 := s0 + maj
    //  s1 := (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
    //  ch := (e and f) xor ((not e) and g)
    //  t1 := h + s1 + ch + k[i] + w[i]

    //  h := g
    //  g := f
    //  f := e
    //  e := d + t1
    //  d := c
    //  c := b
    //  b := a
    //  a := t1 + t2

    if ( chunk == 0 ) begin
      start_point = round_number - 1;
      $display( "start_point=%d", start_point );
    end
    else
      start_point = 0;

    for ( int i = start_point; i < 64; i++ ) begin
      /*
      int s0 = rightrotate( a, 2 ) ^ rightrotate( a, 13 ) ^ rightrotate( a, 22 );
      int maj = (a & b) ^ (a & c) ^ (b & c);
      int t2 = s0 + maj;
      int s1 = rightrotate( e, 6 ) ^ rightrotate( e, 11 ) ^ rightrotate( e, 25);
      int ch = (e & f) ^ ((~ e) & g);
      int t1 = h + s1 + ch + _k[i] + w[i];

      h = g;
      g = f;
      f = e;
      e = d + t1;
      d = c;
      c = b;
      b = a;
      a = t1 + t2;
      */
      single_round( a, b, c, d, e, f, g, h, i, w[i] );
    end


    //Add this chunk's hash to result so far:
    //h0 := h0 + a
    //h1 := h1 + b
    //h2 := h2 + c
    //h3 := h3 + d
    //h4 := h4 + e
    //h5 := h5 + f
    //h6 := h6 + g
    //h7 := h7 + h
    _h[0] += a;
    _h[1] += b;
    _h[2] += c;
    _h[3] += d;
    _h[4] += e;
    _h[5] += f;
    _h[6] += g;
    _h[7] += h;

  end
 
  result = { _h[0], _h[1], _h[2], _h[3], _h[4], _h[5], _h[6], _h[7] };
  
  return result;

  $display( "%h", result );
     
endfunction


function automatic bit[0:255] sha256( string message );

  bit[0:255] result;

  //Initialize variables
  //(first 32 bits of the fractional parts of the square roots of the first 8 primes 2..19):
  //h[0..7] := 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19;
  bit [0:31] _h[8] = {
    32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
  };

  bit [0:31] __h[8];

  //Initialize table of round constants
  //(first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311):
  //k[0..63] :=
  //0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  //0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 
  //0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  //0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  //0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  //0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  //0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  //0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  bit [0:31] _k[64] = {
    32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
    32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
    32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
    32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
    32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
    32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
    32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
    32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
  };

  int binary_size;
  longint binary_message_size;
  bit[0:63] binary_message_size_as_binary;
  bit binary_message[];
  bit binary_message_original[];
  int padding;
  int minus;

  bit[0:31] placeholder[8];
  

  bit[0:7] _byte;
  int offset;

  //message = "hello"; // there you magical fox and ere you  fox you and you ";
  //message = "The quick brown fox jumps over the lazy dog.";

  //$display( "%s [%d bytes = %d bits]", message, message.len(), message.len() * 8 );
  binary_size = message.len() * 8;
  binary_message = new[binary_size];

  offset = 0;

  for ( int i = 0; i < message.len(); i++ ) begin
    offset = i * 8; // length of byte
    _byte = message[i];
    //$display( "%h", _byte );
    for ( int k = 0; k < 8; k++ ) begin
      binary_message[offset + k] = _byte[k];
    end
  end
 
  binary_message_original = binary_message;
  $display( "%h", bitcoin_sha256( _h, binary_message_original, 1 ) );

  //for ( int j = 0; j < binary_message.size(); j++ ) begin
    //$display( binary_message[j] );    
  //end

  //$display( binary_array_to_string( binary_message ) );

  //Pre-processing:
  //append the bit '1' to the message
  //append k bits '0', where k is the minimum number >= 0 such that the resulting message
  //length (in bits) is congruent to 448 (mod 512)
  //append length of message (before pre-processing), in bits, as 64-bit big-endian integer
  
  // resize and add trailing 1
  binary_message_size = binary_message.size();
  binary_message = new[binary_message.size() + 1](binary_message);
  binary_message[binary_message.size() - 1] = 1;

  //$display( binary_array_to_string( binary_message ) );

  // calculate padding, resize and add it
  padding = 512 - ( (binary_message_size + 1) % 512 );
  if ( padding < 64 ) begin
    minus = 64 - padding;
    padding = 512 - minus; 
  end
  else
    padding = padding - 64;
  
  //$display( "size=%d, minus=%d, padding=%d",binary_message_size, minus, padding );

  binary_message = new[binary_message.size() + padding](binary_message);

  // unnecessary because automatically initializes to 0
  for ( int pad = 0; pad < padding; pad++ ) begin
    binary_message[binary_message_size + 1 + pad] = 0;
  end

  //$display( binary_array_to_string( binary_message ) );
  //$display( binary_message.size() );

  // resize and add size of message prior to pre-processing
  binary_message = new[binary_message.size() + 64](binary_message);
  binary_message_size_as_binary = binary_message_size;

  //$display( binary_message_size );

  for ( int append = 0; append < 64; append++ ) begin
    binary_message[binary_message.size() - 64 + append] = binary_message_size_as_binary[append];
  end

  //$display( binary_array_to_string( binary_message ) );
  //$display( binary_message.size() );



  //Process the message in successive 512-bit chunks:
  //break message into 512-bit chunks
  //for each chunk
  //  break chunk into sixteen 32-bit big-endian words w[0..15]
  for ( int chunk = 0; chunk < binary_message.size() / 512; chunk++ ) begin



    bit[0:31] a = _h[0];
    bit[0:31] b = _h[1];
    bit[0:31] c = _h[2];
    bit[0:31] d = _h[3];
    bit[0:31] e = _h[4];
    bit[0:31] f = _h[5];
    bit[0:31] g = _h[6];
    bit[0:31] h = _h[7];

    bit [0:31] w[64];
    for ( int word = 0; word < 16; word++ ) begin
      for ( int _bit = 0; _bit < 32; _bit++ ) begin
        w[word][_bit] = binary_message[chunk*512 + word*32 + _bit]; 
        //$display( "chunk=%d,word=%d,bit=%d ->%d", chunk, word, _bit, binary_message[chunk*512 + word*32 + _bit] ); 
      end
    end

    //Extend the sixteen 32-bit words into sixty-four 32-bit words:
    //for i from 16 to 63
    //  s0 := (w[i-15] rightrotate 7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift 3)
    //  s1 := (w[i-2] rightrotate 17) xor (w[i-2] rightrotate 19) xor (w[i-2] rightshift 10)
    //  w[i] := w[i-16] + s0 + w[i-7] + s1
    for ( int extend = 16; extend < 64; extend++ ) begin
      int s0 = rightrotate( w[extend-15], 7 ) ^ rightrotate( w[extend-15], 18 ) ^ ( w[extend-15] >> 3 );
      int s1 = rightrotate( w[extend-2], 17 ) ^ rightrotate( w[extend-2], 19 ) ^ ( w[extend-2] >> 10 );
      w[extend] = w[extend-16] + s0 + w[extend-7] + s1;
    end 

    //Initialize hash value for this chunk:
    //a := h0
    //b := h1
    //c := h2
    //d := h3
    //e := h4
    //f := h5
    //g := h6
    //h := h7
    // (see at start of loop)

    //Main loop:
    //for i from 0 to 63
    //  s0 := (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
    //  maj := (a and b) xor (a and c) xor (b and c)
    //  t2 := s0 + maj
    //  s1 := (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
    //  ch := (e and f) xor ((not e) and g)
    //  t1 := h + s1 + ch + k[i] + w[i]

    //  h := g
    //  g := f
    //  f := e
    //  e := d + t1
    //  d := c
    //  c := b
    //  b := a
    //  a := t1 + t2
    for ( int i = 0; i < 64; i++ ) begin

      if ( chunk == 0 && i == 0 ) begin
        //__h = { a, b, c, d, e, f, g, h };
        __h = { _h[0], _h[1], _h[2], _h[3], _h[4], _h[5], _h[6], _h[7] };
        $display( "%h", bitcoin_sha256( __h, binary_message_original, i + 1) );
      end

      /*
      int s0 = rightrotate( a, 2 ) ^ rightrotate( a, 13 ) ^ rightrotate( a, 22 );
      int maj = (a & b) ^ (a & c) ^ (b & c);
      int t2 = s0 + maj;
      int s1 = rightrotate( e, 6 ) ^ rightrotate( e, 11 ) ^ rightrotate( e, 25);
      int ch = (e & f) ^ ((~ e) & g);
      int t1 = h + s1 + ch + _k[i] + w[i];

      h = g;
      g = f;
      f = e;
      e = d + t1;
      d = c;
      c = b;
      b = a;
      a = t1 + t2;
      */

      single_round( a, b, c, d, e, f, g, h, i, w[i] );

    end


    //Add this chunk's hash to result so far:
    //h0 := h0 + a
    //h1 := h1 + b
    //h2 := h2 + c
    //h3 := h3 + d
    //h4 := h4 + e
    //h5 := h5 + f
    //h6 := h6 + g
    //h7 := h7 + h
    _h[0] += a;
    _h[1] += b;
    _h[2] += c;
    _h[3] += d;
    _h[4] += e;
    _h[5] += f;
    _h[6] += g;
    _h[7] += h;

  end

  result = { _h[0], _h[1], _h[2], _h[3], _h[4], _h[5], _h[6], _h[7] };
  
  return result;

  //$display( "%h", result );

endfunction
  

function automatic bit[255:0] sha256_other( string message );
  return sha256( message );
endfunction 


function automatic single_round( ref bit[0:31] a, ref bit[0:31] b, ref bit[0:31] c, ref bit[0:31] d, ref bit[0:31] e, ref bit[0:31] f, ref bit[0:31] g, ref bit[0:31] h, int round_number, bit[0:31] round_word );

  bit [0:31] _k[64] = {
    32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
    32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
    32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
    32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
    32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
    32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
    32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
    32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
  };

  int s0 = rightrotate( a, 2 ) ^ rightrotate( a, 13 ) ^ rightrotate( a, 22 );
  int maj = (a & b) ^ (a & c) ^ (b & c);
  int t2 = s0 + maj;
  int s1 = rightrotate( e, 6 ) ^ rightrotate( e, 11 ) ^ rightrotate( e, 25);
  int ch = (e & f) ^ ((~ e) & g);
  int t1 = h + s1 + ch + _k[round_number] + round_word;

  h = g;
  g = f;
  f = e;
  e = d + t1;
  d = c;
  c = b;
  b = a;
  a = t1 + t2;

endfunction


function string binary_array_to_string( bit _array[] );
  string result;
  string temp;

  for ( int i = 0; i < _array.size(); i++ ) begin
    temp.bintoa( _array[i] );
    //$display( "temp = %s", temp );
    result = { result, temp };
  end

  return result;
endfunction


function bit[0:31] rightrotate(bit[0:31] value, int shift);
  return ( value >> shift ) | ( value << (32 - shift) );
endfunction


