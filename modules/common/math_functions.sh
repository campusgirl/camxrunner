# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Common script for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Title: Mathematical functions otherwise missing in bash (especially floating point operations)
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
CXR_META_MODULE_NUM_TESTS=33

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Contains some math functions for the CAMxRunner, mostly to add floating point features to bash"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2010), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'

################################################################################
# Function: common.math.compareVersions
#
# Compares two numerical version strings of the form 1.2.11... (any depth)
# with each other. The comparison is done hierarchically until a decision is reached,
# so 4.4.40 is smaller than 4.5.
# Make sure to add trainling zeros when comparing, 5.30 is larger than 5.4
#
# Returns:
# - -1 if version 1 is larger than version 2
# - 0 if they are the same or on error
# - +1 if version 1 is smaller than version 2
#
# Parameters:
# $1 - Version number 1
# $2 - Version number 2
################################################################################
function common.math.compareVersions()
################################################################################
{
	local v1
	local v2
	local v1_arr
	local v2_arr
	
	local nv1
	local nv2
	local iH
	local max
	
	v1="$1"
	v2="$2"
	
	# Convert them into arrays
	oIFS="$IFS"
	IFS=.
	
	v1_arr=($v1)
	v2_arr=($v2)
	
	IFS="$oIFS"
	
	nv1=${#v1_arr[@]}
	nv2=${#v2_arr[@]}
	
	# We loop over the smaller array
	if [[ $nv1 -lt $nv2 ]]
	then
		max=$nv1
	else
		max=$nv2
	fi
	
	if [[ $max -gt 0 ]]
	then
	
		for iH in $(seq 0 $(( $max - 1 )) )
		do
			if [[ ${v1_arr[$iH]} -gt ${v2_arr[$iH]} ]]
			then
				echo -1
				return $CXR_RET_OK
			elif [[ ${v2_arr[$iH]} -gt ${v1_arr[$iH]} ]]
			then
				echo 1
				return $CXR_RET_OK
			fi # Decision reached?
		done # Loop though hierarchy
		
		# Arriving here can mean two things: the versions are the same,
		# or one array is longer than the other (the longer is the higher in this case)
		
		if [[ $nv1 -eq $nv2 ]]
		then
			echo 0
			return $CXR_RET_OK
		elif [[ $nv1 -gt $nv2 ]]
		then
			echo -1
			return $CXR_RET_OK
		else
			echo 1
			return $CXR_RET_OK
		fi
	
	else
		main.log -e "One of the version strings $v1 or $v2 is empty"
		echo 0
	fi
	
}

################################################################################
# Function: common.math.case
#
# Implements a case statement. You must provide a scalar value and two lists:
# the list of labels that is searched for the scalar (the labels)  and a list of values 
# returned for the label at the same index. The label "else" has  special meaning, it 
# is returned when no label matches.
# if no match is found and no else case is given, the empty string is returned.
# 
# This is useful to implement rules that have
# a structure that depends on a variable. It is smarter to use this function than 
# a bash if-statement because for a bash if-statement the variable in question must be 
# known at the time when the if-statement is evaluated (which is when the config file
# is read).
#
# Parameters:
# $1 - a value to define the current case
# $2 - a list of values that label all cases (the word else is reserved). Items my not contain spaces!
# $3 - a list of values to return for the respective cases. Items my not contain spaces!
################################################################################
function common.math.case()
################################################################################
{
	local current_case
	local labels
	local values
	local elsecase
	
	local iElement
	local current_label
	
	elsecase=

	current_case="$1"
	labels=($2)
	values=($3)
	
	for iElement in $(seq -f"%.0f" 0 $(( ${#labels[@]} - 1 )))
	do
		current_label="${labels[$iElement]}"
		
		if [[ $current_label == 'else' ]]
		then
			elsecase=${values[$iElement]}
		elif [[ $current_label == $current_case ]]
		then
			echo ${values[$iElement]}
			return $CXR_RET_OK
		fi
	done
	
	# If we arrived here, there was no math, return elsecase
	echo $elsecase
	return $CXR_RET_OK
}

################################################################################
# Function: common.math.if_then_else
#
# Implements the ternary operator. This is useful to implement rules that have
# a structure that depends on a variable. It is smarter to use this function than 
# a bash if-statement because for a bash if-statement the variable in question must be 
# known at the time when the if-statement is evaluated (which is when the config file
# is read)
#
# Parameters:
# $1 - an boolean expression yielding either true or false
# $2 - the value to return if true
# $3 - the value to return otherwise
################################################################################
function common.math.if_then_else()
################################################################################
{
	local ifvar
	local thenvar
	local elsevar
	
	ifvar=$1
	thenvar=$2
	elsevar=$3
	
	if [[ $ifvar == true ]]
	then
		echo $thenvar
	else
		echo $elsevar
	fi
}

################################################################################
# Function: common.math.convertBoolean
#
# Converts an internal true/false boolean to another system (default: 1/0).
# Needed because some programs such as IDL need integer truth values.
# Returns the input on error.
#
# Parameters:
# $1 - a logical literal (true or false)
# $2 - new true value (default: 1)
# $3 - new false value (default: 0)
################################################################################
function common.math.convertBoolean()
################################################################################
{
	local input
	local true_val
	local false_val
	
	input="${1}"
	true_val="${2:-1}"
	false_val="${3:-0}"
	
	if [[ $input == true ]]
	then
		echo $true_val
	elif [[ $input == false ]]
	then
		echo $false_val
	else
		echo "$input"
		main.log -e "Did not get a logical as input: $*"
	fi
}



################################################################################
# Function: common.math.not
#
# Provides the logical NOT function or our true/false logical literals.
# If the input is no logical literal, an error is raised and the value is returned.
#
# Parameters:
# $1 - a logical literal (true or false)
################################################################################
function common.math.not()
################################################################################
{
	local input
	
	input="${1}"
	
	if [[ $input == true ]]
	then
		echo false
	elif [[ $input == false ]]
	then
		echo true
	else
		echo "$input"
		main.log -e "Did not get a logical as input: $*"
	fi
}


################################################################################
# Function: common.math.roundToInteger
#
# Uses printf to round the input to the nearest integer.
#
# Parameters:
# $1 - a FP number
################################################################################
function common.math.roundToInteger()
################################################################################
{
	if [[ $# -ne 1 ]]
	then
		main.dieGracefully  "needs a floting point number as input"
	fi
	
	printf %0.f ${1}
}

################################################################################
# Function: common.math.FloatOperation
#
# Performs FP arithmetic - unlike $(()). Implemented with bc.
# 
# You can also use this function to do FP-safe comparisons:
# > result=$(common.math.FloatOperation "$a > $b" 0)
# >if [[ $result -eq 1 ]]
# >then
#	>	# a is greater
# >else
#	>	# a is not greater
# >fi
#
# Parameters:
# $1 - an expression
# $2 - an optional scale parameter (default CXR_NUM_DIGITS). -1 Means truncate, 0 means round to next integer
################################################################################
function common.math.FloatOperation()
################################################################################
{
	if [[ $# -lt 1 ]]
	then
		main.dieGracefully  "needs at least an expression as input"
	fi
	
	# Define & Initialize local vars
	local resolution
	local result
	local bc_res
	
	resolution=${2:-$CXR_NUM_DIGITS}
	
	# Fix resolution 
	# We treat -1 and 0 ourselves
	if [[ "$resolution" -le 0 ]]
	then
		bc_res=${CXR_NUM_DIGITS}
	else
		bc_res=$resolution
	fi
	
	# error handling is not easy here.
	# we cannot test $? nor PIPESTATUS in the subshell...
	# If you really need to debug, write stderr into a tempfile and test for size
	# As a workaround, we test if we get a number back
	
	# Set resolution & pass expression
	# Make sure the leading 0 is printed
	# http://stackoverflow.com/questions/8402181/how-do-i-get-bc1-to-print-the-leading-zero
	result=$( echo "scale=$bc_res; $1" | bc | sed 's/^\./0./' )
	
	if [[ ! "$result" =~ $CXR_PATTERN_NUMERIC ]]
	then
		main.dieGracefully "common.math.FloatOperation: the operation scale=$bc_res; $1 could not be performed (result: $result) !"
	fi
	
	if [[ "$resolution" -eq -1 ]]
	then
		# Chop off the decimals and dot (might result in the empty string!)
		result=${result%%\.*}
		
		if [[ -z "$result" ]]
		then
			result=0
		fi
	elif [[ "$resolution" -eq 0 ]]
	then
		# Round
		result="$(common.math.roundToInteger $result)"
	fi
	
	echo $result
}

################################################################################
# Function: common.math.FortranFloatOperation
#
# Performs FP arithmetic - unlike $(()). Implemented with bc.
# If the result is a whole number, a dot is appended at the end (FORTRAN compatibility)
#
# Parameters:
# $1 - an expression
# $2 - an optional scale parameter (default CXR_NUM_DIGITS). -1 Means truncate, 0 means round to next integer
################################################################################
function common.math.FortranFloatOperation()
################################################################################
{
	if [[ $# -lt 1 ]]
	then
		main.dieGracefully  "needs at least an expression as input"
	fi
	
	# Define & Initialize local vars
	local result
	
	result="$(common.math.FloatOperation "$1" "${2:-$CXR_NUM_DIGITS}")"
	
	# The scale function counts digits after the decimal point
	if [[ "$( echo "scale(${result})" | bc )" -eq 0 ]]
	then
		# Integer,  and we need to add a trailing .
		echo ${result}.
	else
		echo ${result}
	fi
}

################################################################################
# Function: common.math.RandomNumber
#
# Returns a random number between $1 and $2 formatted using $3 as scale.
# Due to the use of $RANDOM, these numbers are only pseudorandom at best.
#
# Parameters:
# [$1] - minimum (default 0)
# [$1] - maximum (default 1)
# $2 - an optional scale parameter (default CXR_NUM_DIGITS). -1 Means truncate, 0 means round to next integer
################################################################################
function common.math.RandomNumber()
################################################################################
{
	local maxrnd
	local result
	local scale
	local min
	local max
	
	min=${1:-0}
	max=${2:-1}
	scale=${3:-$CXR_NUM_DIGITS}
	
	# According to docs, that's the maximum $RANDOM returns
	maxrnd=32767
	
	result=$(common.math.FloatOperation "$min + (($RANDOM / $maxrnd) * ($max - $min))" $scale)
	
	echo $result
}

################################################################################
# Function: common.math.abs
#
# Calculates the absolute value of a number
#
# Parameters:
# $1 - number to be treated
################################################################################
function common.math.abs()
################################################################################
{
	if [[  $# -ne 1 || ! "$1" =~ $CXR_PATTERN_NUMERIC ]]
	then
		main.log -e  "needs a number as input, got $*"
		echo false
		return $CXR_RET_ERROR
	fi
	
	# Is the number 0?
	if [[ "$(common.math.FloatOperation "$1 == 0" -1)" == 1 ]]
	then
		echo 0
	# Is the number negative?
	elif [[ "$(common.math.FloatOperation "$1 < 0" 0)" == 1 ]]
	then
		echo "$(common.math.FloatOperation "0 - $1")"
	else
		echo $1
	fi
	
	return $CXR_RET_OK
}


################################################################################
# Function: common.math.sumVector
#
# Calculates the sum of a list of values passed as a string-delimited list (FP)
# Can be replaced by SQL:
# SELECT sum(column) FROM table; 
#
# Parameters:
# $1 - a list of numeric values (string-delimited)
# $2 - an optional scale parameter (default -1)
################################################################################
function common.math.sumVector()
################################################################################
{
	if [[ $# -lt 1 || -z "$1" ]]
	then
		main.log -e  "needs a list of numeric values as input"
		echo 0
		return $CXR_RET_ERROR
	fi
	
	local list
	local scale
	local iElement
	local result
	
	list="${1}"
	scale="${2:--1}"
	result=0
	
	arr=( $list )
	
	# We might get many elements - seq by default does Engineering notation
	for iElement in $(seq -f"%.0f" 0 $(( ${#arr[@]} - 1 )))
	do
		result="$(common.math.FloatOperation "$result + ${arr[$iElement]}" "$scale")"
	done
	
	echo $result

}

################################################################################
# Function: common.math.meanVector
#
# Calculates the arithmetic mean of a list of values passed as a string-delimited list
# By default we return an integer value (calculation is carried out FP).
# Can be replaced by SQL:
# SELECT avg(column) FROM table; 
#
# Parameters:
# $1 - a list of numeric values (string-delimited)
# $2 - an optional scale parameter (default -1)
################################################################################
function common.math.meanVector()
################################################################################
{
	if [[ $# -lt 1 || -z "$1" ]]
	then
		main.log -e  "needs a list of numeric values as input"
		echo 0
		return $CXR_RET_ERROR
	fi
	
	local list
	local scale
	
	list="${1}"
	scale="${2:--1}"
	
	nValues=$(main.countDelimitedElements "$list" " ")
	
	# Just to be on the safe side
	if [[ $nValues -lt 1 ]]
	then
		main.log -e  "needs a list of numeric values as input"
		echo 0
		return $CXR_RET_ERROR
	fi
	
	sum=$(common.math.sumVector "$list" "$scale")
	
	result=$(common.math.FloatOperation "$sum / $nValues" "$scale")
	
	echo $result
}

################################################################################
# Function: common.math.stdevVector
#
# Calculates the standard deviation of a list of values passed as a string-delimited list.
# Can be replaced by SQL:
# SELECT load_extension('./libsqlitefunctions.so');
# SELECT stdev(column) FROM table; 
#
# Parameters:
# $1 - a list of numeric values (string-delimited)
# [$2] - the mean value (if not given, will be calculated)
################################################################################
function common.math.stdevVector()
################################################################################
{
	if [[ $# -lt 1 || -z "$1" ]]
	then
		main.log -e  "needs a list of numeric values as input"
		echo 0
		return $CXR_RET_ERROR
	fi
	
	local list
	local mean
	local SumSquaredDeviation
	local nValues
	
	list="${1}"
	mean="${2:-}"
	SumSquaredDeviation=0
	nValues=$(main.countDelimitedElements "$list" " ")
	
	# Just to be on the safe side
	if [[ $nValues -lt 1 ]]
	then
		main.log -e  "needs a list of numeric values as input"
		echo 0
		return $CXR_RET_ERROR
	fi
	
	# Get mean if needed
	if [[ -z "$mean" ]]
	then
		main.log -v "Mean not given - we calculate it..."
		mean=$(common.math.meanVector "$list")
	fi
	
	arr=( $list )
	
	# We might get many elements - seq by default does Engineering notation
	for iElement in $(seq -f"%.0f" 0 $(( ${#arr[@]} - 1 )))
	do
		SumSquaredDeviation="$(common.math.FloatOperation "$SumSquaredDeviation + ( ${arr[$iElement]} - $mean )^2")"
	done

	result="$(common.math.FloatOperation "sqrt($SumSquaredDeviation / $nValues)")"
	
	echo $result
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
	
	is "$(common.math.compareVersions "4.51" "4.51")" 0 "common.math.compareVersions: both 4.51"
	is "$(common.math.compareVersions "1.2.3.4.5" "1.2.3.4.5")" 0 "common.math.compareVersions: both 1.2.3.4.5"
	is "$(common.math.compareVersions "5.1.20" "5.0")" -1 "common.math.compareVersions: 5.1.20 > 5.0"
	is "$(common.math.compareVersions "4.42" "5.3")" 1 "common.math.compareVersions: 5.3 > 4.42"
	is "$(common.math.compareVersions "5.0.0.20" "5.0.0.20.1")" 1 "common.math.compareVersions: 5.0.0.20.1 > 5.0.0.20"
	
	is "$(common.math.abs 0)" 0 "common.math.abs of 0"
	is "$(common.math.abs -0)" 0 "common.math.abs of -0"
	is "$(common.math.abs 1)" 1 "common.math.abs of 1"
	is "$(common.math.abs -1)" 1 "common.math.abs of -1"
	is "$(common.math.abs -1000000)" 1000000 "common.math.abs of -1000000"
	is "$(common.math.abs -3.14159)" 3.14159 "common.math.abs of -3.14159"
	is "$(common.math.abs 3.14159)" 3.14159 "common.math.abs of 3.14159"
	
	is "$(common.math.FortranFloatOperation "-1000000 * -1")"  1000000. "common.math.FortranFloatOperation -1000000 * -1"
	is "$(common.math.FloatOperation "12.43 * 2" )" 24.86 "common.math.FloatOperation 12.43 * 2"
	is "$(common.math.FortranFloatOperation "5" )"  5. "common.math.FortranFloatOperation 5"
	is "$(common.math.FloatOperation "5")"  5 "common.math.FloatOperation 5)"
	is "$(common.math.FloatOperation "0.0000224784 * 300000" -1)" 6 "common.math.FloatOperation Truncation"
	is "$(common.math.FloatOperation ".01 + 0.2" -1)" 0 "common.math.FloatOperation Truncation to 0"
	is "$(common.math.FortranFloatOperation ".01 + 0.2" -1)" "0." "common.math.FortranFloatOperation Truncation to 0 with dp"

	is "$(common.math.sumVector "1 -1 1")" 1 "common.math.sumVector - alternating signs"
	is "$(common.math.sumVector "10.4" 1)" 10.4 "common.math.sumVector - single fp"
	is "$(common.math.sumVector "0.1 1.1 3.14159" 5)" 4.34159 "common.math.sumVector - many FP"
	
	is "$(common.math.stdevVector "1 1 1 1 1")" 0 "common.math.stdevVector - all equal"
	is "$(common.math.stdevVector "1 2 3 4 5")" 1.4142 "common.math.stdevVector - 1 through 5"
	is "$(common.math.stdevVector "1 2 3 4 5" "3" )" 1.4142 "common.math.stdevVector - 1 through 5, passing mean"
	
	is "$(common.math.meanVector "1 1 1")" 1 "common.math.meanVector - all 1"
	is "$(common.math.meanVector "0 0 0")" 0 "common.math.meanVector - all 0"
	is "$(common.math.meanVector "1000")" 1000 "common.math.meanVector - single 1000"
	
	is "$(common.math.if_then_else true Yes No)" Yes "common.math.if_then_else true"
	is "$(common.math.if_then_else false Yes No)" No "common.math.if_then_else false"
	
	is "$(common.math.case one "one two three" "1 2 3")" 1 "common.math.case existing case"
	is "$(common.math.case four "one two three" "1 2 3")" "" "common.math.case non-existing case, no default"
	is "$(common.math.case four "one two three else" "1 2 3 number")" number "common.math.case non-existing case, default"
	
	########################################
	# teardown tests if needed
	########################################
	
}
