function verilatorTestbenchGen(io::IO, tplen::Integer, cycles::Integer)
    body = """
    module testbench (
        input CLK, RST
    );

    logic [63:0] counter;
    logic [$(tplen-1):0] tp;
    dut u0 (.*);

    always_ff @( posedge CLK ) begin
        if (RST) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
            if (counter > $cycles) begin
                \$display("%0$(tplen)b\\n", tp);
                \$finish;
            end
        end
    end

    endmodule
    """

    return write(io, body)
end
function verilatorTestbenchGen(fname::AbstractString, tplen, cycles)
    ret = open(fname, "w") do io
        verilatorTestbenchGen(io, tplen, cycles)
    end

    return ret
end

function verilatorCppGen(io::IO)
    body = """
    #include <iostream>
    #include <memory>
    #include <verilated.h>
    #include "Vtestbench.h"

    int main(int argc, char** argv)
    {
        const std::unique_ptr<Vtestbench> top{new Vtestbench()};

        top->CLK = 0;
        top->RST = 1;
        uint64_t count = 0;
        while (!Verilated::gotFinish())
        {
            count++;
            top->CLK = !top->CLK;

            if (!top->CLK)
            {
                if (count > 20)
                {
                    top->RST = 0;
                }
            }

            top->eval();
        }

        top->final();

        return 0;
    }
    """
    return write(io, body)
end
function verilatorCppGen(fname::AbstractString)
    return open(fname, "w") do io
        verilatorCppGen(io)
    end
end

function acceptableInVerilatorTest(v::Vector{Vmodule}, tplen)
    return acceptableInVerilatorTest(v[begin], tplen)
end
function acceptableInVerilatorTest(v::Vmodule, tplen::Integer)::Bool
    expectedname = "dut"
    expectedbitports = [
        (@oneport @in CLK),
        (@oneport @in RST),
    ]
    dutports = getports(v)
    dutportset = Set([i for i in dutports])

    if getname(v) != expectedname
        println("name of Vmodule should be 'dut', '$getname(v)' given.")
        return false
    end
    for p in expectedbitports
        if !(p in dutportset)
            println("port ", string(p), " does not exist in dut.")
            return false
        end
    end

    tpports = filter(x->getname(x)=="tp", dutportset)
    if length(tpports) == 0
        println("no port named tp found.")
        return false
    elseif length(tpports) > 1
        println("multiple ports named tp found.")
        return false
    else
        tpport = pop!(tpports)
        if getdirec(tpport) != pout
            println("tp should be an output port.")
            return false
        elseif !isequal(getwidth(tpport), @wireexpr $tplen)
            println("unexpected tp width, expected ", string(tplen), ", given ", string(getwidth(tpport)))
            return false
        end
    end

    if length(dutportset) != length(expectedbitports) + 1
        println("dutportset contains ports more than expected, ports are:")
        vshow(dutports)
        return false
    end

    return true
end


function parseVerilatorSimResult(parseresultbuf::IO, simoutput::IO, tplen)::Bool
    for line in eachline(simoutput)
        result = line == "1"^tplen
        if !result
            # println("simulation result failure, test points value: ", line)
            write(parseresultbuf, "simulation result failure, test points value: ", line, "\n")
        end
        return result
    end

    return false
end
function parseVerilatorSimResult(simoutput::IO, tplen)::Bool
    return parseVerilatorSimResult(stdout, simoutput, tplen)
end

struct VerilatorOption
    wall::Bool
    disabledWarning::Vector{String}
end
function (cls::VerilatorOption)()
    disabled = [string("-Wno-", s) for s in cls.disabledWarning]
    if cls.wall
        disabled = ["-Wall"; disabled]
    end

    return disabled
end

VerilatorOption(wno::Vector{String})= VerilatorOption(true, wno)
const DEFAULT_VERILATOR_OPTION = VerilatorOption(true, String[])

"""
    verilatorSimrun(resultbuf::IO, dut::V, tplen::Integer, cycles::Integer; option::VerilatorOption=DEFAULT_VERILATOR_OPTION) where {V <: Union{Vmodule, Vector{Vmodule}}}

Run simulation using Verilator.

`dut` must pass `acceptableInVerilatorTest`.
Simulation is run for `cycles` cycles, for `tplen`-many test points.
"""
function verilatorSimrun(resultbuf::IO, dut::V, tplen::Integer, cycles::Integer; option::VerilatorOption=DEFAULT_VERILATOR_OPTION) where {V <: Union{Vmodule, Vector{Vmodule}}}
    @assert acceptableInVerilatorTest(dut, tplen)

    dirnow = pwd()

    try
        vworkdir = "tmpverilatorsim"
        if isdir(vworkdir)
            println("$vworkdir already exists in $dirnow, files in the directory would be lost")
            rm(vworkdir, force=true, recursive=true)
        end

        mkdir(vworkdir)
        cd(vworkdir)
        # get vmodule and generate vmodule, testbench file

        tbfile = "testbench.sv"
        tbcpp = "testbench.cpp"
        dutfile = "dut.sv"
        verilatorTestbenchGen(tbfile, tplen, cycles)
        verilatorCppGen(tbcpp)
        open(dutfile, "w") do iodut
            vexport(iodut, dut)
        end

        compilecmd = `verilator --cc $(option()) $tbfile $dutfile --exe $tbcpp`
        println("compile command: ", compilecmd)
        run(compilecmd)

        cd("obj_dir")
        bufignore = IOBuffer()
        makecmd = `make -f Vtestbench.mk`
        # prevent log for make from being displayed in the terminal where julia is running
        run(pipeline(makecmd, stdout=bufignore, stderr=bufignore))

        simoutbuf = IOBuffer()
        simruncmd = `./Vtestbench`
        # error message is returned to terminal
        run(pipeline(simruncmd, stdout=simoutbuf))
        seek(simoutbuf, 0)

        cd(dirnow)
        rm(vworkdir, force=true, recursive=true)
        
        return parseVerilatorSimResult(resultbuf, simoutbuf, tplen)
    catch
        cd(dirnow)
        rethrow()
    end
end
function verilatorSimrun(dut, tplen, cycles; option::VerilatorOption=DEFAULT_VERILATOR_OPTION)
    return verilatorSimrun(stdout, dut, tplen, cycles, option=option)
end