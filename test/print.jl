# Oneport
# [@in/@out]
# [wire/reg/logic/None]
# [num/None] 
# [one/multiple]
# 
# max(2,4,2,2) = 4?

a = @portoneline @in wire clk
@test string.(a) == ["input clk"]

b = @portoneline @out reg 8 dout1, dout2
@test string.(b) == [
    "output reg [7:0] dout1",
    "output reg [7:0] dout2"
]

c = @portoneline @in logic din1, din2, din3 
@test string.(c) == [
    "input logic din1",
    "input logic din2",
    "input logic din3"
]

d = @portoneline @out 10 dout 
@test string.(d) == ["output [9:0] dout"]


# Ports
# muliple lines
e = @ports (
    @in 8 din;
    @out logic dout1, dout2
)
@test string(e) == """(
    input [7:0] din,
    output logic dout1,
    output logic dout2
);
"""

# one line
f = @ports (
    @in clk
)
@test string(f) == """(
    input clk
);
"""


# Wireexpr

w = @wireexpr (a + b) << (c - d) >> e & f
@test string(w) == "((((a + b) << (c - d)) >> e) & f)"

w = @wireexpr &(a) | ~(^(b) ^ -c) == |(d)
@test string(w) == "((&(a) | ~(^(b) ^ -c)) == |(d))"

w = @wireexpr (0x12 <= 0b100) && (10 < x[10:1]) || y[z:1]
@test string(w) == "(((18 <= 4) && (10 < x[10:1])) || y[z:1])"

w = w = Wireexpr(32, 5)
@test string(w) == "32'd5"

# Alassign 