dir$ = "/Users/eleanorchodroff/Dropbox/Phonological Trains data/wav/"
Create Strings as file list: "files", dir$ + "*utt.TextGrid"
nFiles = Get number of strings

for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - "_utt.TextGrid"
	Read from file: dir$ + basename$ + ".TextGrid"
	Read from file: dir$ + filename$
	selectObject: "TextGrid " + basename$
	plusObject: "TextGrid " + basename$ + "_utt"
	Merge
	Save as text file: dir$ + basename$ + "_full.TextGrid"
	select all
	minusObject: "Strings files"
	Remove
endfor