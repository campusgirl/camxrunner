# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Postprocessor for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Compares the model output of the current run to another run.
# Normally this processor is not needed - it is targeted towards 
# the ENVIRON Testcase
#
# Written by Daniel C. Oderbolz (CAMxRunner@psi.ch).
# This software is provided as is without any warranty whatsoever. See doc/Disclaimer.txt for details. See doc/Disclaimer.txt for details.
# Released under the Creative Commons "Attribution-Share Alike 2.5 Switzerland"
# License, (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)
################################################################################
# TODO: 
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

CXR_META_MODULE_DEPENDS_ON="${CXR_TYPE_MODEL}"

# Also for the management of parallel tasks
# If this is true, no new tasks will be given out as long as this runs
# Normaly only used for a model or parallelized preprocessors
CXR_META_MODULE_RUN_EXCLUSIVELY=false

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Compares the model output of the current run to another run.\nNormally this processor is not needed - it is targeted towards the ENVIRON Testcase"

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}"
CXR_META_MODULE_TYPE="${CXR_TYPE_POSTPROCESS_DAILY}"

# If >0, this module supports testing
CXR_META_MODULE_NUM_TESTS=0

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
	# this module needs one invocation per grid per step
	
	echo $CXR_NUMBER_OF_GRIDS
}

################################################################################
# Function: getProblemSize
#
# Returns the problem size of a given invocation.
# If the problem size is constant, return 1.
# 
# Parameters:
# $1 - invocation
################################################################################
function getProblemSize()
################################################################################
{
	local invocation
	local x
	local y
	local z
	
	invocation=$1
	
	x=$(common.runner.getX ${invocation})
	y=$(common.runner.getY ${invocation})
	z=$(common.runner.getZ ${invocation})
	
	# The Problem size here is a function of the invocation
	echo $(( $x * $y * $z ))
}

################################################################################
# Function: set_variables
#	
# Sets the appropriate variables for <avgdif>
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
	
	# Grid specific - we need to define CXR_IGRID
	CXR_IGRID=$CXR_INVOCATION
	
	# Output files must not be decompressed!
	CXR_AVGDIF_OUTPUT_FILE=$(common.runner.evaluateRule "$CXR_AVGDIF_OUTPUT_FILE_RULE" false CXR_AVGDIF_OUTPUT_FILE_RULE false)
	
	#Checks
	CXR_CHECK_THESE_OUTPUT_FILES="$CXR_CHECK_THESE_OUTPUT_FILES $CXR_AVGDIF_OUTPUT_FILE"
	
	# The file produced in this run
	CXR_TEST_INPUT_FILE=$(common.runner.evaluateRule "$CXR_AVG_FILE_RULE" false CXR_AVG_FILE_RULE)
		
	# The reference files
	CXR_REFERENCE_INPUT_FILE=$(common.runner.evaluateRule "$CXR_REFERENCE_FILE_RULE" false CXR_REFERENCE_FILE_RULE)
	
	#Checks
	CXR_CHECK_THESE_INPUT_FILES="$CXR_CHECK_THESE_INPUT_FILES ${CXR_TEST_INPUT_FILE} ${CXR_REFERENCE_INPUT_FILE}"

	
}

################################################################################
# Function: avgdif
#	
# Compares the model output of the current run to another run using the avgdif postprocessor
################################################################################	
function avgdif
################################################################################
{
	# We do not need this variable here (exept implicit for the stage name)
	CXR_INVOCATION=${1:-1}
	
	# Define & Initialize local vars
	local exec_tmp_file
	
	#Was this stage already completed?
	if [[ $(common.state.storeStatus ${CXR_STATUS_RUNNING}) == true  ]]
	then	
		#  --- Setup the Environment of the current day
		set_variables 
		
		#  --- Check Settings
		# Postprocessor: we only terminate the module
		if [[ $(common.check.preconditions) == false  ]]
		then
			main.log  "Preconditions for ${CXR_META_MODULE_NAME} are not met!"
			common.state.storeStatus ${CXR_STATUS_FAILURE}  > /dev/null
			
			# We notify the caller of the problem
			return $CXR_RET_ERR_PRECONDITIONS
		fi
		
		main.log  "Comparing Model output to existing model data on grid $CXR_INVOCATION ..."    
		
		# Loop over grids
		main.log  "Comparing ${CXR_REFERENCE_INPUT_FILE} and ${CXR_TEST_INPUT_FILE}\nOutput will be in $CXR_AVGDIF_OUTPUT_FILE"
			
		# Put call into this file
		exec_tmp_file=$(common.runner.createJobFile AVGDIF)
		
		# Build tempfile
		cat <<-EOF > $exec_tmp_file
		$CXR_AVGDIF_OUTPUT_FILE
		${CXR_REFERENCE_INPUT_FILE}
		${CXR_TEST_INPUT_FILE}
		${CXR_AVGDIF_MIN_LAYER} ${CXR_AVGDIF_MAX_LAYER}
		EOF
		
		# Get a copy of the call
		main.log  "Calling AVGDIF - using this jobfile (be patient)...\n"
		cat ${exec_tmp_file} | tee -a $CXR_LOG
		
		#Dry?
		if [[ "$CXR_DRY" == false  ]]
		then
			# Call AVGDIF (never mind the strange calling convention...)
			$CXR_AVGDIF_EXEC < $exec_tmp_file
		else
			main.log   "This is a dry-run, no action required"    
		fi
		
		# Check if all went well
		# Postprocessor: we only terminate the module
		if [[ $(common.check.postconditions) == false  ]]
		then
			main.log -a "Postconditions for ${CXR_META_MODULE_NAME} are not met, we exit this module."
			common.state.storeStatus ${CXR_STATUS_FAILURE}  > /dev/null
			
			# We notify the caller of the problem
			return $CXR_RET_ERR_POSTCONDITIONS
		fi
		
		common.state.storeStatus ${CXR_STATUS_SUCCESS} > /dev/null
	else
		main.log  "Stage $(common.task.getId) was already started, therefore we do not run it. To clean the state database, run \n \t ${CXR_CALL} -c \n and rerun."
	fi
}

################################################################################
# Function: test_module
#
# Runs the predefined tests for this module. If you add or remove tests, please
# update CXR_META_MODULE_NUM_TESTS in the header!
# 
################################################################################	
function test_module()
################################################################################
{

	########################################
	# Setup tests if needed
	########################################
	
	########################################
	# Tests. If the number changes, change CXR_META_MODULE_NUM_TESTS
	########################################
	
	# None yet.
	:

	########################################
	# teardown tests if needed
	########################################
	
}



