compile_dicefg
cd ..
if isunix
system('zip bin/dicefg-linux-x86_64.zip bin/dicefg bin/run_dicefg.sh') 
system('svn commit --non-interactive -m ''$commit_msg''') 
end
cd bin/
