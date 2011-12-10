
program automatic test();


initial begin

  string message;

  message = "";
  $display( "%s\n%h", message, sha256( message ) );

  message = "Hello";
  $display( "%s\n%h", message, sha256( message ) );

  message = "The quick brown fox jumps over the lazy dog";
  $display( "%s\n%h", message, sha256( message ) );

  message = "The quick brown fox jumps over the lazy dog.";
  $display( "%s\n%h", message, sha256( message ) );

   
end

endprogram : test

