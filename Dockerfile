FROM julia:1.7.3-bullseye
# mount current directory
RUN julia -e 'using Pkg; Pkg.add(PackageSpec(url="https://github.com/t-f-marfil/VerilogWriter.jl"))'
CMD /bin/bash