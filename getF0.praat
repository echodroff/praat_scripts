# getF0.praat
# Get f0 at predefined points in the vowel: quartiles and deciles
# Get information about the file, vowel, and duration
# Written by Eleanor Chodroff
# 31 Oct 2020


#################

# where is the directory w/ TextGrids and wavs located? make sure the TextGrids and wav files have the same name and are in this same directory
dir$ = "/Users/eleanorchodroff/Dropbox/Phonological Trains data/wav/male/"
#dir$ = "/Users/eleanorchodroff/Desktop/input/"


# where should I write the file with the formants?
outfile$ = "/Users/eleanorchodroff/Desktop/trains_f0_male50-300.csv"


# hate csv files? fine, you can change that here
sep$ = ","

# female 100-500, male 50-300
minf0 = 50 
maxf0 = 300
#################


# create header
appendFile: outfile$, "file", sep$, "vowel", sep$, "prec", sep$, "foll", sep$
appendFile: outfile$, "start", sep$, "end", sep$, "dur", sep$
appendFile: outfile$, "word", sep$
appendFile: outfile$, "f0_max", sep$, "f0_max_time", sep$, "f0_min", sep$, "f0_min_time", sep$
appendFile: outfile$, "f0_start", sep$, "f0_q1", sep$, "f0_mid", sep$, "f0_q3", sep$, "f0_end", sep$
appendFile: outfile$, "f0_t0", sep$, "f0_t1", sep$, "f0_t2", sep$, "f0_t3", sep$, "f0_t4", sep$, "f0_t5", sep$, "f0_t6", sep$, "f0_t7", sep$, "f0_t8", sep$, "f0_t9", sep$, "f0_t10", newline$


# loop through individual TextGrid files within the language directory
Create Strings as file list: "files", dir$ + "*.wav"
nFiles = Get number of strings
for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".wav"
	Read from file: dir$ + basename$ + ".TextGrid"
	Read from file: dir$ + basename$ + ".wav"

	# convert wav files to pitch objects
	To Pitch: 0, minf0, maxf0

	# loop through TextGrid to find vowels
	selectObject: "TextGrid " + basename$
	nInt = Get number of intervals: 2
	for j from 1 to nInt
		selectObject: "TextGrid " + basename$
		label$ = Get label of interval: 2, j
		# do stuff if label is a vowel
		if index_regex(label$, "^[AEIOULRWYMN]")
			@getLabels
			@getTime
			@getWord
			@getF0
			appendFile: outfile$, newline$
		endif
	endfor

	# do some clean up
	select all
	minusObject: "Strings files"
	Remove
endfor 


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
	appendFile: outfile$, basename$, sep$, label$, sep$, prec$, sep$, foll$, sep$
endproc


procedure getTime
	start = Get start time of interval: 2, j
	end = Get end time of interval: 2, j
	dur = end - start
	appendFile: outfile$, start, sep$, end, sep$, dur, sep$ 
endproc	

procedure getWord
	wordInt = Get interval at time: 1, start+0.01
	word$ = Get label of interval: 1, wordInt
	appendFile: outfile$, word$, sep$
endproc


procedure getF0
	selectObject: "Pitch " + basename$

	# get max and min f0
	f0_max = Get maximum: start, end, "Hertz", "Parabolic"
	f0_max_time = Get time of maximum: start, end, "Hertz", "Parabolic"
	f0_min = Get minimum: start, end, "Hertz", "Parabolic"
	f0_min_time = Get time of minimum: start, end, "Hertz", "Parabolic" 

	appendFile: outfile$, f0_max, sep$, f0_max_time, sep$, f0_min, sep$, f0_min_time, sep$

	# get f0 at each quartile (including start and end)
	for f from 0 to 4
		f_time4 = Get value at time: start + f*(dur/4), "Hertz", "Linear"
		appendFile: outfile$, f_time4, sep$
	endfor

	# get formats at each decile 
	for t from 0 to 10
		f_timex = Get value at time: start + t*(dur/10), "Hertz", "Linear"
		if t = 10
			appendFile: outfile$, f_timex
		else
			appendFile: outfile$, f_timex, sep$
		endif
	endfor

endproc
						