# evaluate parameters.
p = @parameters (
    a = 10;
    b = a << 2;
    c = (a + 3) * b;
    d = e
)
lp = @localparams (
    e = 32 / 8;
    # e = 4 << 2;
    f = a - 2e
)
ans = paramsolve(p, lp)

@test dictstr(ans) == """
a => 10
b => 40
c => 520
d => 4
e => 4
f => 2"""

# evaluate one parameter(::Wireexpr) under `ans`.
@test paramcalc((@wireexpr c / f + 3), ans) == 263

# unsolvable 
p = @parameters (
    a = b;
)
lp = @localparams (
    b = a + 3
)

@test (@strerror paramsolve(p, lp)) == """
Looking at 'b',
Mutual recursion detected in solving parameters."""
