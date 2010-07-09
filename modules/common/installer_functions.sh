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
# 
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
CXR_META_MODULE_REQ_SPECIAL="exec|dos2unix"

# Min CAMxRunner Version needed (Revision number)
CXR_META_MODULE_REQ_RUNNER_VERSION=100

# Min Revision number of configuration needed (to avoid that old runs try to execute new modules)
# The revision number is automatically extracted from the config file
CXR_META_MODULE_REQ_CONF_VERSION=100

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Contains installation for the CAMxRunner (the modules needed are in the installer directory)"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2009), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'

################################################################################
# Function: common.install.do
#	
# * Interactively installs the CAMxRunner, CAMx and the testcase.
# * TODO: Use the state DB to keep track of what is installed already.
# * Uses <common.module.runType> to loop through the relevant files under ${CXR_INSTALLER_INPUT_DIR}
#   and executes them in order
################################################################################
function common.install.do()
################################################################################
{
	# What we do here is similar to the pre- or postprocessors:
	# - go through all the files in the installer/$CXR_MODEL_VERSION directory
	# - Run them (while checking they are not yet run)
	# The interactivity is mostly hidden in these modules
	
	local model_id
	local supported
	local oIFS
	local array
	
	main.log -a   "Checking internal files (may take a while)..."
	
	common.check.RunnerExecutables
	
	message="Do you want to run the installer for the CAMxRunner, some converters, model and the testcase?"

	while [ "$(common.user.getOK "$message" )" == true ]
	do
		# Fix the message
		message="Do you want to further run the installer for the CAMxRunner, some converters, model and the testcase (for other models/versions)?"
		
		CXR_MODEL=$(common.user.getMenuChoice "Which model should be installed?\nIf your desired model is not in this list, adjust CXR_SUPPORTED_MODELS \n(Currently $CXR_SUPPORTED_MODELS) - of course the installer needs to be extended too!" "$CXR_SUPPORTED_MODELS" "CAMx")
		
		model_id=$(common.runner.getModelId "$CXR_MODEL") || main.dieGracefully "model $CXR_MODEL is not known."
		
		# Extract the list of supported versions
		supported="${CXR_SUPPORTED_MODEL_VERSIONS[${model_id}]}"
		
		# Set the default to the first entry
		# Save old IFS
		oIFS="$IFS"
	
		IFS="$CXR_SPACE"
		
		# Suck line into array
		array=($supported)
		
		# Reset IFS
		IFS="$oIFS"
		
		DEFAULT_VERSION=${array[0]}
	
		#Generate a menu automatically
		CXR_MODEL_VERSION=$(common.user.getMenuChoice "Which version of $model should be used?\nIf your desired version is not in this list, adjust CXR_SUPPORTED_MODEL_VERSIONS \n(Currently $supported)" "$supported" "$DEFAULT_VERSION")
		
		common.check.isVersionSupported? $CXR_MODEL_VERSION $CXR_MODEL
		
		main.log  "Installing system for $CXR_MODEL $CXR_MODEL_VERSION..."
		
		# reload config for this version (the run is called "installer")
		main.readConfig "installer" "$CXR_MODEL" "$CXR_MODEL_VERSION" "$CXR_RUN_DIR"
		
		# Run the required modules (we could even select them!)
		common.module.runType ${CXR_TYPE_INSTALLER}
	
		main.log -a -b "All installation actions finished."
	done
}

################################################################################
# Function: common.install.getPatchTarget
#	
# Parses a Patch file and finds out the target file base name.
# This allows us to name the patches arbitrarily.
#
# Parameters:
# $1 - Full Path to the patch in question
################################################################################
function common.install.getPatchTarget()
################################################################################
{
	local patch=${1:-}
	local file
	
	if [[ ! -f "$patch"  ]]
	then
		main.dieGracefully "no filename passed or file not readable!"
	fi
	
	# Simple parser, we look for (See also http://en.wikipedia.org/wiki/Diff)
	# +++ /path/to/new some other stuff might be here
	# I know I spawn 2 procs here...
	file=$(basename $(grep -h '+++' "$patch" | head -n1 | cut -f2 -d' '))
	
	if [[ "$file"  ]]
	then
		echo "$file"
	else
		main.dieGracefully "Could not find any filename"
	fi
	
}

################################################################################
# Function: common.install.applyPatch
#	
# Recursively patches a number of files in a directory by applying patches in another directory.
# Refer to CAMxRunner Developers Handbook on patch naming convention.
#
# .svn directories are ignored
#
# Parameters:
# $1 - Directory containig the patches
# $2 - Directory containig the files to be patched
# $3 - an optional filename to report actions (other than the normal log)
# $4 - ask_user, if false do not prompt user for consent, default true
################################################################################
function common.install.applyPatch()
################################################################################
{
	local patch_dir="$1"
	local src_dir="$2"
	local logfile="${3:-/dev/null}"
	local ask_user="${4:-true}"
	
	local patchlist
	local curline
	local patch_file
	local file
	local len_patch_dir
	local current_dir
	local real_file
	
	if [[ ! -d "$patch_dir" || ! -d "$src_dir" ]]
	then
		main.dieGracefully "$FUNCNAE:$LINENO - needs two existing directories as input, either $patch_dir or $src_dir not found."
	fi
	
	main.log  "Applying patches in $patch_dir to $src_dir..."
	
	# Create a list of all patches in all Subdirectories of $patch_dir
	patchlist=$(common.runner.createTempFile $FUNCNAME)
	
	# Prepare the files containing all patches and no .svn stuff
	find $patch_dir -noleaf -type f -name \*.patch | grep -v ".svn" | sort > $patchlist
	# Dont check PIPESTATUS here, grep will return non-0 if no files are found 
	
	# Loop through all patches
	
	# The canonical way to loop through a file is
	# while read LINE
	# do
	# done

	# This is not possible because I want to read input from stdin as well.
	# Therefore, I use a slightly more cumbersome/inefficient construct:
	curline=1
	while [ $curline -le $(wc -l < $patchlist) ]
	do
		# Read the current line (I know this is not nice, read comment above)
		# Read first $curline lines
		# the last of which is line $curline
		patch_file=$(head -n $curline $patchlist | tail -n 1)
		
		# Test status
		if [[ $(common.array.allElementsZero? "${PIPESTATUS[@]}") == false ]]
		then
			main.dieGracefully "could not read name of file to be patched."
		fi
		
		# Is the patch a dos-file ?
		if [[ "$(common.fs.isDos? "$patch_file")" == true ]]
		then
			main.log -w  "Patch $patch_file is in dos format. I will correct this."
			${CXR_DOS2UNIX_EXEC} $patch_file
			
			if [[ $? -ne 0 ]]
			then
				main.dieGracefully "could not convert $patch_file to Unix format!"
			fi
		fi
		
		# Which file do we need to patch?
		file=$(common.install.getPatchTarget $patch_file)
		
		##########
		# Get the relative path of the current patch
		##########
		
		# How long is the part we need to romeve?
		# we add 1 because of /
		len_patch_dir=$(( ${#patch_dir} + 1 ))

		# Give back substring starting at position $len_patch_dir
		# and then the "path-part"
		current_dir=$(dirname ${patch_file:$len_patch_dir})
		
		# Complete path of the file to patch
		real_file=$src_dir/$current_dir/$file
		
		main.log -v   "$patch_file\nREAL_FILE: $real_file"

		if [[ -f $real_file  ]]
		then
			if [[ "$ask_user" == true  ]]
			then
				# Ask user
				
				main.log -a   "Found patch $(basename $patch_file). Here are the first few lines:\n$(head -n$CXR_PATCH_HEADER_LENGHT $patch_file)\n"
				
				if [[ "$(common.user.getOK "Do you want to apply the patch $(basename $patch_file) to $real_file?\nCheck if the patch is compatible with the current platform." Y )" == true  ]]
				then
					echo "Applying patch $patch_file to $real_file" >> "${logfile}"
					patch $real_file < $patch_file
					
					# Test status
					if [[ $? -ne 0 ]]
					then
						main.dieGracefully "could not patch $real_file with $patch_file"
					fi
					
				fi
			else
				# Just do it
				echo "Applying patch $patch_file to $real_file" >> "${logfile}"
				patch $real_file < $patch_file
				
				# Test status
				if [[ $? -ne 0 ]]
				then
					main.dieGracefully "could not patch $real_file with $patch_file"
				fi
			fi
		else
			main.log -e  "file $real_file does not exist. Check the header of $patch_file!"
		fi
		
		# Increment
		curline=$(( $curline + 1 ))
	done
	
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
	
	# Create a broken patch
	# According to spec, we consider only the first one
	a=$(common.runner.createTempFile)
	echo "+++ /path/to/new" > $a
	echo "+++ /path/to/newer" >> $a
	
	########################################
	# Tests. If the number changes, change CXR_META_MODULE_NUM_TESTS
	########################################
	
	is $(common.install.getPatchTarget $a) new "common.install.getPatchTarget of a broken patch"

	########################################
	# teardown tests if needed
	########################################

}