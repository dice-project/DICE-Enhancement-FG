compile_dicefg
cd ..
if isunix
    system('zip bin/dicefg-linux-x86_64.zip bin/dicefg bin/run_dicefg.sh')
elseif ispc
    system('zip .\bin\dicefg-windows.zip bin\dicefg.exe')    
end
cd bin/
commit_dicefg

