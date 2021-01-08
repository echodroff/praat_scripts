# interUttPauseDuration.praat
# Get pause duration *between* utterances 
# (inter-utterance pause duration)
# Written by Eleanor Chodroff
# Nov 16 2020


#################

dir$ = "/Users/xxx/xxx/Phonological Trains data/models/male/"
Create Strings as file list: "files", dir$ + "*.TextGrid"
nFiles = Get number of strings

outfile$ = "/Users/xxx/xxx/models_interUttPauseDuration.csv"
sep$ = ","

for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".TextGrid"
	Read from file: dir$ + filename$
	nInt = Get number of intervals: 1
	for j from 2 to nInt-1
		selectObject: "TextGrid " + basename$
		label$ = Get label of interval: 1, j
		if label$ == ""
			start = Get start time of interval: 1, j
			end = Get end time of interval: 1, j
			dur = end - start
			appendFileLine: outfile$, basename$, sep$, start, sep$, end, sep$, dur
		endif
	endfor
	select all
	minusObject: "Strings files"
	Remove
endfor
