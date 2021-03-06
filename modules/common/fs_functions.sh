# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Common script for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Title: Filesystem functions of CAMxRunner.
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
CXR_META_MODULE_NUM_TESTS=41

# This string describes special requirements this module has
# it is a space-separated list of requirement|value[|optional] tuples.
# If a requirement is not binding, optional is added at the end
CXR_META_MODULE_REQ_SPECIAL="exec|dos2unix exec|unix2dos"

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Contains filesystem and memory functions for the CAMxRunner"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2010), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'


################################################################################
# Function: common.fs.isNotEmpty?
# 
# Returns true if argument is an non-empty file, false otherwise.
# Used mostly as a wrapper for testing
#
# Parameters:
# $1 - path of file to test
################################################################################
function common.fs.isNotEmpty?()
################################################################################
{
	if [[ -s "${1}" ]]
	then
		echo true
	else
		echo false
	fi
}

################################################################################
# Function: common.fs.isFilledDir?
# 
# Returns true if argument is an existing directory with content, false otherwise.
#
# Parameters:
# $1 - path of directory to test
################################################################################
function common.fs.isFilledDir?()
################################################################################
{
	path="${1}"
	
	if [[ -e "$path" ]]
	then
		if [[ "$(ls -A $path)" ]]
		then
			echo true
		else
			echo false
		fi
	else
		# Non-existing
		echo false
	fi
}

################################################################################
# Function: common.fs.exists?
# 
# Returns true if argument is an existing file, false otherwise.
# Used mostly as a wrapper for testing
#
# Parameters:
# $1 - path of file to test
################################################################################
function common.fs.exists?()
################################################################################
{
	if [[ -f "${1}" ]]
	then
		echo true
	else
		echo false
	fi
}

################################################################################
# Function: common.fs.isAbsolutePath?
# 
# Returns true if argument is an absolute path, false otherwise.
# An NFS-like path of the form machine:/some/path also works
#
# Parameters:
# $1 - path to test
################################################################################
function common.fs.isAbsolutePath?()
################################################################################
{
	path="$1"
	
	# Remove machine, if any
	case "$path" in
		/*) echo true ;;
		*) 
			# remove machine name, if any
			path=${path#*:}
			# Try again
			case "$path" in
				/*) echo true ;;
				*) echo false ;;
			esac
			;;
	esac
}

################################################################################
# Function: common.fs.sumFilenameLenght
# 
# Sums the length of all filenames in a directory. We do this because AFS
# has a limitation on this number in each directory.
# For hen-and-egg reasons, we use mktemp directly here (<common.runner.createTempFile>
# sometimes calls this function here)
#
# Parameters:
# $1 - directory to test
################################################################################
function common.fs.sumFilenameLenght()
################################################################################
{
	local dir
	local len
	local file
	
	dir="$1"
	
	if [[ -d "$dir" ]]
	then
		file="$(mktemp ${CXR_TMP_DIR}/sum.XXXXXXXX)"
		
		# Let find store all "raw" filenames next to each other in $file
		find ${dir}/ -noleaf -maxdepth 1 -fprintf $file "%P"
		
		# Count the bytes 
		len="$(wc -c < $file)"
		
		# tempfile no longer needed
		rm -f $file
	else
		main.log -w "$dir is not a directory!"
		len=0
	fi
	
	echo $len
}

################################################################################
# Function: common.fs.getSubDirs
# 
# Returns a newline-separated list of subdirectories of a directory (no path component).
# Also returns any softlinks that point to directories.
# Does not return "." or ".."
#
# Parameters:
# $1 - path to look at
################################################################################
function common.fs.getSubDirs()
################################################################################
{
	local dir
	
	dir="$1"
	
	find "${dir}" -follow -noleaf -maxdepth 1 -type d  -printf '%f\n' | sed '/^\.$/d' | sed '/^\.\.$/d'

}

################################################################################
# Function: common.fs.isSubDirOf?
# 
# Returns true if argument1 is (in) a subdir of argument2.
# If they two paths are the same, they are defined to be subdirs of each other.
# Also works if the first path is the path to a file. 
# Empty strings are accepted as well and are not subdirs by definition
#
# Parameters:
# $1 - path to test if it is a subdir
# $2 - path suspected to be the root
################################################################################
function common.fs.isSubDirOf?()
################################################################################
{
	# first, we need proper names
	local path1
	local path2
	
	path1="$1"
	path2="$2"
	
	if [[ -z "$path1" || -z "$path2" ]]
	then
		echo false
	else
		# If they are the same, they are subdirs of each other by definition
		if [[ "$path1" == "$path2" ]]
		then
			echo true
		else
			# They are not the same
			# We add a slash to the suspected root unless the last character is a slash
			if [[ "${path2: -1}" != "/" ]]
			#              �
			#     This space is vital, otherwise, bash thinks we mean a default (see http://tldp.org/LDP/common.math.abs/html/string-manipulation.html)
			then
				path2="$path2"/
			fi
			
			# If path1 is a subdir of path2,
			# the string making up path1 must be the start of path2
			if [[ "$(main.isSubstringPresent? "$path1" "$path2")" == true ]]
			then
				echo true
			else
				echo false
			fi # subdirs?
		fi # the same
	fi # empty?
	
}



################################################################################
# Function: common.fs.getType
# 
# Gets the filesystem a file or directory resides on. Needs full path.
# Returns the empty string on error.
# Can translate a few ones that stat does not always know.
# (See "man statfs" for more)
#
# Parameters:
# $1 - path to test
################################################################################
function common.fs.getType()
################################################################################
{
	local path
	
	path=${1}

	result="$(stat -f -L -c %T "$path")"
	
	# Fix some standard unknowns
	if [[ "$result" == "UNKNOWN (0x5346414f)" ]]
	then
		result=afs
	elif [[ "$result" == "UNKNOWN (0xff534d42)" ]]
	then
		result=cifs
	fi
	
	echo "$result"
}


################################################################################
# Function: common.fs.afsCheckToken
# 
# Returns true if the user has a valid AFS token or if AFS is not available,
# false if no valid token was found.
# 
################################################################################
function common.fs.afsCheckToken()
################################################################################
{
	local token_exec
	local num_tokens
	local result
	
	token_exec=$(which tokens)
	
	if [[ $? -ne 0 ]]
	then
		echo true
		return $CXR_RET_OK
	fi
	
	num_tokens=$(tokens | grep Expires | wc -l)
	
	if [[ $num_tokens -gt 0 ]]
	then
		result=true
	else
		main.log -w "No valid tokens for AFS where found!"
		result=false
	fi
	
	echo $result
}


################################################################################
# Function: common.fs.isLocal?
# 
# Returns true if a given path is on a local (non-networked) Filesystem, false otherwise.
#
# Parameters:
# $1 - path to test
################################################################################
function common.fs.isLocal?()
################################################################################
{
	local path
	local type
	
	path=${1}
	type="$(common.fs.getType "$path")"
	
	case "$type" in
	
		afs|nfs|cifs)	echo false ;;
		*) echo true ;;
	
	esac
}

################################################################################
# Function: common.fs.sameDevice?
# 
# Returns true if the two arguments reside on the same device.
# This test is crucial whan attempting to hard-link.
# Note that on AFS, hardlinks are impossible between different directories even
# if they reside on the same device.
#
# Parameters:
# $1 - path1 to test
# $2 - path2 to test
################################################################################
function common.fs.sameDevice?()
################################################################################
{
	local file1
	local file2
	local dev1
	local dev2
	
	file1="$1"
	file2="$2"
	
	dev1="$(stat -c"%d" "${file1}")"
	dev2="$(stat -c"%d" "${file2}")"
	
	if [[ "$dev1" -eq "$dev2" ]]
	then
		echo true
	else
		echo false
	fi
}

################################################################################
# Function: common.fs.getMtime
# 
# Returns the files mtime (modification time, last update of the data, or touch)
# As seconds since epoch (January 1, 1970).
# Returns 0 on error.
# Since we use this function to detect stale locks, it quite possible that we 
# call it with non-existing filenames
#
# Parameters:
# $1 - filename to analyse
################################################################################
function common.fs.getMtime()
################################################################################
{
	local file
	local mtime
	
	file=$1
	
	# Dereference symlink, if needed
	mtime="$(stat -L "${file}" -c"%Y" 2>/dev/null)"
	
	if [[ -z "$mtime" ]]
	then
		main.log -v "Could not stat ${file}"
		mtime=0
	fi
	
	echo "${mtime}"
}

################################################################################
# Function: common.fs.getFileType
# 
# Returns a parsed version of the output of "file" where all is lowercase.
# Returns the empty string if the file is not readable.
# Some noteable types:
# - CAMx Binary output files are "mpeg"
# - other binary data is "data"
# - ascii denotes ascii files
#
# Parameters:
# $1 - file to test
################################################################################
function common.fs.getFileType()
################################################################################
{
	local file
	local filetype
	
	file=$1
	
	filetype=$(common.string.toLower $(file "${file}" | cut -f2 -d' '))
	
	if [[ $(common.array.allElementsZero? "${PIPESTATUS[@]}") == false ]]
	then
		# Something went wrong
		main.log -e  "the file command reported an error for $file"
		echo ""
	else
		echo "$filetype"
	fi
}



################################################################################
# Function: common.fs.isDos?
# 
# Returns a parsed version of the output of "file", can detect dos-files.
#
# Parameters:
# $1 - file to test
################################################################################
function common.fs.isDos?()
################################################################################
{
	local file
	local filetype
	
	file=$1
	
	
	# Grep returns a string if found
	found="$(file "${file}" | grep "CRLF line terminators" )"
	
	if [[ "$found" ]]
	then
		echo true
	else
		echo false
	fi
}

################################################################################
# Function: common.fs.getLinkTarget
#
# Returns the link target of a file/directory (even if target is non-existing).
# Throws a warning on error (for example if the input is non-existing but we expect it to be there)
# Resolves any component (!) of a path.
# Does not work in MacOSX: 
# <http://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script>
#
# if "allow missing path components" is true, we allow any path component to be non-existing.
# By default, just the file is allowed to be missing.
#
#
# Parameters:
# $1 - path to link to dereference
# $2 - allow missing path components (default false)
################################################################################
function common.fs.getLinkTarget()
################################################################################
{
	local path
	local target
	
	path="$1"
	allow_missing="${2:-false}"
	
	if [[ $allow_missing == true ]]
	then
		# Allow missing targets
		target="$(readlink -m -s "$path")"
	else
		# Don't allow missing targets
		target="$(readlink -f -s "$path")"
		
		if [[ ! -e "$target" ]]
		then
			main.log -w "Link target $target does not exist."
		fi
		
	fi
	
	echo "$target"
}

################################################################################
# Function: common.fs.isLink?
#
# Returns true if the argument is a link (or contains one), false otherwise.
# As a side effect, the variable _target will contain the target of the link
# or the original path, also _result will contain true or false.
# The Empty string is not a link by definition.
#
# Note that this function also deal with "partial links"
# that is with files which contain a path component that is a link.
# test -L does not offer this.
#
# Because this is a costly function, its recommended to call it like this:
# > common.fs.isLink? $(dirname "${output_file}") &> /dev/null
# > if [[ "$_result" == true ]]
# > then
# > 	# target is in $_target
#
# Parameters:
# $1 - path to link to test
################################################################################
function common.fs.isLink?()
################################################################################
{
	local path
	
	path="$1"
	
	# Get the target and store globally (allow missing links and files)
	_target="$(common.fs.getLinkTarget $path true)"
	# Result is global, too
	_result=false
	
	if [[ ! -z "$path" && "$_target" != "$path" ]]
	then
		# Link
		_result=true
	else
		# No Link
		_result=false
	fi # Link?
	
	echo $_result
}

################################################################################
# Function: common.fs.isBrokenLink?
#
# Returns true if the argument is a broken link, false otherwise.
# The Empty string is broken by definition, a non-existent file is not a broken link.
# Note: One reason for a broken link is that the target of the link was compressed!
# 
#
# Parameters:
# $1 - path to link to test
################################################################################
function common.fs.isBrokenLink?()
################################################################################
{
	local path
	local target
	
	path="$1"
	
	# This is more powerful than test -L
	common.fs.isLink? "$path" &> /dev/null
	
	if [[ $_result == false ]]
	then
		# Not a link, hence not broken
		echo false
	else
		if [[ -z "$path" || ! -e "$_target" ]]
		then
			# Broken
			echo true
		else
			# OK
			echo false
		fi # Broken?
	fi
}


################################################################################
# Function: common.fs.FileSizeMb
#
# Returns the number of megabytes used by a file, rounded to the nearest MB
#
# Parameters:
# $1 - path to file to test
################################################################################
function common.fs.FileSizeMb()
################################################################################
{
	local size
	
	if [[ ! -f "$1"  ]]
	then
		main.log -w  "The file $1 does not exist!"
		echo 0
		return $CXR_RET_PARAM_ERROR
	fi
	
	# Tail is needed in case this is run on a directory
	size=$(du -m "$1" | tail -n1 | cut -f1)
	
	echo $size
	
	return $CXR_RET_OK
}

################################################################################
# Function: common.fs.WaitForFile
#
# Waits for a file to appear. Returns true on success, false otherwise
#
# Parameters:
# $1 - path to file to test
#
# Variables:
# $CXR_TIMEOUT_MINS - number of minutes to wait for this file
# $CXR_TOTAL_WAITING_MINS - total number of minutes to wait
################################################################################
function common.fs.WaitForFile()
################################################################################
{
	local filename
	filename="$1"
	
	
	until [[ -f $filename && ! ( $waited_mins -gt $CXR_TIMEOUT_MINS || $total_waited_mins -gt $CXR_TOTAL_WAITING_MINS ) ]]
	do
		sleep ${CXR_WAITING_SLEEP_SECONDS}
		waited_mins=$(( ($waited_mins + $CXR_WAITING_SLEEP_SECONDS)/60  ))
		total_waited_mins=$(( $total_waited_mins + $waited_mins  ))
	done
	
	# If we arrive here and the file is not there, we failed
	if [[ ! -f "$filename" ]]
	then
		main.log -e  "$filename still does not exist, timeout reached."
		echo false
	else
		main.log -v  "$filename exists now."
		echo true
	fi
}

################################################################################
# Function: common.fs.WaitForStableSize
#
# Waits until a file has a constant size. Returns true on success, false otherwise
#
# Parameters:
# $1 - path to file to test
#
# Variables:
# $CXR_TIMEOUT_MINS - number of minutes to wait for this file
# $CXR_TOTAL_WAITING_MINS - total number of minutes to wait
################################################################################
function common.fs.WaitForStableSize()
################################################################################
{
	local filename
	local old_size
	
	filename="$1"
	old_size=0
	
	until [[ $(common.fs.FileSizeMb $filename) -eq $old_size  &&  ( $waited_mins -gt $CXR_TIMEOUT_MINS || $total_waited_mins -gt $CXR_TOTAL_WAITING_MINS ) ]]
	do
		# Store the current size as old
		old_size="$(common.fs.FileSizeMb $filename)"
		
		sleep ${CXR_WAITING_SLEEP_SECONDS}
		waited_mins=$(( ($waited_mins + $CXR_WAITING_SLEEP_SECONDS)/60  ))
		total_waited_mins=$(( $total_waited_mins + $waited_mins  ))
	done
	
	# We fail if the filesize is 0 or it still grows
	if [[ $(common.fs.FileSizeMb $filename) -eq 0 || $(common.fs.FileSizeMb $filename) -ne $old_size ]]
	then
		main.log -e  "$filename still seems to grow."
		echo false
	else
		main.log -v  "$filename size is stable now."
		echo true
	fi
}

################################################################################
# Function: common.fs.CompressOutput
# 
# Compresses either all output files or such that match the pattern in
# CXR_COMPRESS_OUTPUT_PATTERN and are bigger than CXR_COMPRESS_THRESHOLD_MB
#
# Parameters:
# None.
#
# Variables:
# $CXR_COMPRESS_OUTPUT - if true, we do it, otherwise not
# $CXR_COMPRESS_OUTPUT_PATTERN - Pattern we apply to both filenames and module names. If match - we compress
#
# Conf:
# common.compressor.* - Maps filetypes to compressors
#
# Hashes:
# $CXR_INSTANCE_HASH_OUTPUT_FILES - Hash of files to compress
################################################################################
function common.fs.CompressOutput()
################################################################################
{
	local filename
	local module
	local do_this
	local found
	local arrKeys
	local keyString
	local compressor
	
	if [[ "${CXR_COMPRESS_OUTPUT}" == true && "${CXR_DRY}" == false ]]
	then
	
		main.log -a "Compressing output files..."
	
		# common.hash.getKeysAndValues returns a newline-separated list
		oIFS="$IFS"
		IFS='
'
		# looping through filename|module pairs
		for pair in $(common.hash.getKeysAndValues $CXR_INSTANCE_HASH_OUTPUT_FILES $CXR_LEVEL_INSTANCE)
		do
			
			# Reset IFS
			IFS="$oIFS"
			
			# Parse the DB string
			oIFS="$IFS"
			IFS="$CXR_DELIMITER"
			
			set $pair
			
			filename="$1"
			module="$2"
			# Reset IFS
			IFS="$oIFS"
		
			main.log -v "Testing if we compress $filename (created by $module)..."
			
			if [[ -s "${filename}" ]]
			then
				# OK file is not empty
				
				# We do not yet know if we need to do it
				do_this=false
			
				# Do we need to do pattern matching?
				if [[ "${CXR_COMPRESS_OUTPUT_PATTERN:-}" ]]
				then
					################
					# Check filename
					################
					found=$(expr match "${filename}" "${CXR_COMPRESS_OUTPUT_PATTERN}")  || :
					
					if [[ $found -gt 0 ]]
					then
						# Do it
						do_this=true
					else
						################
						# filename did not match - try module name
						################
						found=$(expr match "${module}" "${CXR_COMPRESS_OUTPUT_PATTERN}")  || :
				
						if [[ $found -gt 0  ]]
						then
							# Do it
							do_this=true
						else
							main.log -v  "Pattern ${CXR_COMPRESS_OUTPUT_PATTERN} did not match ${filename} or ${module}, will not compress this file"
						fi
					fi
				else
					# No Pattern matching needed
					do_this=true
				fi
				
				# Do it if it is large enough
				if [[ "$do_this" == true  ]]
				then
					if [[ $(common.fs.FileSizeMb ${filename}) -ge "${CXR_COMPRESS_THRESHOLD_MB}"  ]]
					then
						# Find out which compressor to use
						type=$(common.fs.getFileType ${filename})
						compressor=$(common.conf.get "common.compressor.${type}")
						
						if [[ ! -x $(echo $compressor | cut -d" " -f1) ]]
						then
							# is there a default?
							main.log -v "Found no executable configuration item common.compressor.${type} - checking for default..."
							compressor=$(common.conf.get "common.compressor.default")
							
							if [[  ! -x $(echo $compressor | cut -d" " -f1) ]]
							then
								main.log -v "Found no executable configuration item common.compressor.default - using CXR_FALLBACK_COMPRESSOR_EXEC"
								compressor="$CXR_FALLBACK_COMPRESSOR_EXEC"
								
									if [[  ! -x $(echo $compressor | cut -d" " -f1) ]]
									then
										# we are in trouble
										main.log -e "Not even CXR_FALLBACK_COMPRESSOR_EXEC ($CXR_FALLBACK_COMPRESSOR_EXEC) is executable!"
										continue
									fi
							fi # no default?
							
						fi # Compressor set?
						
						
						main.log -a "Compressing ${filename} using ${compressor}"
						${compressor} "${filename}"
					else
						main.log -w "${filename} is smaller than CXR_COMPRESS_THRESHOLD_MB (${CXR_COMPRESS_THRESHOLD_MB}) - will not compress it."
					fi
				fi
			else
				#File empty
				main.log -w  "The output file ${filename} is empty, no compression attempted!"
			fi
		done # Loop over files
		

	else
		main.log -a "Will not compress any output files (either dry run or CXR_COMPRESS_OUTPUT is false.)"
	fi
}

################################################################################
# Function: common.fs.doesCompressedVersionExist?
# 
# Checks if there is a compressed version of an input file around, returns true if so, false otherwise.
# Checks only the name of the file, not its type.
# Is not used by <common.fs.TryDecompressingFile> by design, but is used e. g.
# by <common.check.postconditions> to detect existing, but compressed files.
#
# To detect compressed files, we rely on the common.decompressor. configuration settings.
#
#
# Parameters:
# $1 - path to test
################################################################################
function common.fs.doesCompressedVersionExist?()
################################################################################
{
		local input_file
		local iExt
		local ext
		local comp_file
		local variable
		local index
		local ext
		
		input_file=${1:-/dev/null}
		
		# Extract all possible extensions
		# Looks like this:
		# common.decompressor.lzo|/path/to/lzop
		# common.decompressor.zip|/path/to/unzip
		extension_list="$(common.conf.enumerate common.decompressor)"
		
		if [[ "$extension_list" ]]
		then
			
			# looping through pairs
			# Set IFS to newline only
			oIFS="$IFS" 
			IFS='
'
			for pair in $extension_list
			do
				# Reset IFS
				IFS="$oIFS"

				oIFS="$IFS"
				IFS="$CXR_DELIMITER"
				set $pair
				variable="$1"
				IFS="$oIFS"
				
				# Extract extension from 
				# common.decompressor.*
				ext=$(echo $variable | cut -d"." -f3)
				
				if [[ "$ext" ]]
				then
					# ext is an extension w/o dot (e. g. gz)
					comp_file="${input_file}.${ext}"
					main.log -v  "Looking for $comp_file"
					
					if [[ -r "$comp_file" ]]
					then
						echo true
						return $CXR_RET_OK
					fi
				fi
			done
		else
			# No extensions found
			main.log -w "There are no settings in the common.decompressor.* configuration.\nWithout this, CAMxRunner knows no compressed formats."
		fi
		
		# If we arrive here, its not compressed with a known compressor
		echo false
}

################################################################################
# Function: common.fs.TryDecompressingFile
# 
# Checks if an input file is compressed, decompresses it and returns a new name.
# Wo do this by searching files that have specific suffixes added to their name.
# We decompress even if its a dry-run.
# We always leave the original file (compressed) where it is.
#
# It is possible that there is more than one compressed version of a file,
# we decompress the first file we find.
#
# Due to potential permission issues, we decompress into a temp dir unless CXR_DECOMPRESS_IN_PLACE is true.
# Therefore, we need to keep track which files where decompressed to which tempfiles.
# This is stored in the hash CXR_GLOBAL_HASH_DECOMPRESSED_FILES.
# If we do this (and consequently the name changes), _name_changed is set to true.
#
# If the decompression fails, we return the input string.
#
# This function is directly used by <common.runner.evaluateRule>
#
# Parameters:
# $1 - path to test. This is a filename without compression extension!
################################################################################
function common.fs.TryDecompressingFile()
################################################################################
{
	if [[ $# -ne 1 ]]
	then
		main.dieGracefully "Could not try decompression - no path passed!"
	fi #params ok?
	
	local input_file
	
	local was_compressed
	local line
	local tempfile
	local sed_tmp
	local iExt
	local ext
	local comp_file
	local filetype
	local new_file

	local tempfile
	local dirhash
	local input_dir
	
	local decompressor
	
	# Set initial value of name change indicator
	_name_changed=false
	
	input_file="$1"
	# We assume that in was not compressed
	was_compressed=false
	
	input_dir="$(dirname "${input_file}")"
	
	if [[ "$CXR_DETECT_COMPRESSED_INPUT_FILES" == true ]]
	then
		main.log -v -B "Testing compression on $(basename ${input_file})..."
	
		# Check first if we already have decompressed this file
		common.hash.has? $CXR_GLOBAL_HASH_DECOMPRESSED_FILES $CXR_LEVEL_GLOBAL "${input_file}" > /dev/null
		
		if [[ "$_has" == true ]]
		then
			# Seems like we already did this file
			# The tempfile is the value
			tempfile="$_value"
			
			if [[ -s "$tempfile" ]]
			then
				# tempfile not empty
				main.log -v "File ${input_file} was already decompressed into $tempfile"
			
				echo "$tempfile"
				return $CXR_RET_OK
			else
				# tempfile empty, need to repeat
				main.log -v  "File ${input_file} was already decompressed into $tempfile but for some reason that file is empty!"
			fi	# Got empty file?
		fi # Entry found in hash of compressed files
		
		# Extract all possible extensions
		# Looks like this:
		# common.decompressor.lzo|/path/to/lzop
		# common.decompressor.zip|/path/to/unzip
		extension_list="$(common.conf.enumerate common.decompressor)"

		if [[ "$extension_list" ]]
		then
			
			# looping through pairs
			# Set IFS to newline only
			oIFS="$IFS" 
			IFS='
'
			for pair in $extension_list
			do
				# Reset IFS
				IFS="$oIFS"

				oIFS="$IFS"
				IFS="$CXR_DELIMITER"
				set $pair
				variable="$1"
				decompressor="$2"
				
				IFS="$oIFS"
				
				# Extract extension from 
				# common.decompressor.*
				ext=$(echo $variable | cut -d"." -f3)
				
				if [[ "$ext" ]]
				then
					# ext is an extension w/o dot (e. g. gz)
					comp_file="${input_file}.${ext}"
					main.log -v  "Looking for $comp_file"
					
					if [[ -r "$comp_file" ]]
					then
						# File is readable
				
						# We decompress into a tempfile if we don't decompress in place
						# or if we are not allowed to write to the destination
						if [[ "$CXR_DECOMPRESS_IN_PLACE" == false || ! -w "${input_dir}" ]]
						then
							# We write to our special decompression directory. 
							# we use the MD5 hash of the path to make sure we do not overwrite files
							# of same names
							dirhash="$(common.string.MD5 "${input_dir}")"
							
							mkdir -p "$CXR_TMP_DECOMP_DIR/$dirhash"
							
							tempfile="$CXR_TMP_DECOMP_DIR/$dirhash/$(basename ${input_file})"
							# We now know that the name will change
							_name_changed=true
						else
							# The target is the "original" file name
							tempfile="${input_file}"
							
							# Its possible that the file is already decompressed
							if [[ -e "$tempfile" ]]
							then
								main.log -w "File $tempfile is already decompressed!"
								new_file=$tempfile
								was_compressed=true
								break
							fi # Decompessed file already there?
						fi # Decompress in place?
						
						# There may already be parameters, we
						# just add  -c
						$decompressor -c "$comp_file" > $tempfile
			
						# Check retval of decompressor
						if [[ $? -eq 0 ]]
						then
							was_compressed=true
							new_file=$tempfile
							break
						else
							main.log -e "File ${comp_file} could not be decompressed!"
						fi # Retval ok?
						
					fi # File readable?
				fi # extension set?
			done # Loop over extensions

			if [[ "$was_compressed" == true  ]]
			then
				# Put into Hash with new_file as value
				common.hash.put $CXR_GLOBAL_HASH_DECOMPRESSED_FILES $CXR_LEVEL_GLOBAL "${input_file}" "$new_file"
			
				echo "$new_file"
			else
				# Was not compressed
				main.log -v  "File ${input_file} is not compressed."
				echo "$input_file"
			fi # was it compressed?
			
		else 
			# Extension list was empty
			main.log -w "There are no settings in the common.decompressor.* configuration.\nWithout this, CAMxRunner knows no compressed formats."
			echo "$input_file"
		fi # Extension list
		
	else
		# We do not consider compressed files
		main.log -v  "We do not try to decompress files, CXR_DETECT_COMPRESSED_INPUT_FILES is false"
		echo "$input_file"
	fi # Detect compression?
}

################################################################################
# Function: common.fs.getFreeMb
#
# returns the number of megabytes free in given path (floored?)
# This might actually fail on non Linux-systems...
# Returns -1 if free space cannot be determined.
#
#
# Internally determines the FS type; AFS support works only if quotas are in place.
#
# Parameters:
# $1 - path to test
################################################################################
function common.fs.getFreeMb()
################################################################################
{
	if [[ $# -ne 1 ]]
	then
		main.log -e "$FUNCNAME did not get correct parameters: $*"
		echo 0
		return $CXR_RET_OK
	fi
	
	local last_line
	local fs
	local oIFS
	local quota_array
	local free_kb
	local free_mb
	local path
	
	path="$1"
	
	# Get File system
	fs=$(common.fs.getType $path)
	
	case $fs in
	afs)
			main.log -v  "Directory $path seems to be on AFS. Getting AFS quota, if any..."
			
			# Get last line
			last_line=$(fs listquota "$path" | tail -n1)
			
			if [[ "$(main.isSubstringPresent? "$last_line" "no limit" )" == true ]]
			then
				main.log -w "There seems to be no AFS quota on $path, cannot determine free space"
				
				echo -1
			else
				# Quota must be taken into account
			
				# Suck line into LINE_ARRAY
				# Line looks like this:
				# usr.oderbolz                3000000   2440839   81%         90%
				# or this
				# usr.oderbolz                5000000   3319991   66%        174%<<  <<WARNING
				# or even this:
				# lacfs.nb                   no limit-2092752580    0%       1077%<<  <<WARNING
				quota_array=($last_line)
				
				# Calculate free KiBi
				free_kb=$(( ${quota_array[1]} - ${quota_array[2]} ))
				
				# Convert to MB
				free_mb=$(( $free_kb / 1024 ))
				
				echo $free_mb
			fi
			;;
	*) 
			# Default
			df --block-size=1M $path | tail -n1 | awk '{ print $3 }'
			;;
	esac
}

################################################################################
# Function: test_module
#
# Runs the predefined tests for this module. If you add or remove tests, please
# update CXR_META_module_NUM_TESTS in the header!
# 
################################################################################	
function test_module()
################################################################################
{
	local a
	local b
	local c
	local d
	local link
	local dirlink
	local dirtarget
	local tempdir
	local suffix
	
	########################################
	# Setup tests if needed
	########################################
	
	# We need a few tempfiles
	a=$(common.runner.createTempFile $FUNCNAME)
	b=$(common.runner.createTempFile $FUNCNAME)
	c=$(common.runner.createTempFile $FUNCNAME)
	d=$(common.runner.createTempDir $FUNCNAME)
	e=$(common.runner.createTempDir $FUNCNAME)
	
	# To really test the linking stuff, we ned to now the resolved name of
	# the tempdir
	tempdir="$(common.fs.getLinkTarget $CXR_TMP_DIR)"
	dirtarget=$tempdir/$(basename $d)
	
	link=$(common.runner.createTempFile $FUNCNAME)
	dirlink=$(common.runner.createTempFile $FUNCNAME)

	ln -s -f $a $link
	ln -s -f $d $dirlink
	
	# Create a file that resides in a linked directory
	touch $d/testfile
	
	echo "Hallo" > "$a"
	echo "Velo" >> "$a"
	
	echo "Hallo" > "$c"
	echo "Velo" >> "$c"
	
	# Set settings
	CXR_COMPRESS_OUTPUT=true
	
	suffix="lzo"
	
	# The compressor we use to compress output
	CXR_COMPRESSOR_EXEC="${CXR_LZOP_EXEC} -U"
	
		# The compressor we use to compress output
	CXR_DECOMPRESSOR_EXEC="${CXR_LZOP_EXEC} -d -U"
	
	CXR_COMPRESS_OUTPUT_PATTERN=
	
	# Compress also very small files
	CXR_COMPRESS_THRESHOLD_MB=0
	
	# Destroy output file hash
	common.hash.destroy $CXR_INSTANCE_HASH_OUTPUT_FILES $CXR_LEVEL_INSTANCE
	
	# Add this file to the output file list
	common.hash.put $CXR_INSTANCE_HASH_OUTPUT_FILES $CXR_LEVEL_INSTANCE  "${a}" "path_functions"
	
	# Change Mtime of $a
	touch $a
	
	# This is our time
	rtc=$(date "+%s") 
	
	# MTime of file $a
	ft=$(common.fs.getMtime $a)
	
	# create a 100 MB file called $b
	dd bs=100M if=/dev/zero of=$b count=1
	
	md5_c=$(main.getMD5 $c)
	
	# Compression check
	${CXR_GZIP_EXEC} $c
	
	########################################
	# Tests. If the number changes, change CXR_META_MODULE_NUM_TESTS
	########################################
	
	# Since CXR_TMP_DIR might be a link itself, we must take precautions
	is "$(common.fs.getLinkTarget $link)" "$tempdir/$(basename $a)" "common.fs.getLinkTarget - link to a tempfile"
	is "$(common.fs.getLinkTarget $dirlink/testfile)" "$dirtarget/testfile" "common.fs.getLinkTarget - real file, linked dir"
	
	is "$(common.fs.isLink? $link)" "true" "common.fs.isLink?"
	is "$(common.fs.isLink? $dirlink/testfile)" "true" "common.fs.isLink? - real file, linked dir"
	is "$(common.fs.isLink? /dev/null)" "false" "common.fs.isLink? /dev/null"

	# We expect a difference of max 1 second (if we are at the boundary)
	differs_less_or_equal $rtc $ft 1 "common.fs.getMtime immediate, time difference ok"
	is $(common.fs.isAbsolutePath? /) true "common.fs.isAbsolutePath? /"
	is $(common.fs.FileSizeMb $a) 1 "common.fs.FileSizeMb of small file"
	is $(common.fs.FileSizeMb $b) 100 "common.fs.FileSizeMb of 100MB file"
	is $(common.fs.sameDevice? . .) true "common.fs.sameDevice? with twice the current path"
	is $(common.fs.sameDevice? /proc .) false "common.fs.sameDevice? with proc and current path"
	is "$(common.fs.getType /proc)" proc "common.fs.getType proc"
	is "$(common.fs.isLocal? /proc)" true "common.fs.isLocal? proc"
	
	is $(common.fs.doesCompressedVersionExist? "$c") true "common.fs.doesCompressedVersionExist? gzip"
	
	# We test the basename because the directory might change
	is "$(basename $(common.fs.TryDecompressingFile "$c"))" $(basename $c) "common.fs.TryDecompressingFile"
	
	# Also look at the MD5
	is "$(main.getMD5 $(common.fs.TryDecompressingFile "$c"))" "$md5_c" "common.fs.TryDecompressingFile - MD5 test"
	
	is "$(common.fs.isSubDirOf? /my_path / )" true "common.fs.isSubDirOf? root"
	is "$(common.fs.isSubDirOf? ./my_path . )" true "common.fs.isSubDirOf? relative path"
	is "$(common.fs.isSubDirOf? some/path some/otherpath )" false "common.fs.isSubDirOf? relative path"
	# That is a tough one
	is "$(common.fs.isSubDirOf? some/pathplus some/path )" false "common.fs.isSubDirOf? relative path"
	is "$(common.fs.isSubDirOf? some/path/and/more some/path )" true "common.fs.isSubDirOf? relative path"
	is "$(common.fs.isSubDirOf? some/path some/path/and/more )" false "common.fs.isSubDirOf? wrong order"
	# By definition, the same directories are subdirs of each other
	is "$(common.fs.isSubDirOf? some/path some/path )" true "common.fs.isSubDirOf? twice the same path"
	is "$(common.fs.isSubDirOf? / / )" true "common.fs.isSubDirOf? twice /"
	is "$(common.fs.isSubDirOf? . . )" true "common.fs.isSubDirOf? twice ."
	# There seem to be issues if there are hyphens in the path:
	is "$(common.fs.isSubDirOf? /afs/psi.ch/intranet/LAC/oderbolz/CAMxRuns/Runs/CAMx-v4.51-bafu3-june-2006-s147-sem202-sqt-oib/Emiss /afs/psi.ch/intranet/LAC/oderbolz/CAMxRuns/Runs/CAMx-v4.51-bafu3-june-2006-s147-sem202-sqt-oib)" true "common.fs.isSubDirOf? using hyphens"
	is "$(common.fs.isSubDirOf?  /afs/psi.ch/intranet/LAC/oderbolz/CAMxRuns/Runs/CAMx-v4.51-bafu3-june-2006-s147-sem202-sqt-oib/Emiss /afs/psi.ch/intranet/LAC/oderbolz/CAMxRuns/Runs/CAMx-v4.51-bafu3-june-2006-s147-sem202-sqt-oib/Inputs)" false "common.fs.isSubDirOf? real world"
	is "$(common.fs.isSubDirOf?   /afs/psi.ch/intranet/LAC/oderbolz/CAMxRuns/Runs/CAMx-v4.51-bafu3-june-2006-s147-sem202-sqt-oib/Inputs /afs/psi.ch/intranet/LAC/oderbolz/CAMxRuns/Runs/CAMx-v4.51-bafu3-june-2006-s147-sem202-sqt-oib/Emiss)" false "common.fs.isSubDirOf? real world"
	# Empty string test
	is "$(common.fs.isSubDirOf? /afs/psi.ch/intranet/LAC/oderbolz/CAMxRuns/Runs/CAMx-v4.51-bafu3-june-2006-s147-sem202-sqt-oib/Emiss "")" false "common.fs.isSubDirOf? right empty"
	is "$(common.fs.isSubDirOf?  "" /afs/psi.ch/intranet/LAC/oderbolz/CAMxRuns/Runs/CAMx-v4.51-bafu3-june-2006-s147-sem202-sqt-oib/Inputs)" false "common.fs.isSubDirOf? left empty"
	is "$(common.fs.isSubDirOf?  "" "")" false "common.fs.isSubDirOf? Both empty"

	
	
	# Test detection of filled dirs
	is "$(common.fs.isFilledDir? $tempdir)" true "common.fs.isFilledDir? on $tempdir"
	is "$(common.fs.isFilledDir? $d)" true "common.fs.isFilledDir? on $d"
	is "$(common.fs.isFilledDir? $e)" false "common.fs.isFilledDir? on $e"
	
	# test the dos-detection
	${CXR_UNIX2DOS_EXEC} "$a" &> /dev/null
	is $(common.fs.isDos? "$a") true "common.fs.isDos? on dos-file"
	
	${CXR_DOS2UNIX_EXEC} "$a" &> /dev/null
	is $(common.fs.isDos? "$a") false "common.fs.isDos? on unix-file"
	
	# compress
	common.fs.CompressOutput
	
	#Test
	is $(common.fs.exists? ${a}.${suffix} ) true "common.fs.CompressOutput with simple file, no pattern"
	
	# Decompress again
	${CXR_DECOMPRESSOR_EXEC} ${a}.${suffix}
	
	# Set pattern correct
	CXR_COMPRESS_OUTPUT_PATTERN="path_functions"
	
	# compress
	common.fs.CompressOutput
	
	#Test
	is $(common.fs.exists? ${a}.${suffix} ) true "common.fs.CompressOutput with simple file, matching pattern"
	
	# Decompress again
	${CXR_DECOMPRESSOR_EXEC} ${a}.${suffix}
	
	# Set pattern correct
	CXR_COMPRESS_OUTPUT_PATTERN="path_.*"
	
	# compress
	common.fs.CompressOutput
	
	#Test
	is $(common.fs.exists? ${a}.${suffix} ) true "common.fs.CompressOutput with simple file, matching pattern"
	
	# Decompress again
	${CXR_DECOMPRESSOR_EXEC} ${a}.${suffix}
	
	# Set pattern incorrect
	CXR_COMPRESS_OUTPUT_PATTERN=guagg
	
	# compress
	common.fs.CompressOutput
	
	#Test
	is $(common.fs.exists? ${a}.${suffix} ) false "common.fs.CompressOutput with simple file, not matching pattern"
	
	# No decompression needed (its not compressed)
	
	# Remove target file to test broken link function
	rm $a
	is "$(common.fs.isBrokenLink? $link)" "true" "common.fs.isBrokenLink?"
	
	########################################
	# teardown tests if needed
	########################################
	
	
}
