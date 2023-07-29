# mounting current directory recommended
FROM julia:1.7.3-bullseye
RUN julia -e 'using Pkg; Pkg.add(PackageSpec(url="https://github.com/t-f-marfil/VerilogWriter.jl"))'
CMD /bin/bash