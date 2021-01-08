# intraUtterancePauseDuration.praat
# Get pause durations *within* an utterance
# (intra-utterance pause duration)
# Written by Eleanor Chodroff
# Nov 16 2020

#################

dir$ = "/Users/xxx/xxx/Phonological Trains data/models/rhythm_extracts/"
Create Strings as file list: "files", dir$ + "*.TextGrid"
nFiles = Get number of strings

sep$ = ","
outfile$ = "/Users/xxx/xxx/models_intraUttPauseDuration.csv"

for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".TextGrid"
	Read from file: dir$ + filename$
	nInt = Get number of intervals: 2
	#counter = 0
	for j from 2 to nInt - 1
		label$ = Get label of interval: 2, j
		if label$ == "sp"
			start = Get start time of interval: 2, j
			end = Get end time of interval: 2, j
			dur = end - start
			appendFileLine: outfile$, basename$, sep$, label$, sep$, start, sep$, end, sep$, dur
		endif
	endfor
	select all
	minusObject: "Strings files"
	Remove
endfor
			