# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Common script for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Title: Various check Functions
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
CXR_META_MODULE_NUM_TESTS=2

# This string describes special requirements this module has
# it is a space-separated list of requirement|value[|optional] tuples.
# If a requirement is not binding, optional is added at the end
CXR_META_MODULE_REQ_SPECIAL="exec|md5sum|optional exec|dos2unix exec|idl"

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Contains most of the check functions for the CAMxRunner"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2010), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'

################################################################################
# Function: common.check.concentrations
#	
# Lists a summary of the concentrations identified by the given pattern.
# Uses the IDL procedure summarize_bin_files.
# 
# Parameters:
# $1 - a pattern describing the files to be summarized. Use {} to indicate alternation
################################################################################
function common.check.concentrations() 
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true || $CXR_NO_CONC_CHECK == true ]]
	then
		return $CXR_RET_OK
	fi

	if [[ $# -ne 1 ]]
	then
		main.dieGracefully "needs 1 string (a pattern) as input"
	fi
	
	main.log -a -B "Concentration summary:"
	
	local exec_tmp_file
	local pattern
	
	pattern="$1"
	
	exec_tmp_file=$(common.runner.createJobFile $FUNCNAME)


	cat <<-EOF > $exec_tmp_file
	.run summarize_bin_files.pro
	summarize_bin_files,'$pattern'
	exit
	EOF
	
	${CXR_IDL_EXEC} < ${exec_tmp_file} 2>&1 | tee -a $CXR_LOG
	
}

################################################################################
# Function: common.check.BashVersion
#	
# Checks if the bash version is ok for what we do
################################################################################
function common.check.BashVersion() 
################################################################################
{
	if [[ ${BASH_VERSINFO[0]} -lt 3  ]]
	then
		main.dieGracefully "We need at least Bash Version 3.x - please upgrade."
	fi
}

################################################################################
# Function: common.check.PredictFileSizeMb
# 
# Gives a rough estimate  on the number of megabytes needed for a given output file.
# This function is NOT used by <common.check.PredictModelOutputMb>, the purpose of
# this function here is to check if a file has about the right size.
#
# Parameters:
# $1 - the filename in question
# $2 - the type of file (AIRQUALITY, BOUNDARY, EMISSIONS...)
# $3 - the storage type (ASCII, BINARY, FDA, HDF)
#
################################################################################
function common.check.PredictFileSizeMb ()
################################################################################
{
	# TODO Should be implemented
	echo 400
}

################################################################################
# Function: common.check.PredictModelOutputMb
# 
# Gives a rough (hopefully over-)estimate  on the number of megabytes needed for the output.
#
# Formula: sum (dx_i * dy_i * dz_i) * ( t / t_res) * nspec * C(Options) * f_margin
# Takes into account if 3D output is requested or not.
# Probing tools are taken into account, but crudely.
# The factor C(Options) is currently a constant, it might take other options
# like HDF etc. into account later.
#
# TODO: take into account instance_tasks table!
#
################################################################################
function common.check.PredictModelOutputMb()
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		echo 0
		return $CXR_RET_OK
	fi
	
	local cells
	local time_steps
	local size
	local probing_factor
	
	probing_factor=1

	# Determine size of output field
	if [[ ${CXR_AVERAGE_OUTPUT_3D} == true  ]]; then
		cells=$(common.runner.countAllCells3D)
	else
		cells=$(common.runner.countAllCells2D)
	fi
	
	# Add storage needed for Probing tools
	case "${CXR_PROBING_TOOL}" in
	
		PA) probing_factor=1.8 ;; 
		PSAT|OSAT) probing_factor=2.0 ;;

	esac
	
	# Our constant is designed for 10^5 cells
	cells=$(common.math.FloatOperation "$cells / 100000")
	
	time_steps=$(common.math.FloatOperation "(60 * 24 * ${CXR_NUMBER_OF_SIMULATION_DAYS}) / ${CXR_OUTPUT_FREQUENCY}" 0)
	
	size=$(common.math.FloatOperation "${cells} * ${time_steps} * ${CXR_NUMBER_OF_OUTPUT_SPECIES} * ${CXR_C_SPACE} * ${CXR_F_MARGIN} * ${probing_factor}" 0)
	
	echo "$size"
}

################################################################################
# Function: common.check.MbNeeded
#	
# Checks if space in target directory is sufficient.
# Aborts if not sufficient.
# Internally uses <common.fs.getFreeMb>
#
# Parameters:
# $1 - Directory to check
# $2 - Space needed (in megabytes)
################################################################################
function common.check.MbNeeded() 
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		return $CXR_RET_OK
	fi
	
	
	if [[ $# -ne 2  ]]
	then
		main.dieGracefully "needs 2 parameters: a path and a number (megabytes needed)"
	fi
	
	local dir
	local mb
	
	dir="$1"
	mb="$2"
	
	main.log -v  "Checking if space in $dir is sufficient..."
		
	# Nonexistent Directory?
	if [[ ! -d $dir  ]]
	then
		# Create it!
		main.log -w  "Directory $dir is missing, I create it now."
		mkdir -p $dir
	fi
	
	available="$(common.fs.getFreeMb "$dir")"
	
	if [[ "$available" -eq -1 ]]
	then
		main.log -w "I cannot tell if space in $dir is sufficient."
	else
		main.log -v "Found $available Mb in $dir"
		
		if [[ "$available" -ge "$mb" ]]
		then
			main.log "Space in $dir is sufficient."
		else
			main.dieGracefully "Space in $dir is not sufficient, need at least $mb Megabytes!"
		fi
	fi
	
}


################################################################################
# Function: common.check.DataType
#	
# Checks if a value has a certain datatype - needed for installation
# to make sure the user entered sensible values
#
# Datatypes:
#	- S (String; allowed to be empty)
# - I (Integer)
#	- F (Float)
#	- B (Boolean; either true or false)
# - D (Directory; a high level string that is checked)
#
# Parameters:	
# $1 - Value to check
# $2 - Expected datatype (1 char)
################################################################################
function common.check.DataType()
################################################################################
{
	if [[ $# -ne 2 ]]
	then
		main.dieGracefully "needs 2 strings as input"
	fi
	
	local value
	local datatype
	
	value=$1
	datatype=$2
	
	main.log -v "VALUE: *$value*\nDATATYPE: *$datatype*"

	case $datatype in
	S) # String - everything is ok, even an empty string
		echo true
		;;
	I) # Integer
		if [[ "$value" =~ $CXR_PATTERN_NUMERIC ]]
		then
			echo true
		else
			echo false
		fi

		;;
	F) # Floating point number

		#Check for FP
		# If this returns 0, we look at a FP.
		# We look for any ocurrences of numbers,
		# mandatorily followed by a dot
		# optionally followed by any ocurrences of numbers
		
		# We neet the retval,
		# turn off strict checks
		set +e
		
		echo "$value" | grep "[0-9]*\.[0-9]*" >/dev/null
		
		if [[ $? -eq 0  ]]
		then
			echo true
		else
			echo false
		fi
		
		#Turn strict checks back on unles we are testing
		if [[ ${CXR_TEST_IN_PROGRESS:-false} == false ]]
		then
			set -e
		fi
		
		;;
	B) # Boolean - either true or false
		if [[  "$value" == true || "$value" == false ]]
		then
			echo true
		else
			echo false
		fi
		;;
	D) # Directory - in principle we accept anything
		if [[ ! -d "$value" ]]
		then
			main.log  -s "The directory $value was not found"
			echo true
		fi
			
		;;
	*) main.dieGracefully "illegal Datatype $datatype" ;;
	esac
}

################################################################################
# Function: common.check.ModelLimits
#
# Checks if the current model supports our current settings by inspecting the 
# relevant .conf file.
# If these checks change with the model version, put the definition of this function
# in a module under modules/common/model/version directory
#
################################################################################
function common.check.ModelLimits()
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		return $CXR_RET_OK
	fi
	
	main.log -a -B  "Checking model limits for ${CXR_MODEL_EXEC}..."
	
	# We must find the play file
	local conffile
	local iGrid
	local iVal
	local var
	local curr_var
	local f_val
	local f_nspec
	local cxr_value
	
	local max_col
	local max_row
	local max_lay
	local max_all
	
	local vars
	local vals
	
	max_col=0
	max_row=0
	max_lay=0
	
	
	conffile=${CXR_MODEL_BIN_DIR}/$(basename ${CXR_MODEL_EXEC}).conf
	
	if [[ -f "${conffile}" ]]
	then
		# conffile is present
		
		main.log -a  "This was the configuration used to compile ${CXR_MODEL_EXEC}:"
		cat "${conffile}" | tee -a "${CXR_LOG}"
		
		# Check geometry
		
		#Test each grid
		for iGrid in $(seq 1 $CXR_NUMBER_OF_GRIDS);
		do
			# For column, row, layer (CAMx internal variables are called like lis, eg MXROW1
			for var in COL ROW LAY
			do
				case "${var}" in
					COL) cxr_value=$(common.runner.getX ${iGrid}) 
					
							 if [[ $cxr_value -gt $max_col ]]; then 
							 	max_col=$cxr_value 
							 fi
							 ;;
							 
					ROW) cxr_value=$(common.runner.getY ${iGrid}) 
							 if [[ $cxr_value -gt $max_row ]]; then 
							 	max_row=$cxr_value 
							 fi
							 ;;
							 
					LAY) cxr_value=$(common.runner.getZ ${iGrid})
								if [[ $cxr_value -gt $max_lay ]]; then 
							 	max_lay=$cxr_value 
							 fi
							 ;; 
				esac
				
				# e. g. MXCOL1
				curr_var="MX${var}${iGrid}"
				
				main.log -v  "Checking ${curr_var}..."
				
				# Read value
				f_val="$(grep "${curr_var}${CXR_DELIMITER}" "${conffile}" | cut -d${CXR_DELIMITER} -f2)"
				
				if [[ "${f_val}"  ]]
				then
					# Check if we are above the limit
					if [[ "${cxr_value}" -gt "${f_val}" ]]
					then
						main.log -e  "The limit for the setting ${curr_var} (${f_val}) is too low in the executable ${CXR_MODEL_EXEC} (${cxr_value})\nPlease recompile CAMx using the installer."
					else
						main.log -v  "${curr_var} setting OK"
					fi
				else
					main.log -v "There is no entry ${curr_var} in the conffile ${conffile}"
				fi
			done # Var
		done # grid
		
		# Determine largest (layers do not count)
		if [[ $max_row -gt $max_col ]]
		then
			max_all=$max_row
		else
			max_all=$max_col
		fi
		
		# Test the special vars
		vars="MXCOLA MXROWA MXLAYA MX1D"
		vals=($max_col $max_row $max_lay $max_all)
		
		iVal=0
		for curr_var in $vars
		do
			main.log -v  "Checking ${curr_var}..."
			
			cxr_value=${vals[$iVal]}
				
			# Read value
			f_val="$(grep "${curr_var}${CXR_DELIMITER}" "${conffile}" | cut -d${CXR_DELIMITER} -f2)"
			
			if [[ "${f_val}"  ]]
			then
				# Check if we are above the limit
				if [[ "${cxr_value}" -gt "${f_val}" ]]
				then
					main.log -e  "The limit for the setting ${curr_var} (${f_val}) is too low in the executable ${CXR_MODEL_EXEC} (${cxr_value})\nPlease recompile CAMx using the installer."
				else
					main.log -v  "${curr_var} setting OK"
				fi
			else
				main.log -v "There is no entry ${curr_var} in the conffile ${conffile}"
			fi
			
			iVal=$(( $iVal + 1 ))
		done # vars

		# Check #of species
		f_nspec="$(grep "MXSPEC${CXR_DELIMITER}" "${conffile}" | cut -d${CXR_DELIMITER} -f2)"
		
		if [[ "${f_nspec}"  ]]
		then
			# Check if we are above the limit
			if [[ "${CXR_NUMBER_OF_OUTPUT_SPECIES}" -gt "${f_nspec}"  ]]
			then
				main.log -e  "The limit for the number of species (MXSPEC=${f_nspec}) is too low in the executable ${CXR_MODEL_EXEC} (${CXR_NUMBER_OF_OUTPUT_SPECIES})\nPlease recompile CAMx using the installer."
			else
				main.log -v  "Number of species is OK."
			fi
		else
			main.log -v  "There is no entry MXSPEC in the conffile ${conffile}."
		fi
	else
		main.log -a  "Found no conffile called ${conffile}.\nSo probably CAMx was not compiled using CAMxRunner, cannot check the capabilities of your executable."
	fi
	
	main.log -a  "Model limits checked."
}

################################################################################
# Function: common.check.ExecLimits
#
# Checks if our support executables support the current grid sizes.
# Primitive check that is based on settings in defaults.inc
#
################################################################################
function common.check.ExecLimits()
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		return $CXR_RET_OK
	fi
	
	main.log -a -B  "Checking limits for the support executables..."
	
	# We must find the play file
	local iGrid
	local rows
	local cols
	local layers
	
	if [[ $CXR_NUMBER_OF_OUTPUT_SPECIES -gt $CXR_MAX_NSPEC ]]
	then
		main.log -e  "The limit for the number of species (${CXR_MAX_NSPEC}) is too low in the support executables (${CXR_NUMBER_OF_OUTPUT_SPECIES})\nPlease adjust the code of the converters etc. and the setting of CXR_MAX_NSPEC"
	fi
	

	#Test each grid
	for iGrid in $(seq 1 $CXR_NUMBER_OF_GRIDS);
	do
		rows=$(common.runner.getX ${iGrid}) 
		cols=$(common.runner.getY ${iGrid}) 
		layers=$(common.runner.getZ ${iGrid})
		
		if [[ $rows -gt $CXR_MAX_XDIM ]]
		then
			main.log -e  "The limit for the number of species (${CXR_MAX_XDIM}) is too low in the support executables (${rows})\nPlease adjust the code of the converters etc. and the setting of CXR_MAX_NSPEC"
		fi
		
		if [[ $cols -gt $CXR_MAX_YDIM ]]
		then
			main.log -e  "The limit for the number of species (${CXR_MAX_YDIM}) is too low in the support executables (${cols})\nPlease adjust the code of the converters etc. and the setting of CXR_MAX_NSPEC"
		fi
		
		if [[ $layers -gt $CXR_MAX_ZDIM ]]
		then
			main.log -e  "The limit for the number of species (${CXR_MAX_ZDIM}) is too low in the support executables (${layers})\nPlease adjust the code of the converters etc. and the setting of CXR_MAX_NSPEC"
		fi
	done # grid


	main.log -a  "Support program limits checked."
}

################################################################################
# Function: common.check.RunnerExecutables
#	
# Loop through all *.sh scripts in the ${CXR_RUN_DIR} and check if they are Unix format
#
################################################################################
function common.check.RunnerExecutables()
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		return $CXR_RET_OK
	fi
	
	local file
	
	# We use a bash 3.x structure, the so-called "here-variable"
	while read file
	do
		# We are still alive...
		common.user.showProgress
		
		if [[ "$(common.fs.isDos? "$file")" == true ]]
		then
			main.log -w  "$file is in dos format. I will correct this."
			${CXR_DOS2UNIX_EXEC} $file
			
			if [[ $? -ne 0 ]]
			then
				main.dieGracefully "could not convert $file to Unix format!"
			fi
		fi

	# Make sure we exclude state dir
	done<<<"$(find ${CXR_RUN_DIR}/ -noleaf -type f -name \*.sh | grep -v "^${CXR_RUN_DIR}/state/")"
	
	main.log -a  "Checked."
}

################################################################################
# Function: common.check.Vars
#	
# Loop through all CXR_*.*_EXEC variables and check if they are 
# * Set
# * Present
# * Executable
#
# This function is only visual, does not terminate
################################################################################
function common.check.Vars ()
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		return $CXR_RET_OK
	fi
	
	local executable
	local stripped
	
	for executable in $(set | grep -e ^CXR_*.*_EXEC= | cut -d= -f1)
	do
		# strip arguments
		stripped="$(echo ${!executable} | cut -d" " -f1)"
		
		main.log -v "Variable $executable has value: ${!executable}\n"
			
		# is it set?
		if [[ "${!executable}" ]]
		then
			# Does it exist?
			if [[ -f "${stripped}" ]]
			then
				# is it executable 
				if [[ ! -x "${stripped}" ]]
				then
					main.log -w "Executable ${!executable}, Parameter $executable not executable - I try to correct this ..."     
					
					chmod +x "${stripped}" || main.log -w "Could not change permissions on file $FILE"

					# Do not increase error count here - maybe we do not need this one
				fi
			else
			  # Not present!
			  main.log -w "Executable ${stripped}, Parameter $executable does not exist (might not be a problem, though, CAMx e. g. is not needed for postprocessing and vice-versa)!"
			fi
			
		else
			main.log -w "Variable $executable is not set (might not be a problem, though)"
		fi
	done
}


################################################################################
# Function: common.check.reportMD5
#	
# Logs the MD5 Hash of a file.
# Also stores this information in a universal hash called MD5. If there is a current 
# value in there (generated during this run), we do not report a new value, 
# otherwise we do and compare the new with the old value.
# If a file is on a local filesystem, we add the nodename as prefix to tell local files
# of different machines apart.
#
# Parameters:
# $1 - filename to calculate MD5 on
################################################################################
function common.check.reportMD5() 
################################################################################
{
	if [[ "${CXR_REPORT_MD5}" == true && $CXR_FAST == false ]]
	then
		if [[ $# -ne 1 ]]
		then
			main.log -e  "Programming error: no filename passed!"
		fi

		local file
		local isLocal
		local hash
		local new_hash
		local old_hash
		local old_mtime
		
		file="$1"
		isLocal="$(common.fs.isLocal? "$file")"
		
		if [[ "$isLocal" == true ]]
		then
			# add the hostname as prefix
			hash_file=$(uname -n):${file}
			main.log -v "Local file: $hash_file"
		else
			hash_file=$file
		fi
		
		# Is this file already in the cache?
		if [[ "$(common.hash.has? MD5 $CXR_LEVEL_UNIVERSAL "${hash_file}" )" == true ]]
		then
		
			# Did we encounter it recently?
			if [[ "$(common.hash.isNew? MD5 $CXR_LEVEL_UNIVERSAL "${hash_file}")" == false ]]
			then
				# it must be older, check if hash has changed.
				new_hash="$(main.getMD5 "$file")"
				old_hash="$(common.hash.get MD5 $CXR_LEVEL_UNIVERSAL "${hash_file}")"
				
				if [[ "$new_hash" != "$old_hash" ]]
				then
					# Get the old mtime
					old_mtime="$(common.hash.getValueMtime MD5 $CXR_LEVEL_UNIVERSAL "${hash_file}" )"
					old_datetime="$(common.date.EpochToDateTime $old_mtime)"
					main.log -w "File ${file} changed since ${old_datetime}. New MD5: ${new_hash}"
					
					# Store new hash
 					common.hash.put MD5 $CXR_LEVEL_UNIVERSAL "$hash_file" "$new_hash" true
				fi
			fi
		
		else
			# Never seen this file before
			hash="$(main.getMD5 "$file")"
			main.log -a  "MD5 Hash of ${file} is ${hash}"
			
			# Store in Cache (allowing history)
			common.hash.put MD5 $CXR_LEVEL_UNIVERSAL "$hash_file" "$hash" true
		fi
	fi
}

################################################################################
# Function: common.check.preconditions
#	
# Checks if all input files listed in CXR_CHECK_THESE_INPUT_FILES are available.
# If -w is given, we wait until the files arrive.
# Also sees that output files listed in CXR_CHECK_THESE_OUTPUT_FILES are not present 
# - if -F is given, existing output files are deleted here. 
# If we detect empty output files, they are always removed.
# We also test if output files are written to links, depending on CXR_ALLOW_WRITING_TO_LINKS, this is not allowed.
#
# Files are checked for length if CXR_CHECK_MAX_PATH=true
#
# This function does not terminate the runner if errors are found,
# but it returns false.
#
# You can restrict the checks if wanted, currently, the one-time checks are always executed.
#
# Parameters:
# -i - check input files (Default: Check all)
# -o - check output files (Default: Check all)
################################################################################
function common.check.preconditions() 
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		echo true
		return $CXR_RET_OK
	fi
	
	# In a dryrun, quickly show all expected in- and output files
	if [[ "$CXR_DRY" == true ]]
	then

		main.log -a -b "Expected Input files:"
		# We replace the spaces by newlines
		main.log -a "${CXR_CHECK_THESE_INPUT_FILES// /\\n}"

		main.log -a -b "Expected Output files:"
		# We replace the spaces by newlines
		main.log -a "${CXR_CHECK_THESE_OUTPUT_FILES// /\\n}"

	fi
	
	# Does the user want to limit the checks?
	local limited
	local do_input
	local do_output
	local errors_found
	local output_dir
	local dir
	local output_file
	local input_file
	local target
	local newTarget
	
	limited=false
	# First, all is switched off
	do_input=false
	do_output=false

	while getopts ":io" opt
	do
		case $opt in
		i) limited=true ; do_input=true  ;;
		o) limited=true ; do_output=true ;;
		esac
	done
	
	# Fix switches if user did not restrict
	if [[ "${limited}" == false  ]]
	then
		do_input=true
		do_output=true
	fi
	
	# This is not strictly needed, but it allows to read 
	# non-named command line options
	shift $(($OPTIND - 1))
	
	# Make getopts ready again
	unset OPTSTRING
	unset OPTIND

	# In here, we disable strict checking of variables
	# because we want to fail in a controlled manner if anything is wrong
	set +u

	#Mark if there were errors
	errors_found=false
	
	main.log -a "Testing Preconditions..."
	
	##########################################
	#### this is only checked once
	##########################################
	if [[ "$CXR_CHECKED_ONCE" == false ]]
	then
	
		main.log -v "Performing one-time checks..."
		
		# Increase global indent level
		main.increaseLogIndent

		main.log -v "Checking Output directories ..."
		
		# Increase global indent level
		main.increaseLogIndent

		# Create Output dirs if needed
		# cut extracts the variable name
		for output_dir in $(set | grep -e ^CXR_*.*_OUTPUT_DIR= | cut -d= -f1)
		do
			# Still alive
			common.user.showProgress
			
			# is it set?
			if [[ "${!output_dir}"  ]]
			then
				main.log -v "Variable $output_dir has value: ${!output_dir}\n"
				
				# Test length
				if [[ "${CXR_CHECK_MAX_PATH}" == true ]]
				then
					if [[ $(common.string.len "${!output_dir}") -gt "${CXR_MAX_PATH}" ]]
					then
						main.log -e "Path to $output_dir longer than ${CXR_MAX_PATH}. Either disable this check (CXR_CHECK_MAX_PATH=false) or increase CXR_MAX_PATH.\nCheck if all binaries are ready for paths of this size!"
					fi
					
					# Also test if the total length of existing files in not too large 
					# (only on AFS)
					
					if [[ "$(common.fs.getType ${!output_dir})" == afs ]] 
					then
						if [[ $(common.fs.sumFilenameLenght "${!output_dir}") -gt $CXR_MAX_AFS_FN_LEN ]]
						then
							main.log -e "Directory ${!output_dir} contains a lot of files with long names. AFS might get a problem!"
						fi # too many files
					fi # AFS?
					
				fi
				
				# Does it exist
				if [[ ! -d ${!output_dir}  ]]
				then
					main.log -w  "Directory ${!output_dir} Parameter $output_dir does not exist - will create it"
					
					mkdir -p ${!output_dir} || main.dieGracefully "could not create output dir ${!output_dir}"
					
				# is it writeable?
				elif [[ ! -w ${!output_dir}  ]]
				then
					main.log -e "Output Directory ${!output_dir}, \nParameter $output_dir not writeable!"
				fi
			else
				main.log -w   "Variable $output_dir is not set (might not be a problem, though)"
			fi
		done
		
		# Decrease global indent level
		main.decreaseLogIndent
		
		main.log -v  "Checking Executables ..."
		
		# Increase global indent level
		main.increaseLogIndent

		# EXECUTABLES
		common.check.Vars
		
		# Decrease global indent level
		main.decreaseLogIndent
		
		main.log -v "Checking Directories ..."
		
		# Increase global indent level
		main.increaseLogIndent

		
		# DIRECTORIES
		for dir in $(set | grep -e ^CXR_*.*_DIR= | cut -d= -f1)
		do
			main.log -v   "Variable $dir has value: ${!dir}\n"
			# Still alive
			common.user.showProgress

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
				main.log -w "Variable $dir is not set (might not be a problem, though)"
			fi
		done 
		
		# Decrease global indent level
		main.decreaseLogIndent
		
		# Check done
		CXR_CHECKED_ONCE=true
		
		##########################################
		#### END this is only checked once
		##########################################
		
	fi
	
	##########################################
	### From here, checks are run for each day
	##########################################
	
	main.log -v "Performing per-day checks..."
	
	########################################
	# Input Check
	########################################
	if [[ "${do_input}" == true  ]]
	then
		# INPUT FILES - are they there?
		main.log -v "Checking Input Files ..."
	
		# Increase global indent level
		main.increaseLogIndent
	
		for input_file in ${CXR_CHECK_THESE_INPUT_FILES}
		do
			# Still alive
			common.user.showProgress
			
			# Test length
			if [[ "${CXR_CHECK_MAX_PATH}" == true  ]]
			then
				if [[ $(common.string.len "${input_file}") -gt "${CXR_MAX_PATH}"  ]]
				then
					main.log -e  "Path to $input_file longer than ${CXR_MAX_PATH}. Either disable this check (CXR_CHECK_MAX_PATH=false) or increase CXR_MAX_PATH.\nCheck if all binaries are ready for paths of this size!"
					errors_found=true
				fi
			fi
			
			# does  it exist?
			if [[ ! -e "${input_file}" ]]
			then
				# does not exist!
				
				# Is it a broken link?
				if [[ "$(common.fs.isBrokenLink? "${input_file}")" == true ]]
				then
					# Broken link. Its possible that the source was compressed!
					
					target="$(common.fs.getLinkTarget "${input_file}")"
					
					if [[ $(common.fs.doesCompressedVersionExist? "$target") == true ]] 
					then
						main.log -w "${input_file} points to a file ($target) that seems to be compressed. Trying to decompress..."
						newTarget=$(common.fs.TryDecompressingFile "$target")
						
						if [[ "$newTarget" != "$target" ]]
						then
							main.log -w "The file was decompressed in a different location. Link ${input_file} will be adjusted. After the run, CAMxRunner will undo this!"
							ln -s -f "${newTarget}" "${input_file}" || main.dieGracefully "Could not create new link to ${newTarget}"
							
							# Store the fact that we changed this link, storing the existing information
							common.hash.put $CXR_INSTANCE_HASH_RELOCATED_LINKS $CXR_LEVEL_INSTANCE "${input_file}" "${target}"
						fi # New Target?
						
						
					fi # Compressed target?
				elif [[ "${CXR_WAIT_4_INPUT}" == true ]]
				then
					# We want to wait
					if [[ "$(common.fs.WaitForFile ${input_file})" == false ]]
					then
						# Waiting did not help
						errors_found=true
					fi
				else
					main.log -e  "File ${input_file} does not exist!"
					errors_found=true
				fi
			else
				# File exists.
				
				# If a process writes to the file, it might be that 
				# it still grows
				if [[ "${CXR_WAIT_4_INPUT}" == true ]]
				then
					if [[ "$(common.fs.WaitForStableSize ${input_file})" == false ]]
					then
						# Waiting did not help
						errors_found=true
					fi
				fi
				
				# Readable? (broken links are not readable)
				if [[ -r "${input_file}" ]]
				then
					# is it larger than 0 bytes?
					if [[ ! -s "${input_file}" ]]
					then
						# Empty File!
						main.log -e  "File ${input_file} is empty!"
						errors_found=true
					else
						# Non-empty, report hash if wanted
						common.check.reportMD5 "${input_file}"
					fi # larger than 0
				else
					# Not readable!
					main.log -e  "File ${input_file} not readable!"
					errors_found=true
				fi # readable
			fi
		done
	else
		main.log -v  "Will not check input"
	fi
	
	########################################
	# Output Check
	########################################
	if [[ "${do_output}" == true  ]]
	then
		# OUTPUT FILES - are they absent?
		main.log -v   "Checking if Output Files are absent..."
	
		# Increase global indent level
		main.increaseLogIndent
	
		for output_file in ${CXR_CHECK_THESE_OUTPUT_FILES}
		do
			# Still alive
			common.user.showProgress
			
			# Test length
			if [[ "${CXR_CHECK_MAX_PATH}" == true ]]
			then
				if [[ $(common.string.len "${output_file}") -gt "${CXR_MAX_PATH}"  ]]
				then
					main.log -e  "Path to $output_file longer than ${CXR_MAX_PATH}. Either disable this check (CXR_CHECK_MAX_PATH=false) or increase CXR_MAX_PATH.\nCheck if all binaries are ready for paths of this size!"
					errors_found=true
				fi
			fi
			
			# Writing to link allowed?
			if [[ "${CXR_ALLOW_WRITING_TO_LINKS}" == false ]]
			then
			
				common.fs.isLink? $(dirname "${output_file}") &> /dev/null
				
				if [[ "$_result" == true ]]
				then
					main.dieGracefully "You are trying to write to $_target but CXR_ALLOW_WRITING_TO_LINKS is false!"
				fi
				
			fi
			
			# is it present?
			if [[ -f "${output_file}" ]]
			then
				#############################
				# File Present 
				#############################
				
				# is it empty or do we force?
				if [[ ! -s "${output_file}"  ]]
				then
					# Empty
					main.log -w  "File ${output_file} already exists, but is empty. I will delete it now..."
					rm -f "${output_file}"
				elif [[ "$CXR_FORCE" == true  ]]
				then
					# Force overwrite
					main.log -w  "File ${output_file} already exists. You chose the -F option, so we delete it now..."
					
					if [[ "$CXR_DRY" == false  ]]
					then
						rm -f "${output_file}"
					else
						main.log -w  "Dryrun, file ${output_file} not removed. A real run removes the file if -F is given!"
					fi
				else
					#############################
					# No overwrite, no empty file
					#############################
					
					# Do we skip?
					if [[ "${CXR_SKIP_EXISTING}" == true  ]]
					then
						# Ok, skipping
						main.log -w  "File ${output_file} already exists. You chose to skip over this file..."
					else
						main.log -e  "File ${output_file} already exists! You can force the deletion of existing files by calling \n ${CXR_CALL} -F"
						errors_found=true
					fi
				fi
			else
				# Not there, OK
				main.log -v "File $output_file does not yet exist - Good."
			fi
		done
		
		# Decrease global indent level
		main.decreaseLogIndent
	else
		main.log -v  "Will not check output"
	fi
	
	# re-enable checking of variables
	set -u
	
	# Inverting
	if [[ "${errors_found:-false}" == false ]]
	then
		# No errors
		main.log -a "Preconditions OK."
		echo true
	else
		# Detected errors
		main.log -a "Preconditions NOT OK."
		echo false
	fi
	
	return $CXR_RET_OK
}

################################################################################
# Function: common.check.postconditions
#	
# Checks if the output was generated
# Later, we can think about a real size check
#
# We basically just loop through a list of files (this is a radical break with the 
# old approach where we looped over an array of arrays of files).
# This list is called CXR_CHECK_THESE_OUTPUT_FILES and must be set befor calling this function
#
# Additionally, each created file is added to the hash CXR_INSTANCE_HASH_OUTPUT_FILES
#
# This function does not terminate the runner if errors are found,
# but it returns false
################################################################################
function common.check.postconditions() 
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		echo true
		return $CXR_RET_OK
	fi
	
	local errors_found
	local output_file
	
	errors_found=false
	
	# No output check for dryruns
	if [[ $CXR_DRY == true ]]
	then
		
		main.log -a "Output check is not carried out for dryruns - no output was generated.\nStill we generate dummy files now..."
		
		# generate dummy files if needed
		for output_file in ${CXR_CHECK_THESE_OUTPUT_FILES}
		do
			# Still alive
			common.user.showProgress
			
			# does it exist?
			if [[ -f "${output_file}" || "$(common.fs.doesCompressedVersionExist? "${output_file}")" == true ]]
			then
				main.log -w  "File ${output_file} seems to exist or is compressed, we do not touch it."
			else	
				common.runner.createDummyFile ${output_file}
			fi
		done
		
		echo true
		return $CXR_RET_OK
	fi

	main.log -a "Checking Postconditions:"

	# Increase global indent level
	main.increaseLogIndent

	# We do word splitting
	for output_file in ${CXR_CHECK_THESE_OUTPUT_FILES}
	do
		# Still alive
		common.user.showProgress
		
		# does it exist and is it larger than 0 bytes?
		if [[ -s "${output_file}"  ]]
		then
			main.log -v  "Output File ${output_file} has non-zero size, OK."
			
			# Add the file to CXR_INSTANCE_HASH_OUTPUT_FILES value is the module that created it
			common.hash.put $CXR_INSTANCE_HASH_OUTPUT_FILES $CXR_LEVEL_INSTANCE  "${output_file}" "${CXR_META_MODULE_NAME}"
			
		else
			main.log -e "File $(basename ${output_file}) was not created properly"
			errors_found=true
		fi
	done
	# Decrease global indent level
	main.decreaseLogIndent
	
	if [[ "$errors_found" == false  ]]
	then
		# No errors
		echo true
	else
		# Detected errors
		echo false
	fi
}

################################################################################
# Function: common.check.isVersionSupported?
#	
# Checks if a version number is supported by a given model.
#
# Returns:
# 0 if ok, 1 otherwise
#
# Parameters:	
# $1 - The Version to check
# $2 - The Model name as indicated in CXR_SUPPORTED_MODELS
################################################################################
function common.check.isVersionSupported?()
################################################################################
{
	if [[ -z "${1:-}" ]]
	then
		# Forget it - must be larger than ""
		return 1
	fi
	
	local version
	local model
	local model_id
	local supported
	local found
	
	version=$1
	model=$2
	model_id="$(common.runner.getModelId "$model")" || main.dieGracefully "Model $model is not known."
	supported="${CXR_SUPPORTED_MODEL_VERSIONS[${model_id}]}"
	
	# Check the Version
	found=$(main.isSubstringPresent? "$supported" "$version")
	
	if [[ $found == true ]]
	then
		# found, ok
		return 0
	else
		main.log -e   "Version $1 of $2 is not supported by CAMxRunner. Adjust CXR_SUPPORTED_MODEL_VERSIONS\n(Currently $supported)"    
		return 1
	fi
}

################################################################################
# Function: common.check.runner
#	
# A Quick check to see if the CAMxRunner installation is OK
# and consistent with config (can be extended...)
################################################################################
function common.check.runner() 
################################################################################
{
	# Disable checks for fast guys
	if [[ $CXR_FAST == true ]]
	then
		return $CXR_RET_OK
	fi
	
	# Each directory in $CXR_RUN_SUBDIRS must exist
	local dir
	local subdir
	
	# Increase global indent level
	main.increaseLogIndent

	main.log -v "Checking if subdirectories exist..."
	
	for SUBIDR in $CXR_RUN_SUBDIRS
	do
		# Increase global indent level
		main.increaseLogIndent

		if [[ ! -d $CXR_RUN_DIR/$SUBIDR ]]
		then
			# Oh Oh!
			mkdir -p $CXR_RUN_DIR/$SUBIDR
			main.log -v "The directory $CXR_RUN_DIR/$SUBIDR did not exist. According to the Variable CXR_RUN_SUBDIRS it should exist, however. I created it now, but you need to fill it with sensible stuff!" 
		else 
			main.log -v "The directory $CXR_RUN_DIR/$SUBIDR exists"
		fi
		
		# Decrease global indent level
		main.decreaseLogIndent
	done
	
	# Check executables
	
	############################################################################
	main.log -v "Checking if all executables are present and executable..."
	
	# Increase global indent level
	main.increaseLogIndent
	
	########################################
	main.log -v "Checking external files..."
	########################################
	
	# Increase global indent level
	main.increaseLogIndent
	
	common.check.Vars
	
	# Decrease global indent level
	main.decreaseLogIndent
	
	# Decrease global indent level
	main.decreaseLogIndent
	
	# Decrease global indent level
	main.decreaseLogIndent
	############################################################################
	
	# Each directory in $CXR_RUN_VERSION_SUBDIRS must have 
	# one subdir for each model and each version 
	
	main.log -v "Checking if version sub-subdirectories exist..."
	
	for subdir in $CXR_RUN_VERSION_SUBDIRS
	do
		
		# Increase global indent level
		main.increaseLogIndent
		
		main.log -v "Checking subdirs of $subdir..."
		
		for model in $CXR_SUPPORTED_MODELS
		do
		
			main.log -v "Checking model $model..."
		
			# Get id of the current model
			model_id=$(common.runner.getModelId "$model") || main.dieGracefully "model $model is not known."
	
			# Extract the list of supported versions
			supported="${CXR_SUPPORTED_MODEL_VERSIONS[${model_id}]}"
	
			for version in $supported
			do
				
				main.log -v "Checking version $version..."
				
				dir=$CXR_RUN_DIR/$subdir/$model/$version
			
				if [[ ! -d $dir  ]]
				then
					# Oh Oh!
					mkdir -p $dir
					main.log  "The directory $dir did not exist. All directories stored in CXR_RUN_VERSION_SUBDIRS need a subdirectory for each supported version of model and each supported version  (stored in CXR_SUPPORTED_MODEL_VERSIONS).\n I created this one now, but if you want to use model $model $version you need to fill it with sensible stuff!"
				else
	
					main.log -v  "The directory $CXR_RUN_DIR/$subdir/$version exists"
	
				fi
			done # Versions
			
		done # model
		
		# Decrease global indent level
		main.decreaseLogIndent
	done # Directory
	
	# Decrease global indent level
	main.decreaseLogIndent
}


################################################################################
# Function: common.check.RunName
#	
# Checks if run name has correct form and length (max 60 characters)
# e. g. 
# CAMx-v4.51-ENVIRON_testcase or
# PMCAMx-v3.01-test
#
# As an exception, "installer" is accepted.
#
# So we basically split using "-"
#
# Much of the code here is repeated from <main.setModelAndVersion>
#
# Returns:
# Returns true if OK, false otherwise.
#
# Parameters:
# $1 - String
################################################################################
function common.check.RunName()
################################################################################
{
	local oIFS
	local run_array
	local version
	local model
	local run

	if [[ $# -ne 1 ]]
	then
		main.log -e "Programming error: needs one string as input"
		echo false
		return 1
	fi
	
	run="${1}"
	
	if [[ "$run" == installer ]]
	then
		echo  true
		return 0
	fi
	
	# Length must not exceed 60 because we use it as
	# "note" field in all files
	if [[ $(common.string.len $run) -gt 60 ]]
	then
		main.log -e "A run name must not be longer than 60 characters!"
		echo false
		return 0
	fi
	
	# Split it
	oIFS="$IFS"

	IFS=-

	# Suck line into array
	run_array=($run)

	# Reset IFS
	IFS="$oIFS"
	
	# First, there is the model
	model=${run_array[0]}
	
	# Then there is vVersion, remove v to the left:
	version=${run_array[1]#v}
	
	#This returns non-0 if it's not ok
	common.check.isVersionSupported? $version $model
	
	if [[ $? -ne 0 ]]
	then
		echo false
	else
		echo true
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
	
	# Create dummy file to hash
	x=$(common.runner.createTempFile test)
	echo  "Franz jagt im komplett verwahrlosten Taxi quer durch Bayern" > $x
	
	########################################
	# Tests. If the number changes, change CXR_META_MODULE_NUM_TESTS
	########################################
	
	is $(common.check.DataType 1 I) true "common.check.DataType 1 I"
	is $(main.getMD5 $x) 4868ac39fdeb60e886791d6be8c0fcb3 "main.getMD5 strings test"

	########################################
	# teardown tests if needed
	########################################
	
}
