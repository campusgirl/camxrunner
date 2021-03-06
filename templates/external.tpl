#!/bin/bash

# This template is expanded by the -e option of the
# CAMxRunner. You may use variables in here.
#
# The code here is written for the rosa system at CSCS,
# which uses the SLURM queuing system.
#
# Local variables cannot (and should not) be expanded
# make sure that these are not on the same line as an expandable variable
# because we work line-per-line.
#
# If you need to expand a commented line, echo the comment using -en "\\043"
# In general, try to avoid command expansion as the expansion is local.
# One way around this is to generate a $ sign ( and ) using the trick above

$(echo -en "\\043")SBATCH --output=$CXR_EXTERNAL_STDLOG
$(echo -en "\\043")SBATCH --error=$CXR_EXTERNAL_ERRLOG
$(echo -en "\\043")SBATCH --ntasks=$CXR_EXTERNAL_NUMBER_OF_TASKS
$(echo -en "\\043")SBATCH --ntasks-per-node=$CXR_EXTERNAL_TASKS_PER_NODE
$(echo -en "\\043")SBATCH --cpus-per-task=$CXR_EXTERNAL_CPUS_PER_TASK
$(echo -en "\\043")SBATCH --time=$CXR_EXTERNAL_TIME_NEEDED

days_per_job=$CXR_EXTERNAL_DAYS_PER_JOB

export OMP_NUM_THREADS=$CXR_EXTERNAL_TASKS_PER_NODE

# Store all CAMx.in files in a tempfile
tmpfile=$(echo -en "\\044\\050")mktemp /tmp/cxr.XXXXXXXXXXX$(echo -en "\\051")

$(echo -e "ls -1 CAMx.????????.in > \\044tmpfile")

# Count the days
$(echo -e "ndays=\\044\\050cat \\044tmpfile \\0174 wc -l\\051")


tmpfile_red=$(echo -en "\\044\\050")mktemp /tmp/cxr_red.XXXXXXXXXXX$(echo -en "\\051")

# Extract the next days_per_job lines
if [[ -e last_day ]]
then
	# We start at last_day + 1
	last=$(echo -en "\\044\\050")cat last_day$(echo -en "\\051")
	
	$(echo -e "line=\\044\\050 grep -n \\044last \\044tmpfile | cut -d: -f1  \\051")
	
	start=$(echo -en "\\044\\050\\050 \\044")line + 1 $(echo -en "\\051")$(echo -en "\\051")
	
	if [[ $(echo -en "\\044")start -gt $(echo -en "\\044")ndays ]]
	then
		# No more days
		echo "It seems that all days where processed."
		exit
	else
		# There are more days
		# First get the lines after starting,        then get the first n ones
		
		$(echo -e "tail -n\\044\\050\\050 \\044ndays - \\044start + 1\\051\\051 \\044tmpfile \\0174 head -n\\044days_per_job > \\044tmpfile_red")
	fi
else
	# We start at the beginnig
	$(echo -e "head -n\\044days_per_job \\044tmpfile > \\044tmpfile_red")
fi

while read file
do
	ln -s -f $(echo -en "\\044")file CAMx.in
	aprun -n $CXR_EXTERNAL_NUMBER_OF_TASKS -N $CXR_EXTERNAL_TASKS_PER_NODE -d $CXR_EXTERNAL_CPUS_PER_TASK $CXR_EXTERNAL_MODEL_EXEC
	
	# Store the last day processed
	$(echo -e "echo \\044file > last_day")
done $(echo -en "\\074 \\044")tmpfile_red


rm $(echo -en "\\044")tmpfile $(echo -en "\\044")tmpfile_red

