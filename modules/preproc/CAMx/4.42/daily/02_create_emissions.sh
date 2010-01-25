#!/usr/bin/env bash
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
# all_once_preprocessors - all pre_start_preprocessors must have finished
# all_daily_preprocessors - all daily_preprocessors must have finished
# all_model - all model modules must have finished
# all_daily_postprocessors - all daily_postprocessors must have finished
# all_once_postprocessors - all finish_postprocessors must have finished

# the special predicate - refers to the previous model day, so all_model- means that all model modules of the previous day must be successful

CXR_META_MODULE_DEPENDS_ON=""

# Also for the management of parallel tasks
# If this is true, no new tasks will be given out as long as this runs
# Normaly only used for a model or parallelized preprocessors
CXR_META_MODULE_RUN_EXCLUSIVELY=false

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Generates the emissions for the current day by calling Hannes IDL proc"

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}"
CXR_META_MODULE_TYPE="${CXR_TYPE_PREPROCESS_DAILY}"

# If >0 this module supports testing via -t
CXR_META_MODULE_NUM_TESTS=0

# This is the run name that is used to test this module
CXR_META_MODULE_TEST_RUN=base

# Min CAMxRunner Version needed (Revision number)
# We set this ridiculously high for now
CXR_META_MODULE_REQ_RUNNER_VERSION=1049

# Min Revision number of configuration needed (to avoid that old runs try to execute new modules)
# The revision number is automatically extracted from the config file
CXR_META_MODULE_REQ_CONF_VERSION=1049

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2009), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'


# just needed for stand-alone usage help
progname=$(basename $0)
################################################################################

################################################################################
# Function: usage
#
# Shows that this script can only be used from within the CAMxRunner
# For common scripts, remove the reference to CAMxRunner options
#
################################################################################
function usage() 
################################################################################
{
	# At least in theory compatible with help2man
	cat <<EOF

	$progname - A part of the CAMxRunner tool chain.

	Can ONLY be called by the CAMxRunner.
	
	If you want to run just this part of the processing,
	look at the options 
	-D (to process one day),
	-i (a step of the input prep) and 
	-o (a part of the output prep) of the CAMxRunner
	
	Written by $CXR_META_MODULE_AUTHOR
	License: $CXR_META_MODULE_LICENSE
	
	Find more info here:
	$CXR_META_MODULE_DOC_URL
EOF
exit 1
}

################################################################################
# Function: set_create_emissions_variables
#	
# Sets the appropriate variables needed for <convert_emissions>
################################################################################	
function set_create_emissions_variables() 
################################################################################
{	
	# First of all, reset checks.
	# We will later continuously add entries to these 2 lists
	CXR_CHECK_THESE_INPUT_FILES=
	CXR_CHECK_THESE_OUTPUT_FILES=
	
	# We really need the IDL script
	CXR_CHECK_THESE_INPUT_FILES="$CXR_IDL_EMISSION_GENERATOR"
	
	########################################################################
	# Set variables
	########################################################################
	
	# Evaluate some rules
	CXR_EMISSION_OUTPUT_FILE="$(cxr_common_evaluate_rule "$CXR_EMISSION_ASC_FILE_RULE" false CXR_EMISSION_ASC_FILE_RULE)"

	# CXR_CHECK_THESE_OUTPUT_FILES is a space separated list of output files to check
	CXR_CHECK_THESE_OUTPUT_FILES="$CXR_EMISSION_OUTPUT_FILE"

}

################################################################################
# Function: create_emissions
#	
# Generates all emissions needed
################################################################################
function create_emissions() 
################################################################################
{
	# Store the state
	STAGE=${CXR_META_MODULE_TYPE}@${CXR_META_MODULE_NAME}@all_days
	
	#Was this stage already completed?
	if [ $(cxr_common_store_state ${CXR_STATE_START}) == true ]
	then
		#  --- Setup the Environment
		set_create_emissions_variables 
		
		#  --- Check Settings
		if [ $(cxr_common_check_preconditions) == false ]
		then
			cxr_main_logger "${FUNCNAME}" "Preconditions for ${CXR_META_MODULE_NAME} are not met!"
			# We notify the caller of the problem
			return $CXR_RET_ERR_PRECONDITIONS
		fi
		
		if [ ! -f "${CXR_EMISSION_OUTPUT_FILE}" ]
		then
			#File does not exist
		
			# Increase global indent level
			cxr_main_increase_log_indent
	
			cxr_main_logger "${FUNCNAME}"  "Preparing current emission file..."
			
			# We will write the IDL call into a temporary file
			EXEC_TMP_FILE=$(cxr_common_create_tempfile $FUNCNAME)
			
			cxr_main_logger "${FUNCNAME}" "Creating a temporary IDL command file in $EXEC_TMP_FILE"
			
			# Go there
			cd $(dirname ${CXR_IDL_EMISSION_GENERATOR}) || return $CXR_RET_ERROR
			
			# We create the emissions for each grid
			for i in $(seq 1 ${CXR_NUMBER_OF_GRIDS});
			do
				
				cxr_main_logger "${FUNCNAME}" "Creating Emissions for grid $i..."
				
				# Clean Tempfile!
				: > ${EXEC_TMP_FILE}
				
				# Create the file to run IDL
				echo ".run $(basename ${CXR_IDL_EMISSION_GENERATOR})" >> ${EXEC_TMP_FILE}
				
				# We assume (danger, Will Robinson) that Emissions start at hour 0 and end at hour 23
				echo "$(basename ${CXR_IDL_EMISSION_GENERATOR} .pro),${CXR_YEAR},${CXR_MONTH},${CXR_DAY},0,${CXR_YEAR},${CXR_MONTH},${CXR_DAY},23,${i},'${CXR_MET_PROJECT}','${CXR_EMMISS_SCENARIO}','${CXR_MET_SCENARIO}',0,'${CXR_EMISSION_SOURCE_DIR}'" >> ${EXEC_TMP_FILE}
				echo "exit" >> ${EXEC_TMP_FILE}
				
				# Get a copy of the call
				cat ${EXEC_TMP_FILE} | tee -a $CXR_LOG
				
				# Only run if we are not in a dry run
				if [ "$CXR_DRY" == false ]
				then
					# Then we run it, while preserving the output
					${CXR_IDL_EXEC} < ${EXEC_TMP_FILE} 2>&1 | tee -a $CXR_LOG
				else
					cxr_main_logger "${FUNCNAME}"  "This is a dry-run, no action required"
				fi
			done

			# Get back
			cd ${CXR_RUN_DIR}  || return $CXR_RET_ERROR
	
			# Decrease global indent level
			cxr_main_decrease_log_indent
	
			# Check if all went well
			if [ $(cxr_common_check_result) == false ]
			then
				cxr_main_logger "${FUNCNAME}" "Postconditions for ${CXR_META_MODULE_NAME} are not met!"
				# We notify the caller of the problem
				return $CXR_RET_ERR_POSTCONDITIONS
			fi
			
		else
			# File exists. That is generally bad,
			# unless user wants to skip
			if [ "$CXR_SKIP_EXISTING" == true ]
			then
				# Skip it
				cxr_main_logger -w "${FUNCNAME}"  "File $CXR_EMISSION_OUTPUT_FILE exists - because -S option was supplied, file will skipped."
				return 0
			else
				# Fail!
				cxr_main_logger -e "${FUNCNAME}" "File $CXR_EMISSION_OUTPUT_FILE exists - to force the re-creation run ${CXR_CALL} -F"
				return $CXR_RET_ERROR
			fi
		fi

		# Store the state
		cxr_common_store_state ${CXR_STATE_STOP} > /dev/null
	else
		cxr_main_logger "${FUNCNAME}" "${FUNCNAME}:${LINENO} - Stage $(cxr_common_get_stage_name) was already started, therefore we do not run it. To clean the state database, run \n \t ${CXR_CALL} -c \n and rerun."
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
	ERROR_COUNT=0
	TEST_COUNT=1
	
	# This is our test run for this module
	CXR_RUN=CAMx-v4.51-test
	
	# Safety measure if script is not called from .
	MY_DIR=$(dirname $0) && cd $MY_DIR

	# We step down the directory tree until we either find CAMxRunner.sh
	# or hit the root directory /
	while [ $(pwd) != / ]
	do
		cd ..
		# If we find CAMxRunner, we are there
		ls CAMxRunner.sh >/dev/null 2>&1 && break
		
		# If we are in root, we have gone too far
		if [ $(pwd) == / ]
		then
			echo "Could not find CAMxRunner.sh!"
			exit 1
		fi
	done
	
	# Include the init code
	source inc/init_test.inc

	# For this module, testing is harder 
	# compared to date_functions because we cannot just compare
	# Expected with actual results
	create_emissions
	
	echo "For now, you need to inspect the results manually"
	
	exit 1
}


################################################################################
# Are we running stand-alone? 
################################################################################


# If the CXR_META_MODULE_NAME  is a subset of the progname,
# somebody started this script alone
# Normlly this is not allowed, exept to test using -t
if [ $(expr match "$progname" ".*$CXR_META_MODULE_NAME.*") -gt 0 ]
then

	# When using getopts, never directly call a function inside the case,
	# otherwise getopts does not process any parametres that come later
	while getopts ":dvFST" opt
	do
		case "${opt}" in
		
			d) CXR_USER_TEMP_DRY=true; CXR_USER_TEMP_DO_FILE_LOGGING=false; CXR_USER_TEMP_LOG_EXT="-dry" ;;
			v) CXR_USER_TEMP_VERBOSE=true ; echo "Enabling VERBOSE (-v) output. All lines starting with % would not be present otherwise" ;;
			F) CXR_USER_TEMP_FORCE=true ;;
			S) CXR_USER_TEMP_SKIP_EXISTING=true ;;
			
			T) TEST_IT=true;;
			
		esac
	done
	
	# This is not strictly needed, but it allows to read 
	# non-named command line options
	shift $((${OPTIND} - 1))

	# Make getopts ready again
	unset OPTSTRING
	unset OPTIND
	
	# This is needed so that getopts surely processes all parameters
	if [ "${TEST_IT:-false}" == true ]
	then
		test_module
	fi
	
	usage
	
fi

################################################################################
# Code beyond this point is not executed in stand-alone operation
################################################################################



