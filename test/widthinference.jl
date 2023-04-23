# inference on shift operator
# e.g. in `w = x << y` width of y is unknown
c = ifcontent(:(
    reg1 = $(Wireexpr(32, 5)) << reg2;
    reg2 = $(Wireexpr(10, 5))
))

d, _ = autodecl_core(c)

@test string(d) == """
logic [31:0] reg1;
logic [9:0] reg2;"""

# Bitwise and reduction unary operator
c = ifcontent(:(
    reg1 = ^($(Wireexpr(32, 10)));
    reg2 = ~($(Wireexpr(10, 6)))
))

d, _ = autodecl_core(c)

@test string(d) == """
logic reg1;
logic [9:0] reg2;"""

# parameter width
env = Vmodenv(
    @decls (
        @reg A+B reg1;
        @reg A+B reg2
    )
)
d, _ = autodecl_core(
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
logic [(A + B)-1:0] reg3;
logic [(A + B)-1:0] reg4;"""

# recursive check for '==' and reductions
c = always(:(
    if |(a & b) 
        a <= &(b == c)
    end
))
d, nenv = autodecl_core(c)
@test string(d) == """
logic a;
logic b;
logic c;"""

# error message 
c = always(:(
    a <= $(Wireexpr(32, 10));
    a <= $(Wireexpr(1, 0))
))

@test (@strerror autodecl_core(c)) == """
width inference failure in evaluating a <=> 1'd0.
width discrepancy between 32 and 1."""

# 2d reg 
d = @decls (
    @wire 10 a;
    @reg 10 b 1024
)

c = @always (
    if &(b[1])
        c <= a;
        a <= b[1]
    end
)

dc, _ = autodecl_core(c, Vmodenv(d))

@test string(dc) == """
logic [9:0] c;"""

# 2d reg error message
d = @decls (
    @wire 10 a;
    @reg 10 b 1024
)

c = @always (
    if &(b[1])
        c <= a;
        a <= b[W<<2:0]
    end
)

@test (@strerror autodecl_core(c, Vmodenv(d))) == """
2d reg b is sliced at [(W << 2):0]."""