# Oneparam
p = @oneparam p1 = 800
@test string(p) == "parameter p1 = 800"


# Parameters
p = @parameters (
    a = 10; b = 11
)
@test string(p) == """
#(
    parameter a = 10,
    parameter b = 11
)"""

p = @parameters (c = 1)
@test string(p) == """
#(
    parameter c = 1
)"""


# Oneport
# [@in/@out]
# [wire/reg/logic/None]
# [num/None] 
# [one/multiple]
# 
# max(2,4,2,2) = 4?

a = @portoneline @in @wire clk
@test string.(a) == ["input clk"]

b = @portoneline @out @reg 8 dout1, dout2
@test string.(b) == [
    "output reg [7:0] dout1",
    "output reg [7:0] dout2"
]

c = @portoneline @in @logic din1, din2, din3 
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
    @out @logic dout1, dout2
)
@test string(e) == """(
    input [7:0] din,
    output logic dout1,
    output logic dout2
);"""

# one line
f = @ports (
    @in clk
)
@test string(f) == """(
    input clk
);"""


# Onelocalparam
p = @onelocalparam p1 = 111
@test string(p) == "localparam p1 = 111;"


# Onedecl
d = @decloneline (@wire 2 << 1 xy SEN+HYAKU)
@test string(d[]) == """
wire [(2 << 1)-1:0] xy [(SEN + HYAKU)-1:0];"""

# Wireexpr

w = @wireexpr (a + b) << (c - d) >> e & f
@test string(w) == "((((a + b) << (c - d)) >> e) & f)"

w = @wireexpr &(a) | ~(^(b) ^ -c) == |(d)
@test string(w) == "(((&(a)) | (~((^(b)) ^ (-c)))) == (|(d)))"

## + and * parses in a special manner
w = @wireexpr a+b+c+d+e
@test string(w) == "((((a + b) + c) + d) + e)"

w = @wireexpr (0x12 <= 0b100) && (10 < x[10:1]) || y[z:1]
@test string(w) == "(((18 <= 4) && (10 < x[10:1])) || y[z:1])"

w = Wireexpr(32, 5)
@test string(w) == "32'd5"

w = @wireexpr a[(P<<Q)-:(A+B)]
@test string(w) == "a[(P << Q) -: (A + B)]"

w = @wireexpr b[P-:4]
@test string(w) == "b[P -: 4]"

# Alassign 
a = oneblock(:( x <= y ))[2] |> eval
@test string(a) == "x <= y;"

a = oneblock(:( x[4:0] <= y & z))[2] |> eval
@test string(a) == "x[4:0] <= (y & z);"


# Ifelseblock
# a = oneblock(:(
#     if b1 && b2 
#         x <= y 
#     else
#         x <= z;
#         y <= z
#     end
# ))[2] |> eval
# @test string(a) == """
# if ((b1 && b2)) begin
#     x <= y;
# end else begin
#     x <= z;
#     y <= z;
# end"""

# a = oneblock( :(
#     if b1 && b2 
#         x <= y+z;
#     elseif b3
#         if b4 
#             y <= r[3:0]
#         end
#         if b5 
#             d <= y + z 
#         elseif b6 
#             r <= z ^ t;
#             u <= d | e 
#         end
#     end
# ))[2] |> eval
# @test string(a) == """
# if ((b1 && b2)) begin
#     x <= (y + z);
# end else if (b3) begin
#     if (b4) begin
#         y <= r[3:0];
#     end
#     if (b5) begin
#         d <= (y + z);
#     end else if (b6) begin
#         r <= (z ^ t);
#         u <= (d | e);
#     end
# end"""

v = @ifcontent (
    x = z;
    if b 
        x = w 
    end
) 
b = Ifelseblock([], [v])
@test string(b) == """
x = z;
if (b) begin
    x = w;
end"""


# Case
a = Case(Wireexpr("state"), [
    (Wireexpr("suno") => @ifcontent x = y),
    (Wireexpr("sdos") => @ifcontent y <= z)
])

@test string(a) == """
case (state)
    suno: begin
        x = y;
    end
    sdos: begin
        y <= z;
    end
endcase"""

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

# module instantiation check
inst = Vmodinst(
    "test1",
    "u0",
    ["x" => (@wireexpr 10)],
    [i => Wireexpr(i) for i in ["din", "dout"]]
)

md = Vmodule(
    "test",
    (@parameters x = 2),
    (@ports (
        @in 4 din, dum1;
        @out @reg 4 dout, dum2
    )),
    Localparams(),
    Decls(),

    [inst],
    Assign[],
    [@always (
        dum2 = dum1
    )]
)

@test string(md) == """
module test #(
    parameter x = 2
)(
    input [3:0] din,
    input [3:0] dum1,
    output reg [3:0] dout,
    output reg [3:0] dum2
);
    test1 #(
        .x(10)
    ) u0 (
        .din(din),
        .dout(dout)
    );
    always_comb begin
        dum2 = dum1;
    end
endmodule"""