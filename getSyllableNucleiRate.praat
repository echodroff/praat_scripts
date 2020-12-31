dir$ = "/Users/eleanorchodroff/Dropbox/Phonological Trains data/wav/rhythm_extracts/"

Create Strings as file list: "files", dir$ + "*syllables.TextGrid"
nFiles = Get number of strings

outfile$ = "/Users/eleanorchodroff/Desktop/syllableNucleiRate.csv"
appendFileLine: outfile$, "file,nSyll,dur,rate"

for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".syllables.TextGrid"
	Read from file: dir$ + filename$
	nSyll = Get number of points: 1
	dur = Get total duration
	rate = nSyll / dur
	appendFileLine: outfile$, basename$, ",", nSyll, ",", dur, ",", rate
	select all
	minusObject: "Strings files"
	Remove
endfor
