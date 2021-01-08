# extractFricatives.praat
# Extract fricatives
# Get information about the file, duration, preceding and following phones
# Written by Eleanor Chodroff
# 2 December 2019

# make sure the TextGrids and wav files have the same name
###################
# where are all the languageID folders located?
dir$ = "/Users/xxx/xxx/Phonological Trains data/models/"

# where should I write the file with the preliminary information?
outfile$ = dir$ + "trains_models_fricInfo.csv"
sep$ = ","
@createHeader

# where should I save the sibilant extracts?
outdir$ = dir$ + "fric_extracts/"

###################

Create Strings as file list: "files", dir$ + "*.wav"
nFiles = Get number of strings
for i from 1 to nFiles
	@processFile
endfor

procedure createHeader 
	appendFile: outfile$, "file", sep$, "sib", sep$, "prec", sep$, "foll", sep$, "trial", sep$
	appendFile: outfile$, "start", sep$, "end", sep$, "dur", newline$
endproc

procedure processFile 
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".wav"
	Read from file: dir$ + basename$ + ".TextGrid"
	Read from file: dir$ + basename$ + ".wav"

	# loop through TextGrid to find sibilants
	selectObject: "TextGrid " + basename$
	nInt = Get number of intervals: 2
	for j from 1 to nInt
		selectObject: "TextGrid " + basename$
		label$ = Get label of interval: 2, j
		# do stuff if label is a fricative and not if a silence
		if index_regex(label$, "^[SZFV]|^[TD]H") & !index_regex(label$, "ssil|sil")
			@getLabels
			@getTime
			@extractSibilant
		endif
	endfor

	#pauseScript: "done one file"
	# do some clean up
	select all
	minusObject: "Strings files"
	Remove
endproc

procedure getLabels
	if j > 1
		prec$ = Get label of interval: 2, j-1
	else
		prec$ = "NA"
	endif
	if j < nInt
		foll$ = Get label of interval: 2, j+1
	else
		foll$ = "NA"
	endif
	appendFile: outfile$, basename$, sep$, label$, sep$, prec$, sep$, foll$, sep$, string$(j), sep$
endproc

procedure getTime
	start = Get start time of interval: 2, j
	end = Get end time of interval: 2, j
	dur = end - start
	appendFile: outfile$, start, sep$, end, sep$, dur, newline$
endproc	

procedure extractSibilant
	selectObject: "Sound " + basename$
	Extract part: start, end, "rectangular", 1.0, "no"
	Save as WAV file: outdir$ + basename$ + "_" + label$ + "_" + string$(j) + ".wav"
	Remove
endproc
	
