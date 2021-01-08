# Create CV segment and CV interval tiers for input to Dellwo's duration analyser 0.4 script
# Written by E. Chodroff
# 19 July 2020

# input: MFA TextGrid (tier 1 = word/utt, tier 2 = phone); 
# it can have additional tiers, but they will be deleted
# output: MFA TextGrid with cv segment and cv interval tiers (tier 3 = cv segments, tier 4 = cv intervals)
# create cv segment tier from phone tier
# create cv interval tier from cv segment tier
# "peak tier" referred to in Dellwo et al. 2015 is the same as the cv interval tier 
# (Dellwo script automatically locates v intervals and takes the peak)
# "Inter-peak intervals were defined as the interval 
# between the amplitude maximum in the amplitude envelope of a vocalic 
# interval (as the nucleus of the syllable) and the amplitude maximum 
# in the amplitude envelope of the following vocalic interval, 
# hence, this method excluded syllabic consonants" (Dellwo et al. 2015)


#################
### CHANGE ME ###
#################

dir$ = "/Users/xxx/xxx/Phonological Trains data/models/rhythm_extracts/"

###

Create Strings as file list: "files", dir$ + "*.TextGrid"
nFiles = Get number of strings
### Loop through files

for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".TextGrid"
	#Read from file: dir$ + basename$ + ".wav"
	Read from file: dir$ + basename$ + ".TextGrid"

	### Create cv segments tier (turn each segment into either a "c", "v" or "sil" label)
	# Dellwo script requires lowercase c and v
	nTiers = Get number of tiers
	while nTiers > 2
		Remove tier: nTiers
		nTiers = Get number of tiers
	endwhile

	Duplicate tier: 2, 3, "CVsegments"

	nInt = Get number of intervals: 3
	for j from 1 to nInt
		selectObject: "TextGrid " + basename$
		label$ = Get label of interval: 3, j

		if index_regex(label$, "^[AEIOU]")
			Set interval text: 3, j, "v"
		
		elsif index_regex(label$, "sp")
			Set interval text: 3, j, "sil"

		elsif label$ == ""
			Set interval text: 3, j, "sil"

		else
			Set interval text: 3, j, "c"
		endif
	endfor

	### Create CV interval tier (merge consecutive like-labeled segments into a single interval)

	Duplicate tier: 3, 4, "CVintervals"

	nInt = Get number of intervals: 4
	for k from 1 to nInt-1
		selectObject: "TextGrid " + basename$
		label1$ = Get label of interval: 4, k
		label2$ = Get label of interval: 4, k+1

		if label1$ == label2$ & label2$ != "sil"
			Remove right boundary: 4, k
			Set interval text: 4, k, label1$
		endif

		# is there a third segment in a row? if so, merge again

		label2$ = Get label of interval: 4, k+1
		if label1$ == label2$
			Remove right boundary: 4, k
			Set interval text: 4, k, label1$
		endif

		# hopefully there aren't more than three
		# if there are more than 3 cs or 3 vs in a row, we'll just have to merge manually

		# update interval count on the tier
		nInt = Get number of intervals: 4

	endfor
	selectObject: "TextGrid " + basename$
	Save as text file: dir$ + basename$ + ".TextGrid"
	select all
	minusObject: "Strings files"
	Remove
endfor

	