# getVoiceReport.praat
# Written by Eleanor Chodroff
# 6 Nov 2020

#################

# where is the directory w/ TextGrids and wavs located? make sure the TextGrids and wav files have the same name and are in this same directory
dir$ = "/Users/xxx/xxx/Phonological Trains data/wav/male/"


# where should I write the file?
outfile$ = "/Users/xxx/xxx/trains_voicereport_male.csv"


# hate csv files? fine, you can change that here
sep$ = ","

# minPitch = 50 for males, 100 for females
minPitch = 50

# maxPitch = 300 for males, 500 for females
maxPitch = 300
#################

# create header
appendFile: outfile$, "file", sep$, "vowel", sep$, "prec", sep$, "foll", sep$
appendFile: outfile$, "start", sep$, "end", sep$, "dur", sep$
appendFile: outfile$, "word", sep$
appendFile: outfile$, "localjitter", sep$, "localabsolute", sep$, "rap", sep$, "ppq5", sep$, "ddp", sep$
appendFile: outfile$, "meanPeriod", sep$, "sdPeriod", sep$
appendFile: outfile$, "localshimmer", sep$, "localdb", sep$, "apq3", sep$, "apq5", sep$, "apq11", sep$, "dda", sep$
appendFile: outfile$, "hnr", sep$, "sdHNR", sep$
appendFileLine: outfile$, "voiced", sep$, "nFrames", sep$, "percentVoiced"

# loop through individual TextGrid files within the language directory
Create Strings as file list: "files", dir$ + "*.wav"
nFiles = Get number of strings
for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".wav"
	Read from file: dir$ + basename$ + ".TextGrid"
	Read from file: dir$ + basename$ + ".wav"

	# convert wav files to point process and harmonic objects
	To PointProcess (periodic, cc): minPitch, maxPitch
	selectObject: "Sound " + basename$
	To Harmonicity (cc): 0.01, minPitch, 0.1, 1

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
			@getPointStuff
			@getHarmonicStuff
			@getPitchStuff
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

procedure getPointStuff
	selectObject: "PointProcess " + basename$
	localjitter = Get jitter (local): start, end, 0.0001, 0.02, 1.3
	localabsolute = Get jitter (local, absolute): start, end, 0.0001, 0.02, 1.3
	rap = Get jitter (rap): start, end, 0.0001, 0.02, 1.3
	ppq5 = Get jitter (ppq5): start, end, 0.0001, 0.02, 1.3
	ddp = Get jitter (ddp): start, end, 0.0001, 0.02, 1.3

	meanPeriod = Get mean period: start, end, 0.0001, 0.02, 1.3
	sdPeriod = Get stdev period: start, end, 0.0001, 0.02, 1.3

	selectObject: "Sound " + basename$
	plusObject: "PointProcess " + basename$
	localshimmer =  Get shimmer (local): start, end, 0.0001, 0.02, 1.3, 1.6
	localdb = Get shimmer (local_dB): start, end, 0.0001, 0.02, 1.3, 1.6
	apq3 = Get shimmer (apq3): start, end, 0.0001, 0.02, 1.3, 1.6
	apq5 = Get shimmer (apq5): start, end, 0.0001, 0.02, 1.3, 1.6
	apq11 =  Get shimmer (apq11): start, end, 0.0001, 0.02, 1.3, 1.6
	dda = Get shimmer (dda): start, end, 0.0001, 0.02, 1.3, 1.6

	appendFile: outfile$, localjitter, sep$, localabsolute, sep$, rap, sep$, ppq5, sep$, ddp, sep$
	appendFile: outfile$, meanPeriod, sep$, sdPeriod, sep$
	appendFile: outfile$, localshimmer, sep$, localdb, sep$, apq3, sep$, apq5, sep$, apq11, sep$, dda, sep$
endproc

procedure getHarmonicStuff
	selectObject: "Harmonicity " + basename$
	hnr = Get mean: start, end
	sdHNR = Get standard deviation: start, end

	appendFile: outfile$, hnr, sep$, sdHNR, sep$
endproc
	
procedure getPitchStuff
	selectObject: "Sound " + basename$
	Extract part: start, end, "rectangular", 1.0, "yes"
	if (end-start) < 0.06
		newMin = 100
	else
		newMin = minPitch
	endif
	To Pitch: 0, newMin, maxPitch
	voiced = Count voiced frames
	nFrames = Get number of frames
	percentVoiced = voiced/nFrames
	selectObject: "Sound " + basename$ + "_part"
	plusObject: "Pitch " + basename$ + "_part"
	Remove
	
	appendFile: outfile$, voiced, sep$, nFrames, sep$, percentVoiced
endproc