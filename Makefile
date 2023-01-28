run:
	tic80 --skip --fs=`pwd` pmaze.tic.lua

edit:
	tic80 --skip --fs=`pwd` --cmd="load pmaze.tic.lua & edit"

export:
	tic80 --skip --cli --fs=`pwd` --cmd="load pmaze.tic.lua & export html export alone=1 & quit"
	unzip -f export.zip
