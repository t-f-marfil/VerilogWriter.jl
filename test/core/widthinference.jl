# inference on shift operator
# e.g. in `w = x << y`, width of y is independent on x
c = @always (
    reg1 = $(Wireexpr(32, 5)) << reg2;
    reg2 = $(Wireexpr(10, 5))
)

_, (d, _) = autodeclCore(c)

@test string(d) == """
logic [31:0] reg1;
logic [9:0] reg2;"""

# Bitwise and reduction unary operator
c = @always (
    reg1 = ^($(Wireexpr(32, 10)));
    reg2 = ~($(Wireexpr(10, 6)))
)

_, (d, _) = autodeclCore(c)

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
_, (d, _) = autodeclCore(
    (@always (
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
logic [(A + B)-1:0] reg4;
logic [(A + B)-1:0] reg3;"""

# recursive check for '==' and reductions
c = @always (
    if |(a & b) 
        a <= &(b == c)
    end
)
_, (d, _) = autodeclCore(c)
@test string(d) == """
logic c;
logic b;
logic a;"""

# error message 
c = @always (
    a <= $(Wireexpr(32, 10));
    a <= $(Wireexpr(1, 0))
)

# @test (@strerror autodeclCore(c)) == """
# width inference failure in evaluating a <=> 1'd0.
# width discrepancy between 32 and 1."""
@test_throws WireWidthConflict autodeclCore(c)

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

_, (dc, _) = autodeclCore(c, Vmodenv(d))

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

# @test (@strerror autodeclCore(c, Vmodenv(d))) == """
# 2d reg b is sliced at [(W << 2):0]."""
@test_throws SliceOnTwoDemensionalLogic autodeclCore(c, Vmodenv(d))

# empty equality lists
alempty = @always (
    if 1
        a <= $(Wireexpr(1, 1))
    end
)
_, dempty = autodecl(alempty)
@test string(dempty) == "logic a;"

# inference on ipselm
_, ret = autodecl(@always (a = b[A-:B]))
@test string(ret) == """
logic [unknown] B;
logic [unknown] A;
logic [unknown] b;
logic [B-1:0] a;"""


# Inference accross multiple modules
let 
    v0 = Vmodule("mod0")
    v1 = Vmodule("mod1")
    v2  =Vmodule("mod2")
    v3 = Vmodule("mod3")
    inst1 = Vmodinst(
        "mod1",
        "inst1",
        ["p1" => @wireexpr w1]
    )
    inst2 = Vmodinst(
        "mod2",
        "inst2",
        ["p2" => @wireexpr p1]
    )
    inst3 = Vmodinst(
        "mod3",
        "inst3",
        ["p3" => @wireexpr p2]
    )

    vpush!(v0, inst1)
    vpush!(v1, inst2)
    vpush!(v2, inst3)
    vpush!(v3, @ports @out 3 p3)
    vpush!(v2, @ports @out -1 p2)
    vpush!(v1, @ports @out -1 p1)

    vmods = [v2, v0, v1, v3]
    ss, vmods = autodeclVmodlist(vmods)
    v2, v0, v1, v3 = vmods
    
    @test all(widthInferenceCompleted, ss)
    
    @test string(v2.ports) == """
    (
        output [2:0] p2
    );"""

    @test string(v1.ports) == """
    (
        output [2:0] p1
    );"""

    @test string(v0.decls) == "logic [2:0] w1;"
end