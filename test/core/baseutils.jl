# Decls equality

d1 = @decls (@logic 8 x)
d2 = @decls (@logic 8 x)
d3 = @decls (@reg 8 x)
d4 = @decls (@wire 8 x)
d5 = @decls (@logic 7 x)
d6 = @decls (@logic 8 y)

@test d1 == d1
@test d1 == d2
for dtarget in (d3,d4,d5,d6)
    @test d1 != dtarget
end

d1 = @decls (
    @logic 10 a;
    @logic 21 b;
)
d2 = @decls (
    @logic 21 b;
    @logic 10 a;
)
d3 = @decls (
    @logic 10 a;
)
d4 = @decls (
    @logic 10 a;
    @logic 21 b;
    @logic 3 c;
)

@test d1 == d2
@test d1 != d3
@test d1 != d4
