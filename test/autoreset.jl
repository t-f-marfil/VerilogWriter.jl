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
    if (~resetn) begin
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

