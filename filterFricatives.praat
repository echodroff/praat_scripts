dir$ = "/Users/eleanorchodroff/Dropbox/Phonological Trains data/models/fric_extracts300/"
Create Strings as file list: "files", dir$ + "*.wav"
nFiles = Get number of strings

for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".wav"
	Read from file: dir$ + filename$
	Filter (pass Hann band): 300, 0, 100
	nowarn Save as WAV file: dir$ + filename$
	select all
	minusObject: "Strings files"
	Remove
endfor