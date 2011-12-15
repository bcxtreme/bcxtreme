
program automatic test();


initial begin

  string message;

  message = "";
  $display( "%s\n%h\n%h", message, sha256( message ), sha256_other( message ) );

  message = "Hello";
  $display( "%s\n%h\n%h", message, sha256( message ), sha256_other( message ) );

  message = "The quick brown fox jumps over the lazy dog";
  $display( "%s\n%h\n%h", message, sha256( message ), sha256_other( message ) );

  message = "The quick brown fox jumps over the lazy dog.";
  $display( "%s\n%h\n%h", message, sha256( message ), sha256_other( message ) );

   
end

endprogram : test

