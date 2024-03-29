module seventhreecompressor(
input logic[6:0] in,
output logic[2:0] sum
);

always_comb begin
  case(in)
      0: sum=0;
      1: sum=1;
      2: sum=1;
      3: sum=2;
      4: sum=1;
      5: sum=2;
      6: sum=2;
      7: sum=3;
      8: sum=1;
      9: sum=2;
      10: sum=2;
      11: sum=3;
      12: sum=2;
      13: sum=3;
      14: sum=3;
      15: sum=4;
      16: sum=1;
      17: sum=2;
      18: sum=2;
      19: sum=3;
      20: sum=2;
      21: sum=3;
      22: sum=3;
      23: sum=4;
      24: sum=2;
      25: sum=3;
      26: sum=3;
      27: sum=4;
      28: sum=3;
      29: sum=4;
      30: sum=4;
      31: sum=5;
      32: sum=1;
      33: sum=2;
      34: sum=2;
      35: sum=3;
      36: sum=2;
      37: sum=3;
      38: sum=3;
      39: sum=4;
      40: sum=2;
      41: sum=3;
      42: sum=3;
      43: sum=4;
      44: sum=3;
      45: sum=4;
      46: sum=4;
      47: sum=5;
      48: sum=2;
      49: sum=3;
      50: sum=3;
      51: sum=4;
      52: sum=3;
      53: sum=4;
      54: sum=4;
      55: sum=5;
      56: sum=3;
      57: sum=4;
      58: sum=4;
      59: sum=5;
      60: sum=4;
      61: sum=5;
      62: sum=5;
      63: sum=6;
      64: sum=1;
      65: sum=2;
      66: sum=2;
      67: sum=3;
      68: sum=2;
      69: sum=3;
      70: sum=3;
      71: sum=4;
      72: sum=2;
      73: sum=3;
      74: sum=3;
      75: sum=4;
      76: sum=3;
      77: sum=4;
      78: sum=4;
      79: sum=5;
      80: sum=2;
      81: sum=3;
      82: sum=3;
      83: sum=4;
      84: sum=3;
      85: sum=4;
      86: sum=4;
      87: sum=5;
      88: sum=3;
      89: sum=4;
      90: sum=4;
      91: sum=5;
      92: sum=4;
      93: sum=5;
      94: sum=5;
      95: sum=6;
      96: sum=2;
      97: sum=3;
      98: sum=3;
      99: sum=4;
      100: sum=3;
      101: sum=4;
      102: sum=4;
      103: sum=5;
      104: sum=3;
      105: sum=4;
      106: sum=4;
      107: sum=5;
      108: sum=4;
      109: sum=5;
      110: sum=5;
      111: sum=6;
      112: sum=3;
      113: sum=4;
      114: sum=4;
      115: sum=5;
      116: sum=4;
      117: sum=5;
      118: sum=5;
      119: sum=6;
      120: sum=4;
      121: sum=5;
      122: sum=5;
      123: sum=6;
      124: sum=5;
      125: sum=6;
      126: sum=6;
      127: sum=7;
  endcase
end
endmodule
