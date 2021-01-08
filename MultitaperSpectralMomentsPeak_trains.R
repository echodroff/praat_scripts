# Multitaper Spectral Analysis on Sound Segments
# Created by Colin Wilson and Eleanor Chodroff
# 2014, 2016
# Last updated by Eleanor Chodroff: Dec 2020

# This script reads in a series of sound extracts (set up here for sibilant extracts) and takes the
# following measures over the middle 20 ms of the extract (.wav) using a multitaper spectrum:
# spectral peak,
# COG (M1), spectral variance (M2), skewness (M3), kurtosis (M4)

# The analysis interval is by default set to the middle 20 ms but this can be modified to any proportional or durational width and centered over the beginning, middle, or end of the fricative

# For each directory of sound extracts, an output file is created with the above measures called DIRECTORYsibilants.csv

# For any further use of this particular script, PLEASE CITE:
# Chodroff, E., & Wilson, C. (2014). Burst spectrum as a cue for the stop voicing contrast in American English. The Journal of the Acoustical Society of America, 136(5), 2762-2772.

# ASSUMPTIONS OF THIS SCRIPT:
# - there is a directory with sibilant extracts with .wav extensions (mydir)

#################
### CHANGE ME ###
#################
mydir <- '/Desktop/trains/extracts_300/' # main directory with sub-folders of sound extracts
outdir <- '/Desktop/trains/' # output directory for text file
SAMPLE_RATE <- 16000 # sampling rate of extracts

NW_TIME_BANDWIDTH <- 4 # time-bandwidth parameter for multitaper spectrum (nw)
K_TAPERS <- 8 # number of tapers for multitaper spectrum (k)

extract_location <- "mid" # can be "beg", "mid", or "end"
extract_what <- "duration" # can be "duration" or "proportion"
extract_duration <- 0.02
extract_proportion <- 0.5 # number from 0 to 1 indicating the proportional width of the analysed interval (0.5 = 50% of the fricative duration)

outfile <- 'sibilants_300.csv' # extension to add to the output file (if you change csv, you'll need to change code below)
################
### LET'S GO ###
################

require(tuneR)
require(multitaper)

#################
### FUNCTIONS ###
#################

# location can be "beg", "mid", or "end"
getPortion <- function(frici, n_samples, extract_samples, location) {
        if (location == "mid") {
        	edges <- (n_samples - extract_samples)/2
        	start <- round(edges)
        	end <- round(n_samples - edges)
        } else if (location == "end") {
			start <- n_samples - extract_samples
			end <- n_samples
		} else if (location == "beg") {
			start <- 1
			end <- extract_samples
		}
        frici <- frici[start:end]
        return(frici)
}

getSpectrum <- function(frici) {
	xi <- ts(attributes(frici)$left, frequency = SAMPLE_RATE)
    mti <- spec.mtm(xi, nw = NW_TIME_BANDWIDTH, k = K_TAPERS, plot = FALSE)
    	return(mti)
}

getSpectralMoments <- function(mti) {
    # cog
	cogi <- mti$freq %*% (mti$spec / sum(mti$spec))
    
    # variance
    X <- (mti$spec / sum(mti$spec))
    Y <- outer(cogi, mti$freq, function(x, y) { (y - x)^2 })
    spectral.vari <- X %*% Y
    
    # skewness
    X <- (mti$spec / sum(mti$spec))
    Y <- outer(cogi, mti$freq, function(x, y) { (y - x)^3 })
    skewi <- X %*% Y
    skewi <- skewi / spectral.vari^(3/2)
    
    # kurtosis
    X <- (mti$spec / sum(mti$spec))
    Y <- outer(cogi, mti$freq, function(x, y) { (y - x)^4 })
    kurti <- X %*% Y
    kurti <- (kurti / spectral.vari^2) - 3
    
    spectralMoments <- c(cogi, spectral.vari, skewi, kurti)
    return(spectralMoments)
}

getSpectralPeak <- function(mti) {
	peakamp <- max(mti$spec)
    loc <- which(mti$spec == peakamp)
    peaki <- mti$freq[loc]
    return(peaki)
}

getSpectralPeakAmp <- function(mti) {
	peakamp <- max(mti$spec)
}

getMidPeak <-function(mti, lowFreq, highFreq) {
	lowend <- which(abs(mti$freq - lowFreq) == min(abs(mti$freq - lowFreq)))
    highend <- which(abs(mti$freq - highFreq) == min(abs(mti$freq - highFreq)))
    peakamp <- max(mti$spec[lowend:highend])
    loc <- which(mti$spec[lowend:highend] == peakamp)
    midPeaki <- mti$freq[lowend:highend][loc]
    return(midPeaki)
}

getMidPeakAmp <-function(mti, lowFreq, highFreq) {
    lowend <- which(abs(mti$freq - lowFreq) == min(abs(mti$freq - lowFreq)))
    highend <- which(abs(mti$freq - highFreq) == min(abs(mti$freq - highFreq)))
    peakamp <- max(mti$spec[lowend:highend])
    return(peakamp)
}

##################
### FILE LOOPS ###
##################
  	# create list of files and create empty vectors for each measure
    files <- list.files(mydir, pattern = "*.wav")
    cogs <- rep(NA, length(files))
    peaks <- rep(NA, length(files))
    peakamps <- rep(NA, length(files))

    specvars <- rep(NA, length(files))
    skews <- rep(NA, length(files))
    kurts <- rep(NA, length(files))
    
for (i in 1:length(files)) {
	fi <- files[i]
	frici <- readWave(paste(mydir,fi,sep = "/"))
	frici <- normalize(frici)
	n_samples <- length(frici)
    
    if (extract_what == "proportion") {
        extract_samples <- extract_proportion * n_samples
        frici <- getPortion(frici, n_samples, extract_samples, extract_location) # get middle 50% of fricative
    } else {
        extract_samples <- extract_duration * SAMPLE_RATE
        if (extract_samples > n_samples) {
            extract_samples <- n_samples
        }
        frici <- getPortion(frici, n_samples, extract_samples, extract_location) # get middle 50% of fricative
    }
	mti <- getSpectrum(frici) # get spectrum
        
    spectralMomentsi <- getSpectralMoments(mti)
    cogs[i] <- spectralMomentsi[1] # get spectral COG
    specvars[i] <- spectralMomentsi[2] # get spectral variance
    skews[i] <- spectralMomentsi[3] # get spectral skewness
    kurts[i] <- spectralMomentsi[4] # get spectral kurtosis
        
	peaks[i] <- getSpectralPeak(mti) # get spectral peak
	peakamps[i] <- getSpectralPeakAmp(mti) # get amplitude of spectral peak
}

# set up output file
measures <- data.frame(stim = files, cog = cogs, peak = peaks, peakamp = peakamps, spectral.var = specvars, skew = skews, kurtosis = kurts)

# save output
write.csv(measures, paste0(outdir, outfile), row.names = F, quote = F)

###########
### END ###
###########


