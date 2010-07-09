# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Common script for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Contains CAMx Runner Functions
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

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}"
CXR_META_MODULE_TYPE="${CXR_TYPE_COMMON}"

# If >0, this module supports testing
CXR_META_MODULE_NUM_TESTS=4

# This is the run name that is used to test this module
CXR_META_MODULE_TEST_RUN=base

# Min CAMxRunner Version needed (Revision number)
CXR_META_MODULE_REQ_RUNNER_VERSION=100

# Min Revision number of configuration needed (to avoid that old runs try to execute new modules)
# The revision number is automatically extracted from the config file
CXR_META_MODULE_REQ_CONF_VERSION=100

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Contains functions for the CAMxRunner (creation of new runs, module calls, process management)"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2009), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'


################################################################################
# Function: common.runner.getX
# 
# Returns the x dimension  of a given grid (in grid cells of this grid)
# Hides the fact that the configuration is different for master and non-master grids.
# Note that for nested domains, the 2 buffer cells are added
#
# Parameters:
#
# $1 - A integer denoting the domain for which we need the dim (in the range 1..CXR_NUMBER_OF_GRIDS)
################################################################################
function common.runner.getX()
################################################################################
{
	local domain=${1}
	local xdim
		
	if [[  ! ( ${domain} -ge 1 && ${domain} -le ${CXR_NUMBER_OF_GRIDS} )   ]]
	then
		main.dieGracefully "Domain $domain is out of the range 1..${CXR_NUMBER_OF_GRIDS}"
	fi
	
	if [[ "${domain}" == 1  ]]
	then
		# Master Grid
		xdim=${CXR_MASTER_GRID_COLUMNS}
	else
		# Any other grid
		xdim=$(( (((${CXR_NEST_END_I_INDEX[${domain}]} - ${CXR_NEST_BEG_I_INDEX[${domain}]}) + 1) * ${CXR_NEST_MESHING_FACTOR[${domain}]}) + 2))
		#                                                                        |                                      |
		#                                                                    Fencepost                                  |
		#                                                                                                            Buffer Cells (left/right)
	fi
	
	echo ${xdim}
}

################################################################################
# Function: common.runner.getY
# 
# Returns the y dimension  of a given grid (in grid cells of this grid)
# Hides the fact that the configuration is different for master and non-master grids
# Note that for nested domains, the 2 buffer cells are added
#
# Parameters:
#
# $1 - A integer denoting the domain for which we need the dim (in the range 1..CXR_NUMBER_OF_GRIDS)
################################################################################
function common.runner.getY()
################################################################################
{
	local domain=${1:-0}
	local ydim
	
	if [[  ! ( ${domain} -ge 1 && ${domain} -le ${CXR_NUMBER_OF_GRIDS} )   ]]
	then
		main.dieGracefully "domain $1 is out of the range 1..${CXR_NUMBER_OF_GRIDS}"
	fi
	
	if [[ "${domain}" == 1  ]]
	then
		# Master Grid
		ydim=${CXR_MASTER_GRID_ROWS}
	else
		# Any other grid
		ydim=$(( (((${CXR_NEST_END_J_INDEX[${domain}]} - ${CXR_NEST_BEG_J_INDEX[${domain}]}) + 1) * ${CXR_NEST_MESHING_FACTOR[${domain}]}) + 2 ))
		#                                                                        |                                      |
		#                                                                    Fencepost                                  |
		#                                                                                                            Buffer Cells (up/down)
	fi
			
	echo ${ydim}
	
}

################################################################################
# Function: common.runner.getZ
# 
# Returns the z dimension  of a given grid (in grid cells of this grid)
# Hides the fact that the configuration is different for master and non-master grids
#
# Parameters:
#
# $1 - A integer denoting the domain for which we need the dim (in the range 1..CXR_NUMBER_OF_GRIDS)
################################################################################
function common.runner.getZ()
################################################################################
{
	domain=${1:-0}
	
	if [[  ! ( ${domain} -ge 1 && ${domain} -le ${CXR_NUMBER_OF_GRIDS} )   ]]
	then
		main.dieGracefully "domain $1 is out of the range 1..${CXR_NUMBER_OF_GRIDS}"
	fi
	
	echo ${CXR_NUMBER_OF_LAYERS[${domain}]}
	
}

################################################################################
# Function: common.runner.getMaxX
# 
# Returns the maximum x dimension of all grids 
# Useful for compiling CAMx
#
################################################################################
function common.runner.getMaxX()
################################################################################
{
	local new
	local max_xdim=0
	local iGrid
	
	for iGrid in $(seq 1 $CXR_NUMBER_OF_GRIDS);
	do
		new="$(common.runner.getX $iGrid)"
		
		if [[ "$new" -gt "$max_xdim"  ]]
		then
			max_xdim=$new
		fi
	done
	
	echo ${max_xdim}
}

################################################################################
# Function: common.runner.getMaxY
# 
# Returns the maximum y dimension of all grids 
# Useful for compiling CAMx
#
################################################################################
function common.runner.getMaxY()
################################################################################
{
	local new
	local max_ydim=0
	local iGrid
	
	for iGrid in $(seq 1 $CXR_NUMBER_OF_GRIDS);
	do
		new="$(common.runner.getY $iGrid)"
		
		if [[ "$new" -gt "$max_ydim"  ]]
		then
			max_ydim=$new
		fi
	done
	
	echo ${max_ydim}
}

################################################################################
# Function: common.runner.getMaxZ
# 
# Returns the maximum z dimension of all grids 
# Useful for compiling CAMx
#
################################################################################
function common.runner.getMaxZ()
################################################################################
{
	local new
	local max_zdim=0
	local iGrid
	
	for iGrid in $(seq 1 $CXR_NUMBER_OF_GRIDS);
	do
		new="$(common.runner.getZ $iGrid)"
		
		if [[ "$new" -gt "$max_zdim"  ]]
		then
			max_zdim=$new
		fi
	done
	
	echo ${max_zdim}
}

################################################################################
# Function: common.runner.countCells3D
# 
# Returns the sum of the number of cells in all grids (3D)
# Used by <common.check.PredictModelOutputMb>
#
################################################################################
function common.runner.countCells3D()
################################################################################
{
	local new
	local sum=0
	local iGrid
	
	for iGrid in $(seq 1 $CXR_NUMBER_OF_GRIDS);
	do
		sum=$(( $sum + ( $(common.runner.getX $iGrid) * $(common.runner.getY $iGrid) * $(common.runner.getZ $iGrid) ) ))
	done
	
	echo $sum
}

################################################################################
# Function: common.runner.countCells2D
# 
# Returns the sum of the number of cells in all grids (Just lowest layer)
# Used by <common.check.PredictModelOutputMb>
#
################################################################################
function common.runner.countCells2D()
################################################################################
{
	local new
	local sum=0
	local iGrid
	
	for iGrid in $(seq 1 $CXR_NUMBER_OF_GRIDS);
	do
		sum = $(( $sum + ( $(common.runner.getX $iGrid) * $(common.runner.getY $iGrid) ) ))
	done
	
	echo $sum
}

################################################################################
# Function: common.runner.reportDimensions
# 
# Prints the dimensions of all the defined grids.
#
################################################################################
function common.runner.reportDimensions()
################################################################################
{
	local iGrid
	local nCells
	
	for iGrid in $(seq 1 $CXR_NUMBER_OF_GRIDS);
	do
		main.log -B "Grid dimensions domain ${iGrid}:\nX: $(common.runner.getX ${iGrid})\nY: $(common.runner.getY ${iGrid})\nZ: $(common.runner.getZ ${iGrid})"
	done
	
	nCells="$(common.runner.countCells3D)"
	
	main.log -B "Total number of cells: $nCells"
	
	# Set factor to correct times (integer division)
	CXR_TIME_NORM_FACTOR=$(( $nCells / $CXR_TIME_PER_CELLS ))
	
	# This factor must be >= 1
	if [[ $CXR_TIME_NORM_FACTOR -lt 1 ]]
	then
		CXR_TIME_NORM_FACTOR=1
	fi
	
	main.log -v "Time normalisation factor: $CXR_TIME_NORM_FACTOR"
	
}

################################################################################
# Function: common.runner.evaluateRule
# 
# Evaluates a filerule and returns its expansion. Removes syntactical fluff unknown
# to non-bashers.
# If it is a file rule, the file might be compressed, <common.fs.TryDecompressingFile> is called.
#
# Side effect: if the file is compressed and we cannot decompress in place,
# the returned file name will change. If you want the "expected" file name,
# use the fourth parameter.
# ABSOLUTELY use this parameter for any OUTPUT_FILE because if the output would have been 
# compressed, CAMxRunner would decompress it, wich makes no sense.
#
# The evaluator tests if the resulting dirname exists (_FILE_RULE only). This is needed if your rules
# contain things like /${VAR}/... because we have no way of knowing this name in the checker.
#
# To be on the safe side, quote the call (double quotes!)
#
# Examples:
# This code does not if the rule expands to the empty string:
# >MY_DIR="$(common.runner.evaluateRule "$RULE" false "$rule_name")"
# >These  ^                                                ^
# >Ensure that the code does not fail if the string returned contains
# >spaces.
#
# This code accepts an empty string:
# >MY_DIR="$(common.runner.evaluateRule "$RULE" true "$rule_name")" 
#
# This code is also valid and will not fail on empty expansion:
# >MY_DIR="$(common.runner.evaluateRule "$RULE")"
#
# You can use it to generate any string that is made up by variables,
# but make sure that control sequences like \n are double-escaped (\\n)
# because the expansion otherwise removes the sequence:
#
# >CXR_FINISH_MESSAGE_RULE='Please copy this into https://wiki.intranet.psi.ch/twiki/LAC/CAMxRuns \\n \| $(date +"%Y/%M/%D") \| ${USER} \| ${CXR_STATUS} \| ${CXR_RUN} \| ${CXR_START_DATE} \| ${CXR_STOP_DATE} \| http://people.web.psi.ch/oderbolz/CAMx/conf/$(basename $CXR_CONFIG) \| http://people.web.psi.ch/oderbolz/CAMx/log/$(basename $CXR_LOG) \| \\n'
# ...
# >main.log  "$(common.runner.evaluateRule "$CXR_FINISH_MESSAGE_RULE" true CXR_FINISH_MESSAGE_RULE)"
#
# Parameters:
# $1 - The rule to be evaluated (a string, not a variable)
# [$2] - allow_empty if false, a rule must expand to a non-empty string
# [$3] - optional name of the rule
# [$4] - try_decompression if false, will not attempt compression (and consequenital renaming)
################################################################################
function common.runner.evaluateRule()
################################################################################
{
	if [[  $# -lt 1 || $# -gt 4 ]]
	then
		main.dieGracefully "needs at least string (the rule) as input, at most the rule, true/false, the rule name and true/false!"
	fi	
	
	local rule="$1"
	
	# Per default we allow rules to expand to the empty string
	local allow_empty="${2:-true}"
	local rule_name="${3:-}"
	# By default try decompression
	local try_decompression="${4:-true}"
	local expansion
	
	if [[ -z "$rule" ]]
	then
		# If the rule is empty, we evaluate to empty
		main.log -v   "rule $rule_name was empty..."
		expansion=""
	else
		# Non-empty rule - do it
		main.log -v   "Evaluating rule $rule_name $rule..."
	
		# Original code example: CXR_ROOT_OUTPUT=$(eval "echo $(echo $CXR_ROOT_OUTPUT_FILE_RULE)")
		expansion="$(eval "echo $(echo "$rule")")"
		
		main.log -v  "Evaluated rule: $expansion"
		
		# *_FILE_RULE might be compressed
		# Does the name of the rule end in _FILE_RULE ?
		if [[ "${rule_name: -10}" == "_FILE_RULE" ]]
		#                 �
		# This space here � is vital, otherwise, bash thinks we mean a default (see http://tldp.org/LDP/common.math.abs/html/string-manipulation.html)
		then
			if [[ "${try_decompression}" == true ]]
			then
				# Try to decompress
				expansion=$(common.fs.TryDecompressingFile $expansion)
			else
				main.log -v  "No decompression attempted."
			fi # try_decompression
		fi
		main.log -v  "Evaluated rule: $expansion"
	fi
	
	# Test if expansion is empty but shouldn't
	if [[ -z "$expansion" ]]
	then
		# Empty
		if [[ "$allow_empty" == false ]]
		then
			# Empty not allowed
			main.dieGracefully "Rule $rule_name was expanded to the empty string which is not allowed in this context!"
		fi
	else
		# Not empty. Test if the dirname exists, but only if its a FILE_RULE
		# Does the name of the rule end in _FILE_RULE ?
		if [[ "${rule_name: -10}" == "_FILE_RULE" ]]
		#                 �
		# This space here � is vital, otherwise, bash thinks we mean a default (see http://tldp.org/LDP/common.math.abs/html/string-manipulation.html)
		then
			expansion_dir="$(dirname "$expansion")"
			if [[ ! -d "${expansion_dir}" ]]
			then
				# Dirname does not exists
				main.log -w "Dir $expansion_dir does not exist - creating it..."
				mkdir -p "$expansion_dir"
			fi
		fi
	fi
	
	echo "$expansion"
}

################################################################################
# Function: common.runner.evaluateRule
# 
# Evaluates a filerule for a given simulation day offset (0..NUMBER_OF_SIM_DAYS-1).
# This is especially useful to determine how certain things where at the first day of 
# a simulation (e. g. a filename).
# The function needs to re-evaluate the date variables, but takes care to reset them properly.
#
# Parameters:
# $1 - The rule to be evaluated (a string, not a variable)
# $2 - The offset of the simulation day (0..NUMBER_OF_SIM_DAYS-1)
# [$3] - allow_empty if false, a rule must expand to a non-empty string
# [$4] - optional name of the rule
################################################################################
function common.runner.evaluateRuleAtDayOffset()
################################################################################
{
	if [[  $# -lt 2 || $# -gt 4 ]]
	then
		main.dieGracefully "needs at least one string (the rule) and one number (the day offset) as input!"
	fi
	
	# Local variables
	local current_offset
	local rule
	local day_offset
	local expansion
	
	rule="$1"
	day_offset="$2"

	# First store current offset
	current_offset=${CXR_DAY_OFFSET}
	
	# Re-evaluate the date variables
	common.date.setVars "${CXR_START_DATE}" "${day_offset}"
	
	# Evaluate the rule
	expansion=$(common.runner.evaluateRule "${rule}" "${3:-}" "${4:-}")
	
	# Reset Current offset
	CXR_DAY_OFFSET=${current_offset}
	
	# Reset the date vars
	common.date.setVars "${CXR_START_DATE}" "${CXR_DAY_OFFSET}"
	
	echo "$expansion"
}

################################################################################
# Function: common.runner.evaluateScalarRules
# 
# Evaluates all CXR_*_RULE environment variables in the given list.
#
# Arrays can *not* expanded using this technique!
#
# $1 - The list of rules to be evaluated (a space-separated string, not a variable)
# [$2] - allow_empty if false, *all* rules in the must expand to a non-empty string
################################################################################
function common.runner.evaluateScalarRules()
################################################################################
{
	if [[  $# -lt 1 || $# -gt 2   ]]
	then
		main.dieGracefully "needs a string (the list of rules) as input and optionally a boolean allow_empty value!"
	fi
	
	local rule_list="$1"
	local current_rule
	local variable
	
	# Per default we allow rules te expand to the empty string
	allow_empty=${2:-true}
		
	# Read the relevant rules from the environment and
	
	# Loop through them
	for current_rule in $rule_list
	do
		# Chop off _RULE
		# So e. g. CXR_FINISH_MESSAGE_RULE turns into CXR_FINISH_MESSAGE
		variable=${current_rule%_RULE}
		
		# Set variable to its evaluated form
		export $variable="$(common.runner.evaluateRule "${current_rule}" "$allow_empty" $current_rule)"
	done
}


################################################################################
# Function: common.runner.createDummyFile
#
# Creates a dummy file, shows a message and adds the file
# to the dummy file list. The size can be chosen if 
#
# Parameters:
# $1 - Filename
# [$2] - size in MB (Default 1)
################################################################################
function common.runner.createDummyFile()
################################################################################
{
	local filename="$1"
	local size="${2:-1}"
	
	main.log "Creating Dummy $filename of size $size"
	
	if [[ $(main.isNumeric? $size) == false ]]
	then
		main.log -w "You must supply a numeric size in MB. Using 1 MB now."
		size=1
	fi
	
	# Create file
	if [[ ! -f "$filename" ]]
	then
		dd bs=${size}M if=/dev/zero of=$filename count=1
	fi
	
	# Store Dummy file in the file hash (dummy value)
	common.hash.put $CXR_INSTANCE_HASH_DUMMY_FILES $CXR_HASH_TYPE_INSTANCE $filename dummy

	return 0
}

################################################################################
# Function: common.runner.createTempFile
#
# Returns the name of a temporary file with random name, shows a message and adds the file
# to the temp file list if this is needed. 
# Replaces calls to mktemp and removes the need to remove the temp files, this is done by 
# <common.runner.removeTempFiles>
#
# Recommended call:
# >TMPFILE=$(common.runner.createTempFile $FUNCNAME)
#
# Parameters:
# [$1] - identifier of tempfile, recommended to use $FUNCNAME
# [$2] - store, if false, we do not add the file to list. This is useful if we keep track of the files ourselves (e. g. when decompressing files)
################################################################################
function common.runner.createTempFile()
################################################################################
{
	
	if [[ ! -d "${CXR_TMP_DIR}" ]]
	then
		mkdir -p "${CXR_TMP_DIR}"
	fi
	
	# Check if that worked!
	if [[ ! -d "${CXR_TMP_DIR}" ]]
	then
		main.dieGracefully "could not create tmp directory ${CXR_TMP_DIR} (maybe its a broken Link?), CAMxRunner cannot continue."
	fi
	
	local store=${2:-true}
	
	# Create a template by using $1 
	# and adding 8 random alphanums
	# This way, the filename has a meaning
	local template="${CXR_TMP_DIR}/${CXR_TMP_PREFIX}${1:-temp}.XXXXXXXX"

	# replace eventual spaces by _
	template=${template// /_}
	
	local filename=$(mktemp $template)
	main.log -v   "Creating temporary file $filename"
	
	if [[ "${store}" == true  ]]
	then
		# Add to hash (value is a dummy)
		common.hash.put $CXR_INSTANCE_HASH_TEMP_FILES $CXR_HASH_TYPE_INSTANCE $filename dummy
	fi
	
	echo $filename
	return 0
}

################################################################################
# Function: common.runner.removeTempFiles
#
# Removes all files from the temp file list if CXR_REMOVE_TEMP_FILES is true.
# Also removes decompressed files if requested.
#
################################################################################
function common.runner.removeTempFiles()
################################################################################
{
	local line
	local filename
	local temp_file
	
	# remove decompressed files, if wanted
	# each removed file is also removed from the global list
	if [[ "$CXR_REMOVE_DECOMPRESSED_FILES" == true  ]]
	then
			main.log  "Removing temporarily decompressed files..."
			
			# common.hash.getKeys returns a CXR_DELIMITER delimited string
			oIFS="$IFS"
			local keyString="$(common.hash.getKeys $CXR_GLOBAL_HASH_DECOMPRESSED_FILES $CXR_HASH_TYPE_GLOBAL)"
			IFS="$CXR_DELIMITER"
			
			 # Turn string into array (we cannot call <common.hash.getKeys> directly here!)
			local arrKeys=( $keyString )
			
			# Reset Internal Field separator
			IFS="$oIFS"
			
			# Clean files away
			for iKey in $( seq 0 $(( ${#arrKeys[@]} - 1)) )
			do
				compressed_filename=${arrKeys[$iKey]}
				# the value is the name of the decompressed file
				filename="$(common.hash.get $CXR_GLOBAL_HASH_DECOMPRESSED_FILES $CXR_HASH_TYPE_GLOBAL "$compressed_filename")"
				
				main.log -v "Deleting $filename"
				rm -f "${filename}" >/dev/null 2>&1
			done
			
			IFS="$oIFS"
	else
		main.log  "The temporarily decompressed files will not be deleted because the variable CXR_REMOVE_DECOMPRESSED_FILES is false."
	fi

	# remove temporary files, if wanted
	if [[ "$CXR_REMOVE_TEMP_FILES" == true  ]]
	then
			main.log  "Removing temporary files..."
			
			# common.hash.getKeys returns a CXR_DELIMITER delimited string
			oIFS="$IFS"
			local keyString="$(common.hash.getKeys $CXR_INSTANCE_HASH_TEMP_FILES $CXR_HASH_TYPE_INSTANCE)"
			IFS="$CXR_DELIMITER"
			
			 # Turn string into array (we cannot call <common.hash.getKeys> directly here!)
			local arrKeys=( $keyString )
			
			# Reset Internal Field separator
			IFS="$oIFS"
			
			# Clean files away
			for iKey in $( seq 0 $(( ${#arrKeys[@]} - 1)) )
			do
				temp_file=${arrKeys[$iKey]}
			
				main.log -v "Deleting $temp_file"
				
				rm -f "$temp_file" >/dev/null 2>&1
				
				# Remove from hash
				common.hash.delete $CXR_INSTANCE_HASH_TEMP_FILES $CXR_HASH_TYPE_INSTANCE "$temp_file"
			done
			
			IFS="$oIFS"
	else
		main.log  "The temporary files will not be deleted because the variable CXR_REMOVE_TEMP_FILES is false."
	fi
}

################################################################################
# Function: common.runner.waitForLock
#
# Waits until a lock is released without getting it. 
# Locks can have three levels (like hashes) 
# When the lock is not free, we wait up to CXR_MAX_LOCK_TIME seconds, then return false in _retval
#
# Recommended call:
# > common.runner.waitForLock NextTask "$CXR_HASH_TYPE_INSTANCE"
# > if [[ $_retval == false ]]
# > then
# > 	main.dieGracefully "Waiting for NextTask lock took too long"
# > fi
#
# Parameters:
# $1 - the name of the lock to get
# $2 - the level of the lock, either of "$CXR_HASH_TYPE_INSTANCE", "$CXR_HASH_TYPE_GLOBAL" or "$CXR_HASH_TYPE_UNIVERSAL"
# [$3] - wantsLock: boolean flag (default false), if true, we would like to have the lock later
################################################################################
function common.runner.waitForLock()
################################################################################
{
	if [[ $# -lt 2 || $# -gt 3 ]]
	then
		main.dieGracefully "needs the name of a lock, a level and an optional intention as input"
	fi
	
	local lock="$1"
	local level="$2"
	local wantsLock="${3:-false}"
	local procsWaiting=0
	local myId
	local wait_array
	local arr_string
	_retval=true
	
	# how long did we wait?
	local time=0
	
	########################################
	# Notify system if we want the lock
	########################################
	if [[ "$wantsLock" == true ]]
	then
		# If the lock is not set, its our turn
		_turn=1
		
		# should we add this one?
		local add=true
		local currPid
	
		# We use our pid as id
		myId=$$
		
		wait_str="$(common.hash.get Locks "$level" "wait_${lock}")"
		
		if [[ "$wait_str" ]]
		then 
			
			# Add this processes to the waiting queue if its not already there
			wait_array=( $wait_str )
			
			# Search for this process
			for currPid in ${wait_array[@]}
			do 
				if [[ $currPid == $myId ]]
				then
					add=false
					break
				fi
			done
			
		else
			add=true
		fi
		
		if [[ $add == true ]]
		then
		
			# Was there something?
			if [[ "$wait_str" ]]
			then 
				# There was data already
				# Get last index
				last_index=${#wait_array[@]}
				
				wait_array[$last_index]=$myId
				arr_string="${wait_array[@]}"
			
			else
				# Start from scratch
				wait_array[0]=$myId
				arr_string="${wait_array[@]}"
			fi
			
			# Store in Hash
			common.hash.put Locks "$level" "wait_${lock}" "$arr_string"
		fi
	fi
	
	########################################
	# We wait until lock is free or Continue file is gone.
	########################################		
	while [[ $(common.hash.has? Locks "$level" "$lock") == true && -f ${CXR_CONTINUE_FILE} ]]
	do
		main.log -v "Waiting for lock $lock."
		
		# We need to check if we are in position 1
		if [[ "$wantsLock" == true ]]
		then
			wait_array=( $(common.hash.get Locks "$level" "wait_${lock}") )
			
			procsWaiting=${#wait_array[@]}
			
			if [[ $procsWaiting -eq 1 ]]
			then
				# Nobody else waits - we may proceed
				_turn=1
			else
				# There are still others. Lets see if we where first.
				# If the value added last is my id, we are in!
				# since we add at the back, the oldest is in position 0
				if [[ ${wait_array[0]} -eq $myId ]]
				then
					_turn=1
				else
					_turn=0
				fi
			fi
		fi
		
		sleep 10
		time=$(( $time + 10 ))
		
		if [[ $time -gt $CXR_LOCK_TIMEOUT_SEC ]]
		then
			main.log -w "Lock $lock (${level}) took longer than CXR_MAX_LOCK_TIME to get!"
			_retval=false
			return $CXR_RET_ERROR
		fi
	done # is lock set?
	
	if [[ ! -f ${CXR_CONTINUE_FILE} ]]
	then
		main.dieGracefully "Continue file is gone."
	else
		_retval=true
	fi
}

################################################################################
# Function: common.runner.getLock
#
# Tries to get a lock. If we get the lock, it will be added to the 
# gobal Lock Hash and returns true.
# Locks can have three levels (like hashes) 
# This allows to release the locks later when we exit from the program.
# When the lock is not free, we wait up to CXR_MAX_LOCK_TIME seconds, then return false.
#
# The problem is that here, locking is not atomic, so 2 processes could try
# to get the same lock. We try to detect this situation.
# (Even better would be an implementation of a general form of Peterson's or Dekkers algorithm...)
#
# Example:
# > if [[ $(common.runner.getLock NextTask "$CXR_HASH_TYPE_INSTANCE") == false ]]
# > then
# > 	main.dieGracefully "Could not get NextTask lock"
# > fi
#
# Parameters:
# $1 - the name of the lock to get
# $2 - the level of the lock, either of "$CXR_HASH_TYPE_INSTANCE", "$CXR_HASH_TYPE_GLOBAL" or "$CXR_HASH_TYPE_UNIVERSAL"
################################################################################
function common.runner.getLock()
################################################################################
{
	if [[ $# -ne 2 ]]
	then
		main.dieGracefully "needs the name of a lock and a level as input"
	fi
	
	local lock="$1"
	local level="$2"
	
	# If turn is 1 we can get a lock.
	local turn=0
	local wait_array
	local arr_string

	# For debug reasons, locking can be turned off
	if [[ $CXR_NO_LOCKING == false ]]
	then
		
		main.log -v "Waiting to set lock $lock..."
		
		while [[ $turn -ne 1 ]]
		do
			
			# Wait for the lock, _retval is false if we exceeded the timeout
			common.runner.waitForLock "$lock" "$level" true
			
			if [[ $_retval == false ]]
			then
				# Took to long...
				echo false
				return $CXR_RET_ERROR
			fi
			
			# common.runner.waitForLock decides if its our turn
			turn=$_turn
			
			# We only get the lock if its our turn
			if [[ $turn -eq 1 ]]
			then
				# Add lock to hash (value is a dummy)
				common.hash.put Locks "$level" "$lock" dummy
				
				# Remove our id from the queue
				wait_array=( $(common.hash.get Locks "$level" "wait_${lock}") )
				
				# Now lets cut off the 0th element (using a string operator thast works perfectly on 
				# an array
				arr_string="${wait_array[@]:1}"
		
				# Store in Hash
				common.hash.put Locks "$level" "wait_${lock}" "$arr_string"
				
				main.log -v "Got lock $lock. (${level})"
				break
			else
				# try again
				continue
			fi
		done
		
	else
		main.log -w "CXR_NO_LOCKING is false, logging is turned off - no lock acquired."
	fi
	
	echo true
}

################################################################################
# Function: common.runner.releaseLock
#
# Releases a lock by removing the relevant hash entry.
#
# Recommended call:
# > common.runner.releaseLock lockname
#
# Parameters:
# $1 - the name of the lock to release
# $2 - the level of the lock, either of "$CXR_HASH_TYPE_INSTANCE", "$CXR_HASH_TYPE_GLOBAL" or "$CXR_HASH_TYPE_UNIVERSAL"
################################################################################
function common.runner.releaseLock()
################################################################################
{
	if [[ $# -ne 2  ]]
	then
		main.dieGracefully "needs the name of a lock  and a lock-level as input"
	fi
	
	local lock="$1"
	local level="$2"
	
	main.log -v   "Waiting to release lock $lock..."

	# We even release locks if locking is turned off
	common.hash.delete Locks "$level" "$lock"
	
	main.log -v   "lock $lock released."
}

################################################################################
# Function: common.runner.releaseAllLocks
#
# Releases all locks held by removing the relevant hash
#
#
# Parameters:
# None.
################################################################################
function common.runner.releaseAllLocks()
################################################################################
{
	# Just destroy the hash
	common.hash.destroy Locks $CXR_HASH_TYPE_GLOBAL
}

################################################################################
# Function: common.runner.createConfigFile
#
# Interactively creates a new configuration file for a run. 
#
# Can derive a new file from any given config file - also takes care of expansion.
# Also can create a new file using an .ask file, similar to the installer of CAMxRunner
#
# Parameters:
# $1 - Run-name
################################################################################	
function common.runner.createConfigFile() 
################################################################################
{
	local run="$1"
	local basefile
	local template
	local destination
	local askfile
	local playfile
	local tmpfile
	
	if [[ $(common.user.getOK "We create a configuration file for the new run now.\n Do you want to copy an existing file? (If you say no, you will be asked the values of the new configuration instead)" ) == true  ]]
	then

		# Show a list of existing files to choose from
		if [[ $(common.user.getOK "Do you want to use a file other than \n $(basename ${CXR_BASECONFIG}) as as starting point?" ) == false  ]]
		then
			#No, use base.conf
			basefile=${CXR_BASECONFIG}
		else
			#Yes, gimme options
			
			# To keep the list compact, we go into the conf dir and back out again
			cd "${CXR_CONF_DIR}" || main.dieGracefully "Could not change to ${CXR_CONF_DIR}!"
			
			basefile=${CXR_CONF_DIR}/$(common.user.getMenuChoice "Choose a file I should use:" "*.conf" )
			
			cd "$CXR_RUN_DIR" || main.dieGracefully "Could not change to $CXR_RUN_DIR"
		fi
	
		if [[ ! -f "$basefile"  ]]
		then
			main.dieGracefully "File $basefile is not readable!"
		fi
	
		# For the moment, I romoved the option to expand a config
		# Tell user if expand is on and let the user decide
		
#		if [ $(common.user.getOK "Do you want to expand the new configuration?\n \
#This means that any variable in $basefile that is not protected by \
#single quotes will be expanded to its value and then be written to the new configuration file. \
#This makes everything in it static, allowing you to preserve the actual settings used. \
#However, this can also be a disadvantage!" N ) == true ]
#		then
#			# Yes, expand.
#			common.runner.expandConfigFile ${CXR_BASECONFIG} ${CXR_EXPANDED_CONFIG}
#		else
			#No expansion, just copy.
		
			# Is the file already there?
			if [[ -f ${CXR_CONFIG}  ]]
			then
				# Continue even if file is there?
				if [[ $(common.user.getOK "${CXR_CONFIG} already exists. Do you want to overwrite this file?" ) == false  ]]
				then
					exit
				fi
			fi
		
			# The user just wants a copy
			# copy base config and make sure some file is present
			cp  ${basefile} ${CXR_CONFIG}
			touch ${CXR_CONFIG}
			chmod +x ${CXR_CONFIG}

#		fi # Decision to expand 

	else
		# The user wants to be asked a lot of questions.
		
		# This is for the replacement later
		basefile=base.conf

		# The template we use (can be chosen more elaborate, maybe)
		template="${CXR_TEMPLATES_DIR}/conf/base.tpl"

		destination="${CXR_CONF_DIR}/${run}.conf"

		if [[ -f "$destination"  ]]
		then
			# Continue even if file is there?
			if [[ $(common.user.getOK "$destination already exists. Do you want to overwrite this file?" N ) == false  ]]
			then
				exit
			fi
		fi

		# Let's first copy the template
		cp "$template" "$destination"
		
		# We will now ask the user a number of questions encoded in an ask-file
		# The result will be a play-file
		askfile=${CXR_INSTALLER_VERSION_INPUT_DIR}/base.ask
		playfile=${CXR_CONF_DIR}/${run}.play
		
		# Might be simplified later
		if [[ -s "$playfile"  ]]
		then
			# We already have a playfile
			# Do you want to replay?
			if [[ "$(common.user.getOK "Such a config file was already created. Do you want to look at the settings that where used then? (You will then be asked if you want to reinstall using those values)" Y )" == true  ]]
			then
				# Yes, show me
				cat "$playfile"
				
				if [[ "$(common.user.getOK "Should this installation be repeated with the existing settings?" N )" == true  ]]
				then
					# Playback, do nothing
					:
				else
					# Redo
					common.user.getAnswers "$askfile" "$playfile"
				fi
			else
				# Redo
				common.user.getAnswers "$askfile" "$playfile"
			fi
		else
			# Start from scratch
			common.user.getAnswers "$askfile" "$playfile"
		fi

		common.user.applyPlayfile $playfile 
		
		# We need this set later
		CXR_CONFIG=$destination

		# Should we add more tests?
		
	fi # Decision if copy or .ask
	
	main.log  "Edit the config file ${CXR_CONFIG} if needed - else just dry-run the script: \n \$ \t ${run} -d";
}

################################################################################
# Function: common.runner.expandConfigFile
#
# Replaces and non-single quoted variable in a config file by its value.
# This allows to preserve a config file (it is then independent of base.conf).
# Interactive function.
#
# Parameters:
# $1 - File to expand
# $2 - resulting output file
################################################################################
function common.runner.expandConfigFile() 
################################################################################
{
	local basefile=$1
	local expanded_config=$2
	
	# Is the file already there?
	if [[ -f ${expanded_config}  ]]
	then
		# Continue even if file is there?
		if [[ $(common.user.getOK "${expanded_config} already exists. Do you want to overwrite this file?" N ) == false  ]]
		then
			exit
		fi
	fi

	# First save some variables name of the baseconfig to a dummy name.
	# They are again exported before expanding.
	# Needed because these variables are not defined in a normal conf file,
	# but their values are still referenced. 
	# We first unset all variables, then load the config!

	local model_version=${CXR_MODEL_VERSION}
	local run_dir=${CXR_RUN_DIR}
	run=${CXR_RUN}

	# This nice construction expands any variables which are not
	# written in single quotes. Gotten out of a Usenet conversation on comp.unix.shell,
	# idea by Michael Schindler 
	# (the original line was
	# echo "$( unset ${!CXR_*}; source ${basefile} ;  set | grep ^CXR_ )" > ${CXR_EXPANDED_CONFIG}
	echo "$( unset ${!CXR_*}; CXR_RUN_DIR=${run_dir} ; CXR_RUN=${run}; CXR_MODEL_VERSION=${model_version}; source ${basefile} ;  set | grep ^CXR_ )" > ${expanded_config}

	CXR_CONFIG=$expanded_config
}

################################################################################
# Function: common.runner.getModelId
#
# Each model has a 0-based id (used for example to index CXR_SUPPORTED_MODEL_VERSIONS)
#
# Parameters:
# $1 - Exact name of model to use
################################################################################	
function common.runner.getModelId() 
################################################################################
{
	local needle="$1"
	
	# Find my element
	local current_id=0
	local current_model
	
	for current_model in $CXR_SUPPORTED_MODELS
	do
		if [[ $current_model == $needle ]]
		then
			echo $current_id
			return 0
		fi
		
		current_id=$(( $current_id + 1 ))
		
	done
	
	# Found nothing!
	return 1
}


################################################################################
# Function: common.runner.createNewRun
#
# Creates a new run by creating an appropriate link and calling <common.runner.createConfigFile>
#
# Tolerates runs that already exist (asks user).
#
################################################################################	
function common.runner.createNewRun() 
################################################################################
{

	local model="$(common.user.getMenuChoice "Which model should be used?\nIf your desired model is not in this list, adjust CXR_SUPPORTED_MODELS \n(Currently $CXR_SUPPORTED_MODELS)" "$CXR_SUPPORTED_MODELS" )"
	
	local model_id=$(common.runner.getModelId "$model") || main.dieGracefully "model $model is not known."
	
	# Extract the list of supported versions
	local supported="${CXR_SUPPORTED_MODEL_VERSIONS[${model_id}]}"
	
	#Generate a menu automatically
	local version="$(common.user.getMenuChoice "Which version of $model should be used?\nIf your desired version is not in this list, adjust CXR_SUPPORTED_MODEL_VERSIONS \n(Currently $supported)" "$supported" )"
	
	common.check.isVersionSupported? "$version" "$model" || main.dieGracefully "The version you supplied is not supported. Adjust CXR_SUPPORTED_MODEL_VERSIONS."
	
	local run=${model}-v${version}
	
	local addition
	
	echo "The Run name so far is ${run}- what do you want to add?"
	read addition

	run="${run}-$addition"

	# Name ok? ###################################################################
	common.check.RunName $run || main.dieGracefully "The name supplied does not contain a proper CAMx version. Rerun using $0 -C to be guided inturactively"
		
	# Name OK.
	
	# Extract and export model name and version 
	main.setModelAndVersion $run
	
	# This is the file name of an extended config
	CXR_EXPANDED_CONFIG=${CXR_CONF_DIR}/${run}.econf

	# This is a "normal" copy
	CXR_CONFIG=${CXR_CONF_DIR}/${run}.conf
	
	#name is OK - create link ##################################################
	if [[ ! -L $run  ]]
	then
		main.log   "Creating link $run."
			
		ln -s $CXR_RUNNER_NAME $run
		
	else
		# run already existists, OK? ###############################################
		if [[ $(common.user.getOK "$run already exists. Do you want to continue \n (Makes sense if you regenerate the configuration)?" N ) == false  ]]
		then
			# No
			exit
		fi
	fi
		
	# Create a configuration #####################################################
	common.runner.createConfigFile $run
	
	# Messages & Good wishes #####################################################
	main.log  "New run was created, start it with \n\t \$ $run -d"

}

################################################################################
# Function: common.runner.createMissingDirs
#
# Interactive function if called as such
#
# Reads the configuration of a run and creates all directories that are visible.
# This function is not intended to be called during a run, just for preparation.
# It is also no substitute for the checks, because of rules (see below)
# Has a couple of drawbacks:
# - it cannot forsee any rules that alter directories or add subdirectories
# - the configuration must be up-to-date we pause to give user the chance to update it.
#
# Parameters:
# $1 - Run-name for which to create directories
# $2 - iteractive (boolean), if set and true, run interactively (IS THIS GOOD??)
################################################################################	
function common.runner.createMissingDirs() 
################################################################################
{

	# TODO: Add input check
	local runName=$1
	local dir

	# Load config
	main.readConfig "${runName}" "$CXR_MODEL" "$CXR_MODEL_VERSION" "$CXR_RUN_DIR"
	
	# Get directories (create as needed)
	for dir in $(set | grep -e ^CXR_*.*_DIR= | cut -d= -f1)
	do
			main.log -v   "Variable $dir has value: ${!dir}\n"

			# is it set?
			if [[ "${!dir}" ]]
			then
				# does it exist?
				if [[ -d "${!dir}"  ]]
				then
					# is it executable (dir: means accessible)?
					if [[ ! -x ${!dir}  ]]
					then
						main.log -e "Directory ${!dir}, \nParameter $dir not accessible!"
					fi
				else
					# Does not exist, create it.
					if [[ $(common.fs.isAbsolutePath? ${!dir}) == true  ]]
					then
						main.log -w   "Directory ${!dir}, \nParameter $dir does not exist - creating it"
						mkdir -p ${!dir}
					else
						main.log -v  "${!dir} does not exist, but is a relative path - no action taken"
					fi
				fi
				
			else
				main.log -w   "Variable $dir is not set (might not be a problem, though)"
			fi
		done 
}

################################################################################
# Function: common.runner.getConfigItem
#
# This function loads a runs configuration (full hierarchy) and then
# extracts the value of a given variable. If the variable is not found, the empty 
# string is returned.
# Its recommended to call this function in a subshell (see below), otherwise,
# the current configuration is lost.
#
# Example:
# > local oldEmissDir="$(common.runner.getConfigItem CXR_EMISSION_DIR $oldRun)"
#
# Parameters:
# $1 - item name (a variable name) 
# $2 - Run-name
################################################################################	
function common.runner.getConfigItem() 
################################################################################
{
	main.readConfig "${runName}" "$CXR_MODEL" "$CXR_MODEL_VERSION" "$CXR_RUN_DIR"
	
	
}

################################################################################
# Function: common.runner.recreateInput
#
# Interactive function
#
# Asks the user which parts of an existing runs input data must by copied, moved or
# linked to a new run.
# TODO: Rewrite using a loop
#
# Parameters:
# $1 - New Run-name 
# $2 - Existing Run-name
################################################################################	
function common.runner.recreateInput() 
################################################################################
{
	# How fine-grained should we be?
	# Currently, we distinguish between two classes of Inputs: Emissions and all other Input data.
	# Actually, we work only on directory level.
	# In theory, we could ask for each file, but that would take ages...
	# Just make sure that the two directories (Emissions/Other Input) are distinct.
	
	local newRun=$1
	local oldRun=$2
	
	# get the relevant directories
	local oldEmissDir="$(common.runner.getConfigItem CXR_EMISSION_DIR $oldRun)"
	local newEmissDir="$(common.runner.getConfigItem CXR_EMISSION_DIR $newRun)"
	
	local oldInputDir="$(common.runner.getConfigItem CXR_INPUT_DIR $oldRun)"
	local newInputDir="$(common.runner.getConfigItem CXR_INPUT_DIR $newRun)"
	
	if [[ "$(dirname "$oldEmissDir")" == "$(dirname "$oldInputDir")" || "$(dirname "$newEmissDir")" == "$(dirname "$newInputDir")" ]]
	then
		main.dieGracefully "Please use two separate directories for Emissions and all other Inputs if you want to use the recreate feature."
	fi
	
	# also make sure they are not subdirs of each other
	if [[ "$(common.fs.isSubDirOf? "$oldEmissDir" "$oldInputDir" )" == true || "$(common.fs.isSubDirOf? "$oldInputDir" "$oldEmissDir" )" == true ]]
	then
		main.dieGracefully "To use the recreate feature, neither $oldEmissDir must be a subdirectory of $oldInputDir or vice versa."
	fi
	
	# Emissions
	if [[ "$(common.user.getOK "Do you want to re-use emission data of $oldRun?")" == true ]]
	then
		# Re-use Emissions
		
		# Do not take chances - only work on empty target directory
		# we use the fact that rmdir crashes if the directory is non-empty
		rmdir $newEmissDir || main.dieGracefully "Could not replace $newEmissDir by a link or copy to $oldEmissDir! $newEmissDir must be empty"
		
		if [[ "$(common.user.getOK "Do you want to copy the data? (if not, we symlink to it)")" == true ]]
		then
			# copy
			cp -r $oldEmissDir $newEmissDir || main.dieGracefully "Could not replace $newEmissDir by a copy of $oldEmissDir!"
		else
			# link
			ln -s $oldEmissDir $newEmissDir || main.dieGracefully "Could not replace $newEmissDir by a link to $oldEmissDir!"
		fi
	fi
	
	rmdir $newInputDir || main.dieGracefully "Could not replace $newInputDir by a link or copy to $oldInputDir! $newInputDir must be empty"
	
	# Other Inputs
	if [[ "$(common.user.getOK "Do you want to re-use other input data of $oldRun?")" == true ]]
	then
		# Re-use Other stuff
		if [[ "$(common.user.getOK "Do you want to copy the data? (if not, we symlink to it)")" == true ]]
		then
			# copy
			cp -r $oldInputDir $newInputDir || main.dieGracefully "Could not replace $newInputDir by a copy of $oldInputDir!"
		else
			# link
			ln -s $oldInputDir $newInputDir || main.dieGracefully "Could not replace $newInputDir by a link to $oldInputDir!"
		fi
	fi
}

################################################################################
# Function: common.runner.recreateRun
#
# Creates a copy of an existing config file and prepares everything to rerun.
# Depending on the users choice, Input data can be linked or copied.
# Automatically creates the needed directories. 
#
# Parameters:
# [$1] - Run-name to re-create (optional)
################################################################################	
function common.runner.recreateRun() 
################################################################################
{
	local oldRun
	local newRun
	
	# Do we have the old run name?
	if [[ -z "${1:-}" ]]
	then
		#no, ask
		oldRun="$(common.runner.getExistingRunName)"
	else
		#yes
		oldRun=${1}
		# Verify
		if [[ $(common.check.isCorrectRunName $oldRun) == false ]]
		then
			main.dieGracefully "The name of the run you want to repeat () is not correct. Make sure only characters allowed in filenames are included"
		fi # Supplied run name correct?
	fi # got run name?
	
	
	# Get the new one
	newRun="$(common.runner.getNewRunName)"
	
	# Create config (ATTN: IF changed)
	common.runner.createConfigFile "$newRun" "$oldRun"
	
	# Create Directories
	common.runner.createMissingDirs "$newRun"
	
	# Ask user if we need to copy/link input data 
	common.runner.recreateInput "$newRun" "$oldRun"
	
	# Thats all.
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
	
	CXR_IGRID=1
	
	########################################
	# Tests. If the number changes, change CXR_META_MODULE_NUM_TESTS
	########################################
	
	is $(common.runner.evaluateRule a) a "common.runner.evaluateRule constant"
	is $(common.runner.evaluateRule "$(common.math.abs -100)") 100 "common.runner.evaluateRule a function of CAMxRunner"
	is $(common.runner.evaluateRule "domain$(common.string.leftPadZero $CXR_IGRID 3)") domain001 "common.runner.evaluateRule with formatting"
	is $(common.runner.evaluateRule "$(uname -n)") $(uname -n) "common.runner.evaluateRule with uname"
	
	# Test Locking
	local lock=test
	
	## Adjust a few settings
	CXR_LOG_FUNCTION_VERBOSE_LIST="$CXR_LOG_FUNCTION_VERBOSE_LIST common.runner.waitForLock"
	
	# save & lower timeout
	oCXR_LOCK_TIMEOUT_SEC=$CXR_LOCK_TIMEOUT_SEC
	CXR_LOCK_TIMEOUT_SEC=20
	
	main.log -a "Testing Locking - using a timeout of $CXR_LOCK_TIMEOUT_SEC s"
	
	# Get an instance lock
	common.runner.getLock "$lock" "$CXR_HASH_TYPE_INSTANCE" > /dev/null
	
	# Other processes want it
	common.runner.waitForLock "$lock" "$CXR_HASH_TYPE_INSTANCE"
	common.runner.waitForLock "$lock" "$CXR_HASH_TYPE_INSTANCE"
	
	# Restore old settings
	CXR_LOCK_TIMEOUT_SEC=$oCXR_LOCK_TIMEOUT_SEC
	
	# Release it
	common.runner.releaseLock "$lock" "$CXR_HASH_TYPE_INSTANCE"
	
	
	########################################
	# teardown tests if needed
	########################################
	
	
}