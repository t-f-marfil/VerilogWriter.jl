# parameters

# ports 
## width with parameters
x = @ports (
    @in z;
    @out @reg z;
    @in 5C z;
    @out @reg (A+B)<<2 z;

    @out x,y;
    @in @wire x, y;
    @in 5C x, y;
    @out @logic (A+B)<<2 x, y
)
@test string(x) == """
(
    input z,
    output reg z,
    input [(5 * C)-1:0] z,
    output reg [((A + B) << 2)-1:0] z,
    output x,
    output y,
    input x,
    input y,
    input [(5 * C)-1:0] x,
    input [(5 * C)-1:0] y,
    output logic [((A + B) << 2)-1:0] x,
    output logic [((A + B) << 2)-1:0] y
);"""

# localparams 
a = @parameters (x = 10; z = 2)
b = @onelocalparam a = 111
x = @localparams (
    y = 5; $([Onelocalparam.(a)..., b]...)
)

@test string(x) == """
localparam y = 5;
localparam x = 10;
localparam z = 2;
localparam a = 111;"""

# wireexprs
x = @wireexpr a[b+c]
@test string(x) == "a[(b + c)]"

# decls 

## wire width with parameters
x = @decls (
    @logic x;
    @reg A+B m;
    @wire p, q, r;
    @reg (C*D) << 2 s,t,u
)
@test string(x) == """
logic x;
reg [(A + B)-1:0] m;
wire p;
wire q;
wire r;
reg [((C * D) << 2)-1:0] s;
reg [((C * D) << 2)-1:0] t;
reg [((C * D) << 2)-1:0] u;"""

## interpolation
w1 = @wireexpr A1+A2
w2 = @wireexpr B1
x = @decls (
    @reg $w1 a $w2;
    @logic $w1 + 2 b, c
)
@test string(x) == """
reg [(A1 + A2)-1:0] a [B1-1:0];
logic [((A1 + A2) + 2)-1:0] b;
logic [((A1 + A2) + 2)-1:0] c;"""

# ralways
w = @wireexpr x << 2
x = @ralways (
    a <= $w;
    if b
        a <= $w + 3
    elseif c
        a <= $w + 4
    end
)
@test string(x) == """
always_unknown begin
    a <= (x << 2);
    if (b) begin
        a <= ((x << 2) + 3);
    end else if (c) begin
        a <= ((x << 2) + 4);
    end
end"""