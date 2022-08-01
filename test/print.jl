# portoneline 
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