#######################################################################
#  File Segmenter Script
#######################################################################
#  This script divides a file into individual chunks that have been marked
#  in some specified tier.  Each vowel is saved as an individual Praat
#  sound file with the name of the original file plus the interval
#  label.  25 milliseconds is added to either side of the chunk to ensure
#  that any analysis (with a 25ms window) made at the beginning of the chunk
#  will not crash.
#
#  Input:   Sound files with associated TextGrids
#           - TextGrids should have labels for relevant intervals (i.e.,
#             intervals to be chunked).
#  Output:  Individual sound files named according to the original file and
#           the interval label.
#  Process: The script asks for a directory in which to look for files, a tier
#           by which to segment, and an input sound file type.  It then looks
#           for soundfiles of the specified type with associated TextGrids in
#           the specified folder.  For each soundfile, it locates marked
#           intervals in the specifed tier one-by-one.  Each labeled interval 
#           (plus 25 ms before and after it) is saved as a new .wav file and
#           a new text grid.  After all intervals in all files in the specified
#           directory have been segmented, a finish message appears.

# This script is not by Will Styler, but is distributed by him because it's super useful.
#######################################################################

form Chopping long sound files
   comment Specify which tier in the TextGrid you want to segment by:
        integer tier_number 1
   #comment Specify starting Index Number:
   #    integer index 0
   #comment Specify the Prefix of the final wave name:
   #     word prefix 
   comment Sound file extension:
        optionmenu file_type: 2
        option .aiff
        option .wav
   sentence directory 
   sentence out_dir 
endform
clearinfo
#if index < 1
#	writeInfoLine: "specify index..."
#	exit
#endif
#prefix in the form is commented that is why this part is block
#if length(prefix$) = 0
#	writeInfoLine: "specify prefix..."
#	exit
#endif

#printline soundname, nsyll, npause, dur (s), phonationtime (s), speechrate (nsyll/dur), articulation rate (nsyll / phonationtime), ASD (speakingtime/nsyll)3

#printline SoundName'tab$'Segment_label'tab$'start_time'tab$'end_time'tab$'seg_dur'tab$'Sampling Rate'tab$'Avg_Int'tab$'Min_Int'tab$'Max_Int'newline$'


#directory$ = chooseDirectory$ ("Choose the directory containing sound files and textgrids")
directory$ = "'directory$'" + "/" 

#runSystem: "del ", out_dir$, "\*.wav"
#runSystem: "del ", out_dir$, "\*.pk"
#runSystem: "rmdir ",out_dir$

#createDirectory(out_dir$)
#out_dir$ = "'out_dir$'" + "/"

#out_dir$ = "'out_dir$'" + "/" + "SegmentData"
#createDirectory (out_dir$) 

resultfile$="'out_dir$'" + "/" + "output.txt"

# Check if the result file exists:
if fileReadable (resultfile$)
	pause The result file 'resultfile$' already exists! Do you want to overwrite it?
	filedelete 'resultfile$'
endif
#titleline$ = "SoundName'tab$'Segment_label'tab$'start_time'tab$'end_time'tab$'seg_dur'tab$'Sampling Rate'tab$'Avg_Int'tab$'Min_Int'tab$'Max_Int'newline$''newline$'"
titleline$ = "SoundName'tab$'Segment_label'tab$''newline$'"
fileappend "'resultfile$'" 'titleline$'



Create Strings as file list... list 'directory$'*'file_type$'
number_of_files = Get number of strings

# Starting from here, add everything that should be repeated for each sound file
for j from 1 to number_of_files
        select Strings list
        filename$ = Get string... 'j'
        Read from file... 'directory$''filename$'
        soundname$ = selected$ ("Sound")
	out_dir$ = "'out_dir$'" + "/" +"'soundname$'"+ "_SegmentData"
	createDirectory (out_dir$) 
	srate = Get sample rate
	To Intensity... 100 0
	index=001
        gridfile$ = "'directory$''soundname$'.TextGrid"
        if fileReadable (gridfile$)
                Read from file... 'gridfile$'
                select TextGrid 'soundname$'
                number_of_intervals = Get number of intervals... 'tier_number'
                
                # Go through all intervals in the file
		#index = 1
                for k from 1 to number_of_intervals
			
	   		select TextGrid 'soundname$'
	    		seg_label$ = Get label of interval... 'tier_number' 'k'
			#if seg_label$ = "VS"
			if seg_label$ <> "NS"
			#if seg_label$ <> "VS"
				seg_start = Get starting point... 'tier_number' 'k'
			        seg_end = Get end point... 'tier_number' 'k'
			        start = seg_start-0.1
				end = seg_end+0.1
			        #start = seg_start 
			        #end = seg_end 
				sgedur = seg_end - seg_start
				#printline 'start''tab$''end''tab$''sgedur'
			        select Sound 'soundname$'
				#select Intensity 'soundname$'
				#min_int = Get minimum... start end Parabolic
				if sgedur > 0.01
			        	Extract part: start, end, "rectangular", 1, "no"
						#if length(string$(k)) = 1
						#	postfix$ = "0000"+string$(k)
						#endif
						#if length(string$(k)) = 2
						#	postfix$ = "000"+string$(k)
						#endif
						#if length(string$(k)) = 3
						#	postfix$ = "00"+string$(k)
						#endif
						#if length(string$(k)) = 4
						#	postfix$ = string$(k)
						#endif
						if length(string$(index)) = 1
							postfix$ = "0000"+string$(index)
						endif
						if length(string$(index)) = 2
							postfix$ = "000"+string$(index)
						endif
						if length(string$(index)) = 3
							postfix$ = "00"+string$(index)
						endif
						if length(string$(index)) = 4
							postfix$ = "0"+string$(index)
						endif
						index = index + 1

				    
			            out_filename$ = "'out_dir$'"+ "/"+"'soundname$'-'postfix$'"
						# initialize anti-collision counter.
			            #aff = 1
						#name$ = out_filename$
			            #while fileReadable ("'out_filename$'.wav")
							#out_filename$ = "'out_dir$''soundname$'-'seg_label$'-'k'"
							#aff = aff + 1
							#out_filename$ = "'name$'_'aff'"
			            #endwhile
			            Write to WAV file... 'out_filename$'.wav
			            select TextGrid 'soundname$'
			            Extract part... 'start' 'end' no
			            #Rename... 'out_filename$'
			            #Write to text file... 'out_filename$'.TextGrid
				else
					printline SegNo -'k' and Duration:'sgedur:3'
				endif
				select Intensity 'soundname$'
				min_int = Get minimum... start end Parabolic
				max_int = Get maximum... start end Parabolic
				meanIntensity = Get mean... start end dB
				#printline 'soundname$'-'postfix$''tab$''seg_label$''tab$''start:2''tab$''end:2''tab$''sgedur:2''tab$''srate''tab$''meanIntensity:3''tab$''min_int:3''tab$''max_int:3'				
				#resultline$ = "'soundname$'-'postfix$''tab$''seg_label$''tab$''start:2''tab$''end:2''tab$''sgedur:2''tab$''srate''tab$''meanIntensity:3''tab$''min_int:3''tab$''max_int:3''newline$'"
				resultline$ = "'soundname$'-'postfix$''tab$''seg_label$''newline$'"
				fileappend "'resultfile$'" 'resultline$'
					
			endif

			#min_time = Get time of minimum... start end Parabolic
			#max_int = Get maximum... start end Parabolic
			#max_time = Get time of maximum... start end Parabolic
			#meanIntensity = Get mean... start end dB
			#printline 'seg_label$''tab$''start''tab$''end''sgedur''tab$''min_int''tab$''max_int''tab$''meanIntensity'

                endfor
                select all
                minus Strings list
                Remove
		#index=""
        endif
	#minus Strings list
endfor
strings = Create Strings as file list: "list",out_dir$ + "/*.wav"
noOffiles = Get number of strings
#print 'noOffiles'
select all
Remove
#print All files have been segmented.
