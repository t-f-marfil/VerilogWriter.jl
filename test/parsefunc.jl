# parameters
a = @parameters (x = 10; z = 2)
b = @onelocalparam a = 111
x = localparams(:(
    y = 5; $([a, b]...)
))

@test string(x) == """
localparam y = 5;
localparam x = 10;
localparam z = 2;
localparam a = 111;"""

a = @localparams (x = 1; z = 20)
b = @oneparam a = 1111
x = localparams(:(
    y = 50; $([a, b]...)
))

@test string(x) == """
localparam y = 50;
localparam x = 1;
localparam z = 20;
localparam a = 1111;"""


# ports 

# interpolation 
# vector of ports
x = ports(:(
    $([
        ports(:(@in 6 x, z)), 
        ports(:(@in y))
    ]...)
))
@test string(x) == """
(
    input [5:0] x,
    input [5:0] z,
    input y
);
"""

# vector of portoneline return vals
x = ports(:(
    $([
        portoneline(:(@in 6 x, z)), 
        portoneline(:(@in y))
    ]...)
))
@test string(x) == """
(
    input [5:0] x,
    input [5:0] z,
    input y
);
"""

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
);
"""

# localparams 
a = @localparams (x = 10; z = 2)
b = @oneparam a = 111
x = localparams(:(
    y = 5; $([a, b]...)
))

@test string(x) == """
localparam y = 5;
localparam x = 10;
localparam z = 2;
localparam a = 111;"""

a = @parameters (x = 101; z = 22)
b = @onelocalparam a = 1110
x = localparams(:(
    y = 55; $([a, b]...)
))

@test string(x) == """
localparam y = 55;
localparam x = 101;
localparam z = 22;
localparam a = 1110;"""


# decls 
x = decls(:(
    $(@decloneline @reg 8 x)
))
@test string(x) == "reg [7:0] x;"

x = decls(:(
    $([
        (@decloneline @logic a, b),
        (@decloneline @reg 10 c)
    ]...)
))
@test string(x) == """
logic a;
logic b;
reg [9:0] c;"""

x = decls(:(
    $(@decls (
        @logic a;
        @wire 10 b, c
    ))
))
@test string(x) == """
logic a;
wire [9:0] b;
wire [9:0] c;"""

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

# ralways
# interpolation
x = ralways(:(
    x = y;
    $([
        (@oneblock a = b),
        (@oneblock c = d)
    ]...)
))
@test string(x) == """
always_unknown begin
    x = y;
    a = b;
    c = d;
end"""

x = ralways(:(
    $([
        (@oneblock a = b),
        (@oneblock c = d)
    ]...)
))
@test string(x) == """
always_unknown begin
    a = b;
    c = d;
end"""


x = ralways(:(
    $([
        (@oneblock (
            if b1 
                x <= y 
            else 
                x <= z 
            end
        )),
        (@oneblock (
            if b2 
                a <= b
                c <= d
            elseif b3 
                a <= bbb 
            end
        ))
    ]...)
))
@test string(x) == """
always_unknown begin
    if (b1) begin
        x <= y;
    end else begin
        x <= z;
    end
    if (b2) begin
        a <= b;
        c <= d;
    end else if (b3) begin
        a <= bbb;
    end
end"""