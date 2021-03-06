# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Preprocessor for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Written by Daniel C. Oderbolz (CAMxRunner@psi.ch).
# This software is provided as is without any warranty whatsoever. See doc/Disclaimer.txt for details. See doc/Disclaimer.txt for details.
# Released under the Creative Commons "Attribution-Share Alike 2.5 Switzerland"
# License, (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)
################################################################################
# TODO: Check which date to pass (probably the center day...)
################################################################################
# Module Metadata. Leave "-" if no setting is wanted
################################################################################

# This is a very important field needed for the scheduling of parallel processes.
# It contains a comma-separated list of modules (just their names without numbers or extensions)
# from whose output this module DIRECTLY depends on.
#
# A process can only start if its dependencies have finished. Only list direct dependencies.
# There are some special dependencies:
# ${CXR_TYPE_PREPROCESS_ONCE} - all pre_start_preprocessors must have finished
# ${CXR_TYPE_PREPROCESS_DAILY} - all daily_preprocessors must have finished
# ${CXR_TYPE_MODEL} - all model modules must have finished
# ${CXR_TYPE_POSTPROCESS_DAILY} - all daily_postprocessors must have finished
# ${CXR_TYPE_POSTPROCESS_ONCE} - all finish_postprocessors must have finished

# the predicate "-<n>" refers to some previous model day, so ${CXR_TYPE_MODEL}-1 means that all model modules of the previous day must be successful before this module may run. 

CXR_META_MODULE_DEPENDS_ON="albedo_haze_ozone"

# Also for the management of parallel tasks
# If this is true, no new tasks will be given out as long as this runs
# Normaly only used for a model or parallelized preprocessors
CXR_META_MODULE_RUN_EXCLUSIVELY=false

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Generates a a multi-dimensional lookup table of photolytic rates using TUV (Tropospheric Ultraviolet and Visible Radiation Model)"

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}"
CXR_META_MODULE_TYPE="${CXR_TYPE_PREPROCESS_ONCE}"

# If >0, this module supports testing
CXR_META_MODULE_NUM_TESTS=1

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2010), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'

################################################################################
# Function: getNumInvocations
#
# Needs to be changed only if your module can be called more than once per step independently.
# For example your module might be run for each grid separately. Then, CAMxRunner
# can might be able to start these in parallel, but it needs to know how many
# of these "invocations" per step are needed.
# 
################################################################################
function getNumInvocations()
################################################################################
{
	# This depends on the interval
	case "${CXR_RUN_AHOMAP_TUV_INTERVAL:-once}" in
	
		once )
			# Just once
			echo 1
			;;
			
		daily )
			# One for each day
			echo $CXR_NUMBER_OF_SIMULATION_DAYS
			;;
			
		weekly )
			# One for each unique week
			common.date.WeeksBetween $CXR_START_DATE $CXR_STOP_DATE
			;;
			
		
		monthly )
			# One for each unique week
			common.date.MonthsBetween $CXR_START_DATE $CXR_STOP_DATE
			;;
	
		*)
			main.dieGracefully "Unknown interval for TUV in variable CXR_RUN_AHOMAP_TUV_INTERVAL, we suport once,daily,weekly or monthly! Exiting." 
			;;
	esac
}

################################################################################
# Function: getProblemSize
#
# Returns the problem size of a given invocation.
# If the problem size is constant, return 1.
#
################################################################################
function getProblemSize()
################################################################################
{
	# The Problem size here is not a function of the invocation
	echo 1
}

################################################################################
# Function: set_variables
#	
# Sets the appropriate variables needed for <photolysis_rates>
################################################################################	
function set_variables() 
################################################################################
{	

	# First of all, reset checks.
	# We will later continuously add entries to these 2 lists.
	# CAREFUL: If you add files to CXR_CHECK_THESE_OUTPUT_FILES,
	# these are deleted if he user runs the -F option. Do not mix up with input files!
	CXR_CHECK_THESE_INPUT_FILES=
	CXR_CHECK_THESE_OUTPUT_FILES=
	
	########################################################################
	# Set variables
	########################################################################
	
	# Evaluate some rules
	CXR_AHOMAP_INPUT_FILE="$(common.runner.evaluateRule "$CXR_ALBEDO_HAZE_OZONE_FILE_RULE" false CXR_ALBEDO_HAZE_OZONE_FILE_RULE)"
	# Output files must not be decompressed!
	CXR_TUV_OUTPUT_FILE="$(common.runner.evaluateRule "$CXR_PHOTOLYSIS_RATES_FILE_RULE" false CXR_PHOTOLYSIS_RATES_FILE_RULE false)"
	
	#Checks
	CXR_CHECK_THESE_INPUT_FILES="$CXR_CHECK_THESE_INPUT_FILES $CXR_AHOMAP_INPUT_FILE"
	CXR_CHECK_THESE_OUTPUT_FILES="$CXR_CHECK_THESE_OUTPUT_FILES $CXR_TUV_OUTPUT_FILE"

}


################################################################################
# Function: create_tuv_control_file
#	
# Creates a TUV Control file that can be fed to the program.
#
# Parameters:
# $1 - filename of AHOMAP file
#
# Returns:
# a filename of the created control file
#
# See:
# <write_control_file>
################################################################################
function create_tuv_control_file ()
################################################################################
{
	# Create a file name
	local tuv_control_file
	tuv_control_file=$(common.runner.createJobFile TUV)

	# Here, we need only > (overwrite)
	echo "output file name   |$CXR_TUV_OUTPUT_FILE" > $tuv_control_file
	
	# From here one, please >> (append)
	echo "ahomap file name   |$CXR_AHOMAP_INPUT_FILE" >> $tuv_control_file
	echo "ozone, albedo, haze|$CXR_NOZN, $CXR_NALB, $CXR_NHAZ" >> $tuv_control_file
	echo "# of vert levels   |$CXR_NHGHT" >> $tuv_control_file
	echo "levels, km agl     |$CXR_TUV_HEIGHTS" >> $tuv_control_file
	echo "date (YYMMDD)      |${CXR_YEAR_S}${CXR_MONTH}${CXR_DAY}" >> $tuv_control_file
	echo "rad transfer scheme|$CXR_TUV_RADIATIVE_TRANSFER_SCHEME " >> $tuv_control_file
	echo "# of phot reactions|$CXR_TUV_NO_OF_REACTIONS" >> $tuv_control_file
	echo "TUV reaction #s    |$CXR_TUV_REACTION_NUMBERS" >> $tuv_control_file
	
	# Return the file name
	echo $tuv_control_file
}

################################################################################
# Function: photolysis_rates
#	
# Generates a a multi-dimensional lookup table of photolytic rates using
# TUV (Tropospheric Ultraviolet and Visible Radiation Model).
#
# See:
# <create_tuv_control_file>, <albedo_haze_ozone>
#
# Parameters:
# None.
#
# Variables:
# $CXR_RUN_AHOMAP_TUV_INTERVAL - either of {once,daily,weekly,monthly}, controls number of files.
#
# Files:
# $CXR_AHOMAP_INPUT_FILE - the AHOMAP output file
# $CXR_TUV_OUTPUT_FILE - the Output file
################################################################################
function photolysis_rates() 
################################################################################
{
	# We set the invocation (we die if not passed)
	# In this module, CXR_INVOCATION must be mapped to a part of the workload
	CXR_INVOCATION=${1}
	
	# Define & Initialize local vars
	local tuv_control_file
	local day_offset
	local start_offset
	local iMonth
	local tempdir
	
	day_offset=0
	 
	#Was this stage already completed?
	if [[ $(common.state.storeStatus ${CXR_STATUS_RUNNING}) == true  ]]
	then
	
			# Initialize data for this file
			case "${CXR_RUN_AHOMAP_TUV_INTERVAL:-once}" in
			
				once )
					start_offset=0
					common.date.setVars "$CXR_START_DATE" "$start_offset"
					main.log -b "Running TUV for whole period..."
					;;
					
				daily )
					# In this case, the invocation is the day-offset plus 1
					start_offset=$(( $CXR_INVOCATION - 1 ))
					common.date.setVars "$CXR_START_DATE" "$start_offset"
				
					main.log -b "Running TUV for $CXR_DATE..."
					;;
					
				weekly )
				
						# Here, the invocation is the week offset since start
						# We need to find the start (Monday) of the current offset week
						# and determine its day_offset
						if [[ $CXR_INVOCATION -eq 1 ]]
						then
							# we are at the first day
							start_offset=0
						else
							# we are at some later day
							# note that adding 7 to a day_offset moves us into the next week.
							# Therefore we subtract 2 and not 1 from the CXR_INVOCATION
							start_offset=$(( $(common.date.DaysLeftInWeek $CXR_START_DATE true) + 7 * ( $CXR_INVOCATION - 2 ) ))
						fi
						
						# We cannot go beyond the last day
						if [[ $start_offset -gt $(( ${CXR_NUMBER_OF_SIMULATION_DAYS} -1 )) ]]
						then
							start_offset=$(( ${CXR_NUMBER_OF_SIMULATION_DAYS} -1 ))
						fi
						
						common.date.setVars "$CXR_START_DATE" "$start_offset"
					
						main.log -b "Running TUV for week $CXR_WOY..."
					
					;;
				
				monthly )
				
					# Here, the invocation is the month offset since start
					# We need to find the 1st of the current offset month
					if [[ $CXR_INVOCATION -eq 1 ]]
					then
						# we are at the first day
						start_offset=0
					else
						# we start at 0
						start_offset=0
						
						for iMonth in $(seq 2 $CXR_INVOCATION)
						do
							common.date.setVars "$CXR_START_DATE" "$start_offset"
							start_offset=$(( $start_offset + $(common.date.DaysLeftInMonth $CXR_DATE true) ))
						done
					fi
					
					# We cannot go beyond the last day
					if [[ $start_offset -gt $(( ${CXR_NUMBER_OF_SIMULATION_DAYS} -1 )) ]]
					then
						start_offset=$(( ${CXR_NUMBER_OF_SIMULATION_DAYS} -1 ))
					fi
					
					common.date.setVars "$CXR_START_DATE" "$start_offset"
					main.log -b "Running TUV for month $CXR_MONTH..."
					;;
			
				*)
					main.dieGracefully "Unknown interval for TUV in variable CXR_RUN_AHOMAP_TUV_INTERVAL, we suport once,daily,weekly or monthly! Exiting." ;;
			esac
			
			#  --- Setup the Environment
			set_variables 
			
			#  --- Check Settings
			if [[ $(common.check.preconditions) == false  ]]
			then
				main.log  "Preconditions for ${CXR_META_MODULE_NAME} are not met!"
				common.state.storeStatus ${CXR_STATUS_FAILURE}  > /dev/null
			
				# We notify the caller of the problem
				return $CXR_RET_ERR_PRECONDITIONS
			fi
			
			if [[ ! -s "$CXR_TUV_OUTPUT_FILE"  ]]
			then
				# TUV File does not exist
			
				# Increase global indent level
				main.increaseLogIndent
		
				if [[ "$CXR_DRY" == false  ]]
				then
					# TUV needs an input file
					tuv_control_file=$(create_tuv_control_file)
					
					# Is the file there and not empty?)
					if [[ -s "${tuv_control_file}"  ]]
					then
				
						# TUV is picky - it expects a file called
						# tuv.inp and also it looks for some files
						# That's why we chage to a tempdir (avoid races!)
						
						tempdir=$(common.runner.createTempDir tuv-workdir)
						
						cd ${tempdir} || return $CXR_RET_ERROR
						
						main.log -a "TUV working in ${tempdir}"
						
						# TUV needs an input file called "tuv.inp"
						ln -s "$tuv_control_file" tuv.inp
						
						# We also need 4 diectories (creating links again)
						ln -s ${CXR_MODEL_BIN_DIR}/DATAE1
						ln -s ${CXR_MODEL_BIN_DIR}/DATAJ1
						ln -s ${CXR_MODEL_BIN_DIR}/DATAJ2
						ln -s ${CXR_MODEL_BIN_DIR}/DATAS1
						
						main.log  "Calling TUV - using jobfile ${tuv_control_file} (be patient)...\n"
						cat tuv.inp | tee -a ${CXR_LOG}
		
						# Call TUV
						${CXR_TUV_EXEC}  2>&1 | tee -a $CXR_LOG
		
					else
						main.log "Could not create TUV control file - module failed."
						return $CXR_RET_ERROR
					fi
		
				else
					# Dryrun, create dummy
					tuv_control_file=$(common.runner.createJobFile TUV)
					
					main.log  "Dryrun - TUV not performed"
				fi
		
				# Decrease global indent level
				main.decreaseLogIndent
		
				# Check if all went well
				if [[ $(common.check.postconditions) == false  ]]
				then
					main.log -a "Postconditions for ${CXR_META_MODULE_NAME} are not met!"
					common.state.storeStatus ${CXR_STATUS_FAILURE}  > /dev/null
			
					# We notify the caller of the problem
					return $CXR_RET_ERR_POSTCONDITIONS
				fi
				
				# Removing unneeded files
				rm -f tuv.inp
				rm -f tuv.out
			else
				# File exists. That is generally bad,
				# unless user wants to skip
				if [[ "$CXR_SKIP_EXISTING" == true  ]]
				then
					# Skip it
					main.log -w   "File $CXR_TUV_OUTPUT_FILE exists - because -S option was supplied, file will skipped."
					common.state.storeStatus ${CXR_STATUS_SUCCESS} > /dev/null
					return $CXR_RET_OK
				else
					# Fail!
					main.log -e  "File $CXR_TUV_OUTPUT_FILE exists - to force the re-creation run ${CXR_CALL} -F"
					common.state.storeStatus ${CXR_STATUS_FAILURE}  > /dev/null
					return $CXR_RET_ERROR
				fi
			fi
		
		# Reset date variables for first day
		common.date.setVars "$CXR_START_DATE" "0"

		# Return to where we were
		cd $CXR_RUN_DIR || return $CXR_RET_ERROR
		
		
		# All is fine
		CXR_STATUS=$CXR_STATUS_SUCCESS

		# Store the state
		common.state.storeStatus ${CXR_STATUS_SUCCESS} > /dev/null
	else
		main.log  "Stage $(common.task.getId) was already started, therefore we do not run it. To clean the state database, run \n \t ${CXR_CALL} -c \n and rerun."
	fi
}

################################################################################
# Function: test_module
#
# Runs the predefined tests for this module
# 
# Parameters:
################################################################################	
function test_module()
################################################################################
{
	
	########################################
	# Setup tests if needed
	########################################
	
	# Initialise the date variables for first day
	day_offset=0
	common.date.setVars "$CXR_START_DATE" "$day_offset"
	set_variables

	# For this module, testing is harder 
	# compared to date_functions because we cannot just compare
	# Expected with actual results
	photolysis_rates
	
	########################################
	# Tests. If the number changes, change CXR_META_MODULE_NUM_TESTS
	########################################
	
	is $(common.fs.isNotEmpty? ${CXR_TUV_OUTPUT_FILE}) true "photolysis_rates simple existence check, inspect ${CXR_TUV_OUTPUT_FILE}"
	
	
	########################################
	# teardown tests if needed
	########################################
	
}