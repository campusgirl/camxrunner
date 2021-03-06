# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Common script for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Title: functions for coordinate transformations etc. (Provided by Proj.4 <http://proj.osgeo.org/>)
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
CXR_META_MODULE_REQ_SPECIAL="exec|cs2cs"

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Contains some coordinate transformation functions for the CAMxRunner"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2010), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'


################################################################################
# Function: common.map.indexesToModelCoordinates
#
# Converts given domain 1-based indexes (in the given domain) to the models coordinate system.
# The user must be aware of the unit of the result (given in the configuration)
#
# The calculation is done using simple addition since all cells have the same dx and dy.
# Note that indexes for inner domains always include buffer cells.
# Given integer indexes, the lower left corner of the cell in question is returned,
# Meaning that the center point is found by adding 0.5 in each direction and the upper right
# corner is found by adding 1 in each direction.
# Inner domains are resolved using one additional recursive call to this function.
# 
# Output is given as a space delimited list of the form "x y"
#
# Parameters:
# $1 - x-index (1-based), may be fractionals
# $2 - y-index (1-based), may be fractionals
# $3 - domain-index (1-based), integer
################################################################################
function common.map.indexesToModelCoordinates()
################################################################################
{
	if [[ $# -ne 3 ]]
	then
		main.dieGracefully "Needs x and y index plus domain number as input. Got $*"
	fi
	
	local x_in
	local y_in
	local domain
	
	local x_out
	local y_out
	local resolution_x
	local resolution_y
	
	local first_cell
	local first_cell_x
	local first_cell_y
	
	x_in="$1"
	y_in="$2"
	domain="$3"
	
	if [[ $domain -eq 1 ]]
	then
		resolution_x=$CXR_MASTER_CELL_XSIZE
		resolution_y=$CXR_MASTER_CELL_YSIZE
		
		first_cell_x=$CXR_MASTER_ORIGIN_XCOORD
		first_cell_y=$CXR_MASTER_ORIGIN_YCOORD
	elif [[ $domain -gt 1 && $domain -le $CXR_NUMBER_OF_GRIDS ]]
	then
		# calculate resolution of target grid
		resolution_x=$(common.math.FloatOperation "$CXR_MASTER_CELL_XSIZE / ${CXR_NEST_MESHING_FACTOR[$domain]}")
		resolution_y=$(common.math.FloatOperation "$CXR_MASTER_CELL_YSIZE / ${CXR_NEST_MESHING_FACTOR[$domain]}")
		
		# Offsets such as CXR_NEST_BEG_I_INDEX ar relative to master grid
		# recursive call for the cell (1,1) of the inner domain
		first_cell=$(common.map.indexesToModelCoordinates ${CXR_NEST_BEG_I_INDEX[$domain]} ${CXR_NEST_BEG_J_INDEX[$domain]} 1)

		# Parse result
		first_cell_x=$(echo "$first_cell" | awk '{ print $1 }')
		first_cell_y=$(echo "$first_cell" | awk '{ print $2 }')
	else
		main.dieGracefully "Domain number $domain is outside the range 1..$CXR_NUMBER_OF_GRIDS"
	fi
	
	# Calculate
	x_out=$(common.math.FloatOperation "$first_cell_x + (( $x_in - 1 ) * $resolution_x)")
	y_out=$(common.math.FloatOperation "$first_cell_y + (( $y_in - 1 ) * $resolution_y)")
	
	echo "${x_out} ${y_out}"
}

################################################################################
# Function: common.map.indexesToLonLat
#
# Converts given 1-based domain indexes (in the given domain) to decimal Lon/Lat.
# Given integer indexes, the lower left corner of the cell in question is returned
# Refer to <common.map.indexesToModelCoordinates> for further details.
# 
# Output is given as a space delimited list of the form "Lon Lat"
#
# Parameters:
# $1 - x-index (1-based), may be fractionals
# $2 - y-index (1-based), may be fractionals
# $3 - domain-index (1-based), integer
################################################################################
function common.map.indexesToLonLat()
################################################################################
{
	if [[ $# -ne 3 ]]
	then
		main.dieGracefully "Needs x and y index plus domain number as input. Got $*"
	fi

	local x_in
	local y_in
	local domain
	
	local converted_model
	local converted_lonlat
	
	local x_out
	local y_out
	
	x_in="$1"
	y_in="$2"
	domain="$3"
	
	# Convert to Model-Coord
	converted_model=$(common.map.indexesToModelCoordinates $x_in $y_in $domain)
	
	# Convert to decimal Lon/Lat
	common.map.ProjectionToLonLat $converted_model
}

################################################################################
# Function: common.map.LonLatToIndexes
#
# Converts Lon/Lat coordinates to 1-based fractional indexes of the given Model domain.
# Input coordinates must be given in any format supported by the cs2cs 
# program of Proj.4 <http://proj.osgeo.org/>.
#
# If indexes are beyond the dimensions of this domain, "-1 -1" is returned.
#
# Supports the same cooordinate systems as CAMx.
# Output is given as a space delimited list of the form "x_ind y_ind"
#
# Parameters:
# $1 - Lon coordinate
# $2 - Lat coordinate
# $3 - domain-index (1-based), integer
# [$4] - precision (number of decimals, default: CXR_NUM_DIGITS). -1 Means truncate, 0 means round to next integer
################################################################################
function common.map.LonLatToIndexes()
################################################################################
{
	if [[ $# -lt 3 || $# -gt 4 ]]
	then
		main.dieGracefully "Needs x and y coordinates plus domain number as input. Got $*"
	fi
	
	local lon
	local lat
	local x_in
	local y_in
	local converted
	
	local x_out
	local y_out
	local resolution_x
	local resolution_y
	
	local first_cell
	local first_cell_x
	local first_cell_y
	local scale
	

	lon="$1"
	lat="$2"
	domain="$3"
	scale="${4:-$CXR_NUM_DIGITS}"
	
	# Convert coordinates to Model Coordinates
	converted="$(common.map.LonLatToProjection $lon $lat)"
	
	# Parse result
	x_in=$(echo "$converted" | awk '{ print $1 }')
	y_in=$(echo "$converted" | awk '{ print $2 }')

	
	if [[ $domain -eq 1 ]]
	then
		resolution_x=$CXR_MASTER_CELL_XSIZE
		resolution_y=$CXR_MASTER_CELL_YSIZE
		
		first_cell_x=$CXR_MASTER_ORIGIN_XCOORD
		first_cell_y=$CXR_MASTER_ORIGIN_YCOORD
	elif [[ $domain -gt 1 && $domain -le $CXR_NUMBER_OF_GRIDS ]]
	then
		# calculate resolution of target grid
		resolution_x=$(common.math.FloatOperation "$CXR_MASTER_CELL_XSIZE / ${CXR_NEST_MESHING_FACTOR[$domain]}")
		resolution_y=$(common.math.FloatOperation "$CXR_MASTER_CELL_YSIZE / ${CXR_NEST_MESHING_FACTOR[$domain]}")
		
		# Offsets such as CXR_NEST_BEG_I_INDEX ar relative to master grid
		# recursive call for the cell (1,1) of the inner domain
		first_cell=$(common.map.indexesToModelCoordinates ${CXR_NEST_BEG_I_INDEX[$domain]} ${CXR_NEST_BEG_J_INDEX[$domain]} 1)
	
		# Parse result
		first_cell_x=$(echo "$first_cell" | awk '{ print $1 }')
		first_cell_y=$(echo "$first_cell" | awk '{ print $2 }')
	else
		main.dieGracefully "Domain number $domain is outside the range 1..$CXR_NUMBER_OF_GRIDS"
	fi
	
	# Rounding (if needed) is done in this last step
	x_out=$(common.math.FloatOperation "(($x_in - $first_cell_x)/$resolution_x) + 1" "$scale")
	y_out=$(common.math.FloatOperation "(($y_in - $first_cell_y)/$resolution_y) + 1" "$scale")

	# Test dimensions
	if [[ $(common.math.FloatOperation "$x_out > $(common.runner.getX $domain)" 0) -eq 1 || \
	      $(common.math.FloatOperation "$y_out > $(common.runner.getY $domain)" 0) -eq 1 || \
	      $(common.math.FloatOperation "$x_out < 0" 0) -eq 1 || \
	      $(common.math.FloatOperation "$y_out < 0" 0) -eq 1 ]]
	then
		main.log -v "cell indexes $x_out/$y_out exceed dimensions of domain $domain."
		echo "-1 -1"
	else
		echo "${x_out} ${y_out}"
	fi # output checks
}

################################################################################
# Function: common.map.LonLatToProjection
#
# Converts Lon/Lat to projected coordinates and back (with switch)
# Input coordinates must be given in any format supported by the cs2cs 
# program of Proj.4 <http://proj.osgeo.org/>.
# Note that we use a spherical earth (R=$CXR_MAP_EARTH_RADIUS_METRE) as datum 
# because that is what the underlying meteo models (MM5/WRF) use. 
# Check if the results are correct for your case!
# We detected offsets of the order of kms when comparing to WGS84 datum!
#
# Supports the same cooordinate systems as CAMx plus Swiss coordinates.
#
# Attention: When using UTM in the southern hemisphere, an additional +south might be needed.
# Output is given as a space delimited list of the form "x y".
#
#
# Parameters:
# $1 -Lon or x coordinate
# $2 - Lat or y coordinate
# [$3] - name of projection in uppercase, if not given, $CXR_MAP_PROJECTION is used
# [$4] - boolean inverse if true (default false), we convert from Model to Lon Lat
################################################################################
function common.map.LonLatToProjection()
################################################################################
{
	if [[ $# -lt 2 || $# -gt 4 ]]
	then
		main.dieGracefully "Needs x and y coordinates, an optional projection name and an optional boolean as input. Got $*"
	fi
	
	local lon
	local lat
	local proj_string
	local result
	local inverse
	local projection
	
	lon="$1"
	lat="$2"
	projection="$(common.string.toUpper "${3:-$CXR_MAP_PROJECTION}")"
	inverse="${4:-false}"
	inv_string=""
	
	if [[ $inverse == true ]]
	then
		inv_string="-I"
	fi
	
	case $projection in
		$CXR_MAP_PROJECTION_LAMBERT) proj_string="+proj=lcc +R=$CXR_MAP_EARTH_RADIUS_METRE +units=km +lon_0=$CXR_LAMBERT_CENTER_LONGITUDE +lat_0=$CXR_LAMBERT_CENTER_LATITUDE +lat_1=$CXR_LAMBERT_TRUE_LATITUDE1 +lat_2=$CXR_LAMBERT_TRUE_LATITUDE2 +no_defs";;
		$CXR_MAP_PROJECTION_POLAR) proj_string="+proj=stere +R=$CXR_MAP_EARTH_RADIUS_METRE +units=km +lon_0=$CXR_POLAR_LONGITUDE_POLE +lat_0=$CXR_POLAR_LATITUDE_POLE +no_defs";;
		$CXR_MAP_PROJECTION_UTM) proj_string="+proj=utm +R=$CXR_MAP_EARTH_RADIUS_METRE +units=km +zone=$CXR_UTM_ZONE +no_defs";;
		$CXR_MAP_PROJECTION_SWISS) proj_string="+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +x_0=600000 +y_0=200000 +ellps=bessel +units=m +no_defs";;
		$CXR_MAP_PROJECTION_LATLON|LONLAT) 
			# No need to convert.
			echo "${lon} ${lat}"
			return $CXR_RET_OK
			;;
		*) main.dieGracefully "Projection $projection not supported" ;;
	esac
	
	# Call converter
	result="$(${CXR_CS2CS_EXEC} $inv_string -f "%.4f" +proj=lonlat +R=$CXR_MAP_EARTH_RADIUS_METRE +to $proj_string <<-EOT
	$lon $lat
	EOT)"
	
	# Parse and return it
	echo "$(echo "$result" | awk '{ print $1 }') $(echo "$result" | awk '{ print $2 }')"
}

################################################################################
# Function: common.map.ProjectionToLonLat
#
# Converts model coordinates to decimal Lon/Lat. (Wrapper for <common.map.LonLatToProjection>)
#
# Output is given as a space delimited list of the form "Lon Lat".
#
# Parameters:
# $1 - x-model coordinate
# $2 - y-model coordinate
# [$3] - name of projection in uppercase, if not given, $CXR_MAP_PROJECTION is used
################################################################################
function common.map.ProjectionToLonLat()
################################################################################
{
	common.map.LonLatToProjection $1 $2 ${3:-$CXR_MAP_PROJECTION} true
}

################################################################################
# Function: common.map.ProjectionToModelCoordinates
#
# Converts projected coordinates to model coordinates. (Wrapper for <common.map.ProjectionToLonLat> and <common.map.LonLatToProjection>)
#
# Output is given as a space delimited list of the form "x y".
#
# Parameters:
# $1 - x-projected coordinate
# $2 - y-projected coordinate
# [$3] - name of input projection in uppercase
################################################################################
function common.map.ProjectionToModelCoordinates()
################################################################################
{
	local lonlat_xy
	
	lonlat_xy=$(common.map.ProjectionToLonLat $1 $2 $3)
	
	# Now do the conversion to model coordinates
	common.map.LonLatToProjection $lonlat_xy
}


################################################################################
# Function: common.map.ProjectionToIndexes
#
# Converts model coordinates to decimal indexes. (Wrapper for <common.map.ProjectionToLonLat>
# and <common.map.LonLatToIndexes>)
#
# Output is given as a space delimited list of the form "x y". (See <common.map.LonLatToIndexes>
# for details).
#
# Parameters:
# $1 - x-coordinate in projection
# $2 - x-coordinate in projection
# $3 - domain in which indexes are needed
# [$4] - name of projection in uppercase, if not given, $CXR_MAP_PROJECTION is used
# [$5] - precision (number of decimals, default: CXR_NUM_DIGITS). -1 Means truncate, 0 means round to next integer
################################################################################
function common.map.ProjectionToIndexes()
################################################################################
{
	local lonlat_xy

	# Lonlat is the "Lingua franca" here
	lonlat_xy=$(common.map.ProjectionToLonLat $1 $2 ${4:-$CXR_MAP_PROJECTION})
	
	# Now do the conversion to indexes
	common.map.LonLatToIndexes $lonlat_xy $3 ${5:-$CXR_NUM_DIGITS}
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

	# The first cell of the first domain must be at the origin
	is.numerical "$(common.map.indexesToModelCoordinates 1 1 1)" "${CXR_MASTER_ORIGIN_XCOORD} ${CXR_MASTER_ORIGIN_YCOORD}" "common.map.indexesToModelCoordinates origin"

	# Test inverse
	is.numerical "$(common.map.LonLatToProjection $(common.map.ProjectionToLonLat 0 0))" "0.0000 0.0000" "common.map.LonLatToProjection inverse testing"

	main.log -a "Rigi in LonLat: $(common.map.ProjectionToLonLat 679520.05 212273.44 SWISS)"
	main.log -a "Rigi in LV03: $(common.map.LonLatToProjection 8.5 47 SWISS)"
	
	# Get the index of Payerne
	main.log -a "Indexes of Payerne D1: $(common.map.LonLatToIndexes $(common.map.ProjectionToLonLat 562285 184775 SWISS) 1)"
	main.log -a "Indexes of Payerne D1 (direct): $(common.map.ProjectionToIndexes 562285 184775 1 SWISS)"
	main.log -a "LonLat Payerne: $(common.map.ProjectionToLonLat 562285 184775 SWISS)"

	# Same for Magadino
	main.log -a "Magadino in LonLat: $(common.map.ProjectionToLonLat 715500 113200 SWISS)"
	main.log -a "Indexes of Magadino D1 (direct): $(common.map.ProjectionToIndexes 715500 113200 1 SWISS)"

	# Same for Hohenpeissenberg
	main.log -a "Hohenpeissenberg in Swiss coordinates $(common.map.LonLatToProjection 11.0097 47.8013 SWISS)"

	########################################
	# teardown tests if needed
	########################################
	
}
