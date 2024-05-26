function findVerilator()
    if !Sys.islinux()
        return
    end

    cmd = `verilator --version`
    buf = IOBuffer()
    try
        ret = run(pipeline(cmd, stdout=buf))
        @test ret.exitcode == 0
        println(String(take!(buf)) |> rstrip)
    catch
        println("verilator not found")
        rethrow()
    end
end

findVerilator()