# inference on shift operator
# e.g. in `w = x << y` width of y is unknown
c = ifcontent(:(
    reg1 = $(Wireexpr(32, 5)) << reg2;
    reg2 = $(Wireexpr(10, 5))
))

d, _ = autodecl(c)

@test string(d) == """
reg [31:0] reg1;
reg [9:0] reg2;"""

# Bitwise and reduction unary operator
c = ifcontent(:(
    reg1 = ^($(Wireexpr(32, 10)));
    reg2 = ~($(Wireexpr(10, 6)))
))

d, _ = autodecl(c)

@test string(d) == """
reg reg1;
reg [9:0] reg2;"""

# parameter width
env = Vmodenv(
    @decls (
        @reg A+B reg1;
        @reg A+B reg2
    )
)
d, _ = autodecl(
    (@ifcontent (
        reg1 <= reg2;
        reg3 <= reg2;
        reg4 <= reg1;
        if reg1[1]
            reg4 <= reg3
        end
    )), 
    env
)
@test string(d) == """
reg [(A + B)-1:0] reg3;
reg [(A + B)-1:0] reg4;"""

# inference for declonly
c = always(:(
    if &(a & c) 
        a <= c[1:0]
    end
))
# d, nenv = autodecl(c)
# @test string(d) == """
# """

# error message 
c = always(:(
    a <= $(Wireexpr(32, 10));
    a <= $(Wireexpr(1, 0))
))

@test (@strerror autodecl(c)) == """
width inference failure in evaluating a <=> 1'd0.
width discrepancy between 32 and 1."""
