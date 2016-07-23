mcc -d bin/ -m dicefg.m -N -p stats -p optim -a ./* -a ./lib/jsonlab/* -a ./algorithms/* -a ./lib/kpc-toolbox/aph/* -a ./lib/kpc-toolbox/basic/* -a ./lib/kpc-toolbox/mc/* -a ./lib/kpc-toolbox/map/* -a ./lib/kpc-toolbox/trace/* -a ./lib/kpc-toolbox/contrib/* -a ./lib/kpc-toolbox/kpcfit/* -a ./lib/kpc-toolbox/mmpp/*
if isunix
system('zip bin/dicefg-linux.zip bin/dicefg bin/run_dicefg.sh') 
end
