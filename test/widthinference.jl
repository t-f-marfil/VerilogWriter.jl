# inference on shift operator
# e.g. in `w = x << y` width of y is unknown
c = ifcontent(:(
    reg1 = $(Wireexpr(32, 5)) << reg2;
    reg2 = $(Wireexpr(10, 5))
))

d = autodecl(c)

@test string(d) == """
reg [31:0] reg1;
reg [9:0] reg2;"""

# Bitwise and reduction unary operator
c = ifcontent(:(
    reg1 = ^($(Wireexpr(32, 10)));
    reg2 = ~($(Wireexpr(10, 6)))
))

d = autodecl(c)

@test string(d) == """
reg reg1;
reg [9:0] reg2;"""