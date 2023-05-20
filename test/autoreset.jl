v = ifcontent(:(
    a <= m;
    c <= 10;
    if b1 
        b[x:0] <= n 
    else
        c <= p
        b[1] <= nn
    end
))

rr = autoreset(v, rst= @wireexpr ~resetn)

@test string(rr) == """
always_ff @( posedge CLK ) begin
    if ((~resetn)) begin
        a <= 0;
        b <= 0;
        c <= 0;
    end else begin
        a <= m;
        c <= 10;
        if (b1) begin
            b[x:0] <= n;
        end else begin
            c <= p;
            b[1] <= nn;
        end
    end
end"""

v = @always (
    if ~rst
        a <= 9
    else 
        a <= 10
    end
)

# detect reset with user-defined resetting signal
v = autoreset(v, rst = @wireexpr ~rst)
@test string(v) == """
always_ff @( posedge CLK ) begin
    if ((~rst)) begin
        a <= 9;
    end else begin
        a <= 10;
    end
end"""


fsm = FSM("myfsm", "uno", "dos", "tres")
transadd!(fsm, (@wireexpr b), "dos" => "tres")

vcase = fsmconv(Case, fsm)
v = Ifcontent(vcase)

rr = autoreset(v)

@test string(rr) == """
always_ff @( posedge CLK ) begin
    if (RST) begin
        myfsm <= 0;
    end else begin
        case (myfsm)
            uno: begin
                
            end
            dos: begin
                if (b) begin
                    myfsm <= tres;
                end
            end
            tres: begin
                
            end
        endcase
    end
end"""

c1 = @always (
    if (mrstate == MREADING) 
        debsig <= 1 
    end
)
@test string(autoreset(c1)) == """
always_ff @( posedge CLK ) begin
    if (RST) begin
        debsig <= 0;
    end else begin
        if ((mrstate == MREADING)) begin
            debsig <= 1;
        end
    end
end"""


# autoreset with 2d reg
a = @always(
    a <= a + 1
) 
d = @decls(
    @reg 32 a 10
)

m = Vmodule("t")
vpush!(m, a)
vpush!(m, d)

# m = autoreset(m, reg2d=Dict(["a"=>@wireexpr 10]))
m = autoreset(m)
@test string(m) == """
module t ();
    reg [31:0] a [9:0];

    always_ff @( posedge CLK ) begin
        if (RST) begin
            a[0] <= 0;
            a[1] <= 0;
            a[2] <= 0;
            a[3] <= 0;
            a[4] <= 0;
            a[5] <= 0;
            a[6] <= 0;
            a[7] <= 0;
            a[8] <= 0;
            a[9] <= 0;
        end else begin
            a <= (a + 1);
        end
    end
endmodule"""
