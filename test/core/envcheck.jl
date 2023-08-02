# verilator
if Sys.islinux()
    cmd = `verilator --version`
    buf = IOBuffer()
    try
        ret = run(pipeline(cmd, stdout=buf))
        @test ret.exitcode == 0
        println(String(take!(buf)))
    catch e
        println("verilator not found")
        @test false
    end
end