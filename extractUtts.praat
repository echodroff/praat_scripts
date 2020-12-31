dir$ = "/Users/eleanorchodroff/Dropbox/Phonological Trains data/models/"
Create Strings as file list: "files", dir$ + "*.wav"
nFiles = Get number of strings

outdir$ = dir$ + "rhythm_extracts/"

for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".wav"
	Read from file: dir$ + filename$
	Read from file: dir$ + basename$ + ".TextGrid"
	nInt = Get number of intervals: 3
	for j from 1 to nInt
		selectObject: "TextGrid " + basename$
		label$ = Get label of interval: 3, j
		if label$ != ""
			start = Get start time of interval: 3, j
			end = Get end time of interval: 3, j
			Extract part: start, end, "no"
			Save as text file: outdir$ + basename$ + "_" + string$(j) + ".TextGrid"
			Remove
			selectObject: "Sound " + basename$
			Extract part: start, end, "rectangular", 1.0, "no"
			Save as WAV file: outdir$ + basename$ + "_" + string$(j) + ".wav"
			Remove
		endif
	endfor
	select all
	minusObject: "Strings files"
	Remove
endfor
		