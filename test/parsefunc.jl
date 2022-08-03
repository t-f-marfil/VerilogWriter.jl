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