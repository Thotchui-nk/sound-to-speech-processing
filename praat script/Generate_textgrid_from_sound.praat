# Run Praat.exe
# From Praat Oblect dialog 
# Praat --> Open Praat Script... 
# Browse and open this script file (In which location this script is kept)
# Then this script will open another in Praat editor. 
# From Praat editor click on Run dialog and run.
# This script requires two input from the user
# 1. Path of the Input wave directory including the "\" after the path
# 2. Path of the output directory including the "\" after the path (TextGrid will save there) 
# This script will read all the waves in the directory
# It will create TextGrid file according to the name of the wave file


form Counting Syllables in Sound Utterances
	real Silence_threshold_(dB) -35
	real Minimum_dip_between_peaks_(dB) 0.5
	real Minimum_pause_duration_(s) 0.06
	boolean Keep_Soundfiles_and_Textgrids yes
	#sentence directory 
	word Input_Directory C:\Users\ngaka\OneDrive\Desktop\nws_tangkhul\segmentation_file
	word Output_Directory C:\Users\ngaka\OneDrive\Desktop\nws_tangkhul\segmentation_file
endform

clearinfo

# shorten variables
silencedb = 'silence_threshold'
mindip = 'minimum_dip_between_peaks'
showtext = 'keep_Soundfiles_and_Textgrids'
minpause = 'minimum_pause_duration'
 
# print a single header line with column names and units
#printline soundname, nsyll, npause, dur (s), phonationtime (s), speechrate (nsyll/dur), articulation rate (nsyll / phonationtime), ASD (speakingtime/nsyll)

# read files
Create Strings as file list... list 'Input_Directory$'/*.wav
numberOfFiles = Get number of strings
for ifile to numberOfFiles
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'Input_Directory$'/'fileName$'

	# use object ID
	soundname$ = selected$("Sound")
	soundid = selected("Sound")
	#label$= selected$("Sound")
	#Write to text file... praat.txt

	originaldur = Get total duration
	# allow non-zero starting time
	bt = Get starting time

	# Use intensity to get threshold
	To Intensity... 30 0 yes
	intid = selected("Intensity")
	start = Get time from frame number... 1
	nframes = Get number of frames
	end = Get time from frame number... 'nframes'
	#printline 'nframes''tab$''end''newline$'

	# estimate noise floor
	minint = Get minimum... 0 0 None
	# estimate noise max
	maxint = Get maximum... 0 0 None
	#get .99 quantile to get maximum (without influence of non-speech sound bursts)
	max99int = Get quantile... 0 0 0.99

	# estimate Intensity threshold
	threshold = max99int + silencedb
	threshold2 = maxint - max99int
	threshold3 = silencedb - threshold2
	if threshold < minint
		threshold = minint
	endif
	#printline 'max99int''tab$''silencedb''tab$''maxint''tab$''max99int''tab$''threshold2''tab$''threshold3''tab$''minpause'

	To TextGrid (silences)... threshold3 minpause 0.1 NS VS

	# get pauses (silences) and speakingtime
	#Read from file... 'Input_Directory$'/'fileName$'
	#soundname$ = selected$("Sound")
	#soundid = selected("Sound")
	#To TextGrid (voice activity)... 0.0 0.3 0.1 70.0 6000.0 -35.0 -50.0 0.1 0.1 NS VS
	textgridid = selected("TextGrid")
	silencetierid = Extract tier... 1
	silencetableid = Down to TableOfReal... VS
	nsounding = Get number of rows
	npauses = 'nsounding'
	speakingtot = 0
	beginsound = 0
	endsound = 0
	for ipause from 1 to npauses
		beginsound = Get value... 'ipause' 1
		beginsound = beginsound
		endsound = Get value... 'ipause' 2
		#tstart$ = 'beginsound'
		#tend$ = 'endsound'
		speakingdur = 'endsound' - 'beginsound'
		speakingtot = 'speakingdur' + 'speakingtot'
		#fileappend rajib 'beginsound:2''tab$''endsound:2'
		#printline 'beginsound:4''tab$''endsound:4''tab$''speakingdur''tab$''speakingtot'
		
	endfor

	select 'intid'
	Down to Matrix
	matid = selected("Matrix")
	# Convert intensity to sound
	To Sound (slice)... 1
	sndintid = selected("Sound")

	# use total duration, not end time, to find out duration of intdur
	# in order to allow nonzero starting times.
	intdur = Get total duration
	intmax = Get maximum... 0 0 Parabolic

	# estimate peak positions (all peaks)
	To PointProcess (extrema)... Left yes no Sinc70
	ppid = selected("PointProcess")

	numpeaks = Get number of points

	# fill array with time points
	for i from 1 to numpeaks
		 t'i' = Get time from index... 'i'
	endfor 

	# fill array with intensity values
	select 'sndintid'
	peakcount = 0
	for i from 1 to numpeaks
		 value = Get value at time... t'i' Cubic
		 if value > threshold
				 peakcount += 1
				 int'peakcount' = value
				 timepeaks'peakcount' = t'i'
		 endif
	endfor

	# fill array with valid peaks: only intensity values if preceding 
	# dip in intensity is greater than mindip
	select 'intid'
	validpeakcount = 0
	currenttime = timepeaks1
	currentint = int1

	for p to peakcount-1
		following = p + 1
		followingtime = timepeaks'following'
		dip = Get minimum... 'currenttime' 'followingtime' None
		diffint = abs(currentint - dip)

		if diffint > mindip
			validpeakcount += 1
			validtime'validpeakcount' = timepeaks'p'
		endif
			currenttime = timepeaks'following'
			currentint = Get value at time... timepeaks'following' Cubic
	endfor
  
	# Look for only voiced parts
	select 'soundid' 
	To Pitch (ac)... 0.02 30 4 no 0.03 0.25 0.01 0.35 0.25 450
	# keep track of id of Pitch
	pitchid = selected("Pitch")
	select 'pitchid'
	#fileappend pitch.txt 'value''newline$'
	#Write to text file... pitch.txt 
	voicedcount = 0
	voicedcountx = 0
	for i from 1 to validpeakcount
		querytime = validtime'i'

		select 'textgridid'
		whichinterval = Get interval at time... 1 'querytime'
		whichlabel$ = Get label of interval... 1 'whichinterval'
		#printline 'whichinterval''tab$''whichlabel$'
		
		select 'pitchid'
		value = Get value at time... 'querytime' Hertz Linear
		time =  querytime
		#printline 'time:3''tab$''value:3'
		if value <> undefined 
			if whichlabel$ = "VS" && value > 50
				voicedcount = voicedcount + 1
				voicedpeak'voicedcount' = validtime'i'
				#printline 'voicedcount''tab$''time:3''tab$''value:3'
			endif
		endif
	
	endfor
	
	# calculate time correction due to shift in time for Sound object versus
	# intensity object
	timecorrection = originaldur/intdur


	# Insert voiced peaks in TextGrid
	if showtext > 0
		select 'textgridid'
		#Insert point tier... 1 SpkChng
		#printline 'voicedcount'	 
		for i from 1 to voicedcount
			position = voicedpeak'i' * timecorrection
			#printline 'position' 
			#Insert point... 1 position 'i'
			#fileappend rajib.txt 'position' 'newline$'
			#printline 'position''tab$''newline$'
		endfor
	endif

	la$= selected$("TextGrid")
	Write to text file... 'Output_Directory$'/'soundname$'.TextGrid
	#fileappend path.txt 'Output_Directory$''soundname$'.TextGrid

	for ipause from 1 to npauses
		#out = beginsound[ipause]
		#fileappend soma.txt 'out[ipause]' 'newline$'		
	endfor

	# clean up before next sound file is opened
	 select 'intid'
	 plus 'matid'
	 plus 'sndintid'
	 plus 'ppid'
	 plus 'pitchid'
	 plus 'silencetierid'
	 plus 'silencetableid'
	 Remove
	 if showtext < 1
		 select 'soundid'
		 plus 'textgridid'
		 Remove
	 endif

	# summarize results in Info window
	speakingrate = 'voicedcount'/'originaldur'
	articulationrate = 'voicedcount'/'speakingtot'
	npause = 'npauses'-1
	asd = 'speakingtot'/'voicedcount'
	
	#printline 'soundname$', 'voicedcount', 'npause', 'originaldur:2', 'speakingtot:2', 'speakingrate:2', 'articulationrate:2', 'asd:3'
 
endfor

procedure AnalyzeFrame
	f0_prev = 0
	select pitch
	time = Get time from frame number... j
	f0 = Get value in frame... j Hertz
	if f0 != undefined && f0 < 150 && f0_prev >= 250
		select 'textgridid'
		Insert point... 1 time
		select table
		Append row
		Set numeric value... Object_'table'.nrow time 'time:3'
		Set numeric value... Object_'table'.nrow f0 'f0:2'
	endif
	f0_prev = f0	
endproc

select all
Remove