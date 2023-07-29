@test isequal(Wireexpr("s"), Wireexpr("s"))
@test !isequal(Wireexpr("s"), Wireexpr("ss"))