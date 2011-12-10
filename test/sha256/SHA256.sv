
function automatic bit[0:255] sha256( string message );

  bit[0:255] result;

  //Initialize variables
  //(first 32 bits of the fractional parts of the square roots of the first 8 primes 2..19):
  //h[0..7] := 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19;
  bit [0:31] _h[8] = {
    32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
  };

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
  int padding;
  int minus;
  

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


