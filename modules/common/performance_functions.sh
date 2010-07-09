# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Common script for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Contains the Filesystem functions of CAMxRunner.
#
# Written by Daniel C. Oderbolz (CAMxRunner@psi.ch).
# This software is provided as is without any warranty whatsoever. See doc/Disclaimer.txt for details. See doc/Disclaimer.txt for details.
# Released under the Creative Commons "Attribution-Share Alike 2.5 Switzerland"
# License, (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)
################################################################################

################################################################################
# Module Metadata. Leave "-" if no setting is wanted
################################################################################

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}"
CXR_META_MODULE_TYPE="${CXR_TYPE_COMMON}"

# If >0, this module supports testing
CXR_META_MODULE_NUM_TESTS=1

# This is the run name that is used to test this module
CXR_META_MODULE_TEST_RUN=base

# This string describes special requirements this module has
# it is a space-separated list of requirement|value[|optional] tuples.
# If a requirement is not binding, optional is added at the end
CXR_META_MODULE_REQ_SPECIAL="exec|dos2unix exec|unix2dos"

# Min CAMxRunner Version needed (Revision number)
CXR_META_MODULE_REQ_RUNNER_VERSION=100

# Min Revision number of configuration needed (to avoid that old runs try to execute new modules)
# The revision number is automatically extracted from the config file
CXR_META_MODULE_REQ_CONF_VERSION=100

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Contains filesystem functions for the CAMxRunner"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2009), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'


################################################################################
# Function: common.performance.startTiming
# 
# Initializes the most simple wall-clock timer for a given function.
# Stores this value in CXR_TEMP_START_TIME_${module}
#
# Parameters:
# $1 - module name (can be any string)
################################################################################
function common.performance.startTiming()
################################################################################
{
	module=${1}
	currrent_epoch="$(date "+%s")"

	# Store the current epoch in Env
	# let is needed, otherwise the syntax is incorrect
	let CXR_TEMP_START_TIME_${module}="$currrent_epoch"
	
	main.log -v "$module started at $currrent_epoch"
}

################################################################################
# Function: common.performance.stopTiming
# 
# Measures the time difference in seconds, adds it to the universal timing hash
# (a hash of arrays). Once, we use the given module name as key, the second time,
# we use "all" - this can later be used to estimate unknown rumtimes.
#
# Hashes:
# Timing (Universal)
#
# Parameters:
# $1 - module name (can be any string)
################################################################################
function common.performance.stopTiming()
################################################################################
{
	module=${1}
	local time_norm
	
	# Get the current epoch
	local stop_time="$(date "+%s")"
	
	var=CXR_TEMP_START_TIME_${module}
	
	# Get value via indirection
	local start_time=${!var:-}
	
	# We will later loop through this
	local keys="$module all"
	
	if [[ "$start_time" ]]
	then
		
		# Calculate difference
		diff=$(( $stop_time - $start_time ))
		
		# Normalize by cells
		time_norm=$(common.math.FloatOperation "$diff / $CXR_TIME_NORM_FACTOR" -1 false)
		
		if [[ $time_norm -lt 1 ]]
		then
			main.log -v "Normalized difference $time_norm is small. That might be a hint that CXR_TIME_PER_CELLS ($CXR_TIME_PER_CELLS) is too small"
		fi
		
		
		# Do a few things for two hashes
		for key in $keys
		do
		
			# Get time array, if any
			# then add our time as new element
			if [[ $(common.hash.has? Timing $CXR_HASH_TYPE_UNIVERSAL "$key") == true ]]
			then
				time_array=( $(common.hash.get Timing $CXR_HASH_TYPE_UNIVERSAL "$key") )
			else
				time_array=()
			fi
			
			# Get last index
			last_index=${#time_array[@]}
			
			# There is a limit on the number of entries
			if [[ $last_index -eq $CXR_TIME_MAX_ENTRIES ]]
			then
				# Then we add this one at the beginning (normally, we add at the end)
				last_index=0
			fi
			
			time_array[$last_index]=$time_norm
			arr_string="${time_array[@]}"
			
			# Store in Hash
			common.hash.put Timing $CXR_HASH_TYPE_UNIVERSAL "$key" "$arr_string"
		
		done
		
	else
		# Was not in hash
		main.log -e "Module $module has no start time information. Maybe common.performance.startTiming was not run?"
	fi
}

################################################################################
# Function: common.performance.estimateRuntime
# 
# Estimates the runtime in seconds of a given module for the current problem size.
# This estimation is based on the mean and standard deviation of the runtimes of the
# given module measured so far (we just add 1 sigma).
#
# If this module has no performance data yet, we use the "all" entry.
#
# Hashes:
# Timing (Universal)
# Cache_Performance (Universal)
#
# Parameters:
# $1 - module name
################################################################################
function common.performance.estimateRuntime()
################################################################################
{
	local module=${1}
	local mean
	local stddev
	local estimate
	
	# This call sets _has and _value
	common.hash.has? Cache_Performance $CXR_HASH_TYPE_UNIVERSAL "$module" > /dev/null
	if [[ $_has == true ]]
	then
		# Got it
		echo $_value
	else
		# Not cached yet
		
		if [[ $(common.hash.has? Timing $CXR_HASH_TYPE_UNIVERSAL "$module") == true ]]
		then
			time_array=( $(common.hash.get Timing $CXR_HASH_TYPE_UNIVERSAL "$module") )
		else
			if [[ $(common.hash.has? Timing $CXR_HASH_TYPE_UNIVERSAL "all") == true ]]
			then
				time_array=( $(common.hash.get Timing $CXR_HASH_TYPE_UNIVERSAL "all") )
			else
				main.log -w "Cannot find any timing data."
				echo 0
				return $CXR_RET_OK
			fi
		fi
	
		mean=$(common.math.meanVector "${time_array[@]}")
		stddev=$(common.math.stdevVector "${time_array[@]}" "$mean")
		# We use mean + 1 sigma as estimate, we need to multply with cell factor to get it right
		estimate=$(common.math.FloatOperation "($mean + $stddev) * $CXR_TIME_NORM_FACTOR" -1 )
		
		# Add to cache
		common.hash.put Cache_Performance $CXR_HASH_TYPE_UNIVERSAL "$module" "$estimate"
		
		echo $estimate
	fi
}

################################################################################
# Function: test_module
#
# Runs the predefined tests for this module
# 
################################################################################
function test_module()
################################################################################
{
	########################################
	# Setup tests if needed
	########################################
	
	local nSeconds=5
	local time
	local arr
	local difference
	
	# We accept one second difference
	local epsilon=1
	
	main.log -a "We will now wait $nSeconds seconds to test timing..."
	
	common.performance.startTiming test
	sleep $nSeconds
	common.performance.stopTiming test
	
	########################################
	# Tests. If the number changes, change CXR_META_MODULE_NUM_TESTS
	########################################
	
	# Load the performance array
	arr=( $(common.hash.get Timing $CXR_HASH_TYPE_UNIVERSAL test) )
	
	# Measured time is in the last entry
	time=${arr[$(( ${#arr[@]} - 1 ))]}
	
	difference=$(common.math.abs $(common.math.FloatOperation "$nSeconds - $time" 0 false))
	
	# We test for difference
	is_less_or_equal $difference $epsilon "common.performance Timing of sleep"

	########################################
	# teardown tests if needed
	########################################
	
}
