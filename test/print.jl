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
a = @oneblock x <= y 
@test string(a) == "x <= y;"

a = @oneblock x[4:0] <= y & z
@test string(a) == "x[4:0] <= (y & z);"


# Ifelseblock
a = @oneblock (
    if b1 && b2 
        x <= y 
    else
        x <= z;
        y <= z
    end
)
@test string(a) == """
if ((b1 && b2)) begin
    x <= y;
end else begin
    x <= z;
    y <= z;
end"""

a = @oneblock (
    if b1 && b2 
        x <= y+z;
    elseif b3
        if b4 
            y <= r[3:0]
        end
        if b5 
            d <= y + z 
        elseif b6 
            r <= z ^ t;
            u <= d | e 
        end
    end
)
@test string(a) == """
if ((b1 && b2)) begin
    x <= (y + z);
end else if (b3) begin
    if (b4) begin
        y <= r[3:0];
    end
    if (b5) begin
        d <= (y + z);
    end else if (b6) begin
        r <= (z ^ t);
        u <= (d | e);
    end
end"""


# Alwayscontent
a = @always (
    x = y;
    z = b
)
@test string(a) == """
always_comb begin
    x = y;
    z = b;
end"""

a = @always (
    @posedge clk;

    x <= 3;
    if b1 || b2 
        x <= y << z 
    end
)
@test string(a) == """
always_ff @( posedge clk ) begin
    x <= 3;
    if ((b1 || b2)) begin
        x <= (y << z);
    end
end"""


# vmodule
