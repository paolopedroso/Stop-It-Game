// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module hex7seg(
    input  logic d3,d2,d1,d0,
    output logic A,B,C,D,E,F,G
);

assign A = ~((~d3& ~d2&~d1&d0)|(~d3&d2&~d1&~d0)|
            (d3 & d2 & ~d1 & d0)|(d3 & ~d2 & d1 & d0));

assign B = ~((~d3 & d2 & ~d1 & d0) | (~d3 & d2 & d1 & ~d0)
            |(d3 & ~d2 & d1 & d0) | (d3 & d2 & ~d1 & ~d0) | (d3 & d2 & d1 & ~d0) |
            (d3 & d2 & d1 & d0));

assign C = ~((~d3 & ~d2 & d1 & ~d0) | (d3 & d2 & ~d1 & ~d0) |
            (d3 & d2 & d1 & ~d0) | (d3 & d2 & d1 & d0));

assign D = ~((~d3 & ~d2 & ~d1 & d0) | (~d3 & d2 & ~d1 & ~d0) | (~d3 & d2 & d1 & d0) |
            (d3 & ~d2 & d1 & ~d0) | (d3 & d2 & d1  & d0));

assign E = ~((~d3 & ~d2 & ~d1 & d0) | (~d3 & ~d2 & d1 & d0) | (~d3 & d2 & ~d1 & ~d0) |
            (~d3 & d2 & ~d1 & d0) | (~d3 & d2 & d1 & d0) |
            (d3 & ~d2 & ~d1 & d0));

assign F = ~((~d3 & ~d2 & ~d1 & d0) |
            (~d3 & ~d2 & d1 & ~d0) | (~d3 & ~d2 & d1 & d0) | (~d3 & d2 & d1 & d0) |
            (d3 & d2 & ~d1 & d0));

assign G = ~((~d3 & ~d2 & ~d1 & ~d0) | (~d3 & ~d2 & ~d1 & d0) | (~d3 & d2 & d1 & d0) |
            (d3 & d2 & ~d1 & ~d0));

endmodule
