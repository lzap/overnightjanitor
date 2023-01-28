run:
	tic80 --skip --fs=`pwd` onjanitor.tic.lua

edit:
	tic80 --skip --fs=`pwd` --cmd="load onjanitor.tic.lua & edit"

export:
	tic80 --skip --cli --fs=`pwd` --cmd="load onjanitor.tic.lua & export html export alone=1 & quit"
	unzip -f -o export.zip
