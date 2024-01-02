function getname(x::Midmodule)
    getname(x.vmod)
end
function getname(x::Midport)
    string(getname(getmmod(x)), getpid(x) == defaultMidPid ? "" : string("_port", getpid(x)))
end

function getmmod(x::Midport)
    x.mmod
end

function getvmod(x::Midmodule)
    x.vmod
end

function getpid(x::Midport)
    x.pid
end
function getpid(x::Layerconn)
    x.pid
end