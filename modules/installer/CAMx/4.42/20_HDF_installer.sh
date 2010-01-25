#!/usr/bin/env bash
#
# Installer for HDF/zlib Libraries used for CAMx
#
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
#
# Written by Daniel C. Oderbolz (CAMxRunner@psi.ch).
# This software is provided as is without any warranty whatsoever. See doc/Disclaimer.txt for details. See doc/Disclaimer.txt for details.
# Released under the Creative Commons "Attribution-Share Alike 2.5 Switzerland"
# License, (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)
################################################################################
# TODO: The code here is pretty repetitive because bash has no nice
# hash construct (mostly needed for configure options etc.)
################################################################################
# Module Metadata. Leave "-" if no setting is wanted
################################################################################

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Creates a directory full of links for the postprocessors (mostly aqmfad)"

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}""
CXR_META_MODULE_TYPE=${CXR_TYPE_INSTALLER}

# If >0 this module supports testing via -t
CXR_META_MODULE_NUM_TESTS=0

# This is the run name that is used to test this module
CXR_META_MODULE_TEST_RUN=base

# Min CAMxRunner Version needed (Revision number)
CXR_META_MODULE_REQ_RUNNER_VERSION=94

# Min Revision number of configuration needed (to avoid that old runs try to execute new modules)
# The revision number is automatically extracted from the config file
CXR_META_MODULE_REQ_CONF_VERSION=94

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
	
	Start the installation using the -I Option.
	
	Written by $CXR_META_MODULE_AUTHOR
	License: $CXR_META_MODULE_LICENSE
	
	Find more info here:
	$CXR_META_MODULE_DOC_URL
EOF
exit 1
}

################################################################################
# Function: HDF_installer
#
# Downloads and compiles HDF for CAMx (together with zlib support)
#
function HDF_installer() 
################################################################################
{
	if [ "$(cxr_common_get_consent "Do you want to complile the zlib, HDF, netCDF and IOAPI libraries (needed for HDF and IOAPI support)?\nRequires about $CXR_LIB_MEGABYTES_REQUIRED MB of space." Y )" == true ]
	then
	
		########################################
		# Setup
		########################################
		export MYLIBDIR=$(cxr_common_evaluate_rule "$MYLIBDIR_RULE" false MYLIBDIR_RULE)

		########################################
		# Check space
		########################################
		
		cxr_common_check_mb_needed "$MYLIBDIR" "$CXR_LIB_MEGABYTES_REQUIRED"
		
		########################################
		# Determine platform.
		########################################
		
		# Determine default from Machine Type
		case "$MACHTYPE" in
		
			x86_64) DEFAULT=p7-64;;
			i386) DEFAULT=p6;;
		 *) DEFAULT=px;;
		
		esac
		
		CXR_CURRENT_PLATFORM=$(cxr_common_get_menu_choice "What platform do we compile for?" "$CXR_FORTRAN_PLATFORMS" "$DEFAULT")
		

		########################################
		# Create the target directories
		########################################
		
		cxr_main_logger -a "${FUNCNAME}" "Starting installation - feel free to grab a cup of coffee or tea..."
		sleep 2
		
		mkdir -p $MYLIBDIR/zlib || cxr_main_die_gracefully "could not create $MYLIBDIR/zlib"
		mkdir -p $MYLIBDIR/hdf || cxr_main_die_gracefully "could not create to $MYLIBDIR/hdf"
		
		mkdir -p $MYLIBDIR/netcdf || cxr_main_die_gracefully "could not create $MYLIBDIR/netcdf"
		mkdir -p $MYLIBDIR/ioapi || cxr_main_die_gracefully "could not create $MYLIBDIR/ioapi"
		
		
		########################################
		# Zlib
		########################################
		
		cxr_main_logger -a -b "${FUNCNAME}" "zlib"
	
		# Go to location
		cd $MYLIBDIR/zlib || cxr_main_die_gracefully "could not change to $MYLIBDIR/zlib"
	
		# Download
		${CXR_WGET_EXEC} ${CXR_ZLIB_TAR_LOC} -O ${CXR_ZLIB_TAR} || cxr_main_die_gracefully "could not download ${CXR_ZLIB_TAR_LOC}"
		
		# Untar 
		tar xvzf ${CXR_ZLIB_TAR}
		
		# Go to directory
		cd ${CXR_ZLIB_TAR_DIR} || cxr_main_die_gracefully "could not change to $CXR_ZLIB_TAR_DIR"
		
		# Configure
		./configure --shared --prefix=$MYLIBDIR/zlib || cxr_main_die_gracefully "Configure for zlib failed"
		
		# Compile
		make clean
		make && make install || cxr_main_die_gracefully "make for zlib failed"
		
		# Clean up
		cd $MYLIBDIR/zlib || cxr_main_die_gracefully "Could not move up"
		rm ${CXR_ZLIB_TAR}

		
		########################################
		# HDF
		########################################	

		cxr_main_logger -a -b "${FUNCNAME}" "HDF5"
	
		# Go to location
		cd $MYLIBDIR/hdf || cxr_main_die_gracefully "could not change to $MYLIBDIR/hdf"
	
		# Download
		${CXR_WGET_EXEC} ${CXR_HDF_TAR_LOC} -O ${CXR_HDF_TAR} || cxr_main_die_gracefully "could not download ${CXR_HDF_TAR_LOC}"
		
		# Untar 
		tar xvzf ${CXR_HDF_TAR}
		
		# Go to directory
		cd ${CXR_HDF_TAR_DIR} || cxr_main_die_gracefully "could not change to $CXR_HDF_TAR_DIR"
		
		# Configure
		./configure --with-zlib=$MYLIBDIR/zlib --prefix=$MYLIBDIR/hdf || cxr_main_die_gracefully "Configure for hdf failed"
		
		# Compile
		make clean
		make && make install || cxr_main_die_gracefully "make for hdf failed"
		
		# Clean up
		cd $MYLIBDIR/hdf || cxr_main_die_gracefully "Could not move up"
		rm ${CXR_HDF_TAR}
	
				
		########################################
		# netcdf
		########################################
		
		cxr_main_logger -a -b "${FUNCNAME}" "NetCDF"
		
		# Go to location
		cd $MYLIBDIR/netcdf || cxr_main_die_gracefully "could not change to $MYLIBDIR/netcdf"
		
		# Download
		${CXR_WGET_EXEC} ${CXR_NETCDF_TAR_LOC} -O ${CXR_NETCDF_TAR} || cxr_main_die_gracefully "could not download ${CXR_NETCDF_TAR_LOC}"

		# Untar 
		tar xvzf ${CXR_NETCDF_TAR}
		
		# Go to directory
		cd ${CXR_NETCDF_TAR_DIR} || cxr_main_die_gracefully "could not change to $CXR_NETCDF_TAR_DIR"
		
		./configure --enable-netcdf-4 --with-hdf5=$MYLIBDIR/hdf  --with-zlib=$MYLIBDIR/zlib --prefix=$MYLIBDIR/netcdf

		# Compile
		make clean
		make  && make install && make check || cxr_main_die_gracefully "make for netcdf failed"
		
		# Clean up
		cd $MYLIBDIR/netcdf || cxr_main_die_gracefully "Could not move up"
		rm ${CXR_NETCDF_TAR}
			
		########################################
		# IOAPI
		########################################
		
		cxr_main_logger -a -b "${FUNCNAME}" "IOAPI"
		
		# Set needed variable
		BIN=$(uname -s)$(uname -r | cut -d. -f1)_x86pg
		
		# Go to location
		cd $MYLIBDIR/ioapi || cxr_main_die_gracefully "could not change to $MYLIBDIR/ioapi"
		
		# Download
		${CXR_WGET_EXEC} ${CXR_IOAPI_TAR_LOC} -O ${CXR_IOAPI_TAR} || cxr_main_die_gracefully "could not download ${CXR_IOAPI_TAR_LOC}"

		# Untar 
		tar xvzf ${CXR_IOAPI_TAR}
		
		# Go to directory
		cd ${CXR_IOAPI_TAR_DIR} || cxr_main_die_gracefully "could not change to $CXR_IOAPI_TAR_DIR"
		
		# Disable PVM
		cp Makefile.nocpl Makefile
		
		
		########################################
		cxr_main_logger  -a "${FUNCNAME}" "Setup Input directories containing patches..."
		########################################
		
		# We compile CAMx
		CXR_CURRENT_BINARY=ioapi
		
		# These directories might not exist!
		PATCH_ALL_DIR=$(cxr_common_evaluate_rule "$CXR_PATCH_ALL_DIR_RULE" false CXR_PATCH_ALL_DIR_RULE) 
		PATCH_PLATFORM_DIR=$(cxr_common_evaluate_rule "$CXR_PATCH_PLATFORM_DIR_RULE" false CXR_PATCH_PLATFORM_DIR_RULE)
		
		########################################
		cxr_main_logger -a "${FUNCNAME}" "Applying patches..."
		########################################
		
		if [ -d "$PATCH_ALL_DIR" ]
		then
			cxr_common_apply_patches "$PATCH_ALL_DIR" "$MYLIBDIR/ioapi/${CXR_IOAPI_TAR_DIR}"
		fi
		
		if [ -d "$PATCH_PLATFORM_DIR" ]
		then
			cxr_common_apply_patches "$PATCH_PLATFORM_DIR" "$MYLIBDIR/ioapi/${CXR_IOAPI_TAR_DIR}"
		fi
		
		cd ${CXR_IOAPI_TAR_DIR} || cxr_main_die_gracefully "could not change to $CXR_IOAPI_TAR_DIR"
		
		make clean && make all && make install || cxr_main_die_gracefully "make for ioapi failed"
		
		# Clean up
		cd $MYLIBDIR/ioapi || cxr_main_die_gracefully "Could not move up"
		rm ${CXR_IOAPI_TAR}
		
		# Those directories are no longer needed
		if [ "$(cxr_common_get_consent "Do you want to remove the directories ${CXR_HDF_TAR_DIR}, ${CXR_ZLIB_TAR_DIR}, ${CXR_NETCDF_TAR_DIR} and ${CXR_IOAPI_TAR_DIR} (they are not needed anymore)?" )" == true ]
		then
			rm -r ${MYLIBDIR}/hdf/${CXR_HDF_TAR_DIR}
			rm -r ${MYLIBDIR}/zlib/${CXR_ZLIB_TAR_DIR}
			rm -r ${MYLIBDIR}/netcdf/${CXR_NETCDF_TAR_DIR}
			rm -r ${MYLIBDIR}/ioapi/${CXR_IOAPI_TAR_DIR}
		fi
		
		# Change to run dir
		cd "$CXR_RUN_DIR" || cxr_main_die_gracefully "Could not change to $CXR_RUN_DIR"
		
		cxr_main_logger -a "${FUNCNAME}" "Done. Libraries should now be ready for the compilation of CAMx."
		
	fi
	
}


################################################################################
# Are we running stand-alone? - Can only show help
################################################################################

# If the CXR_META_MODULE_NAME  is not set,
# somebody started this script alone
if [ -z "${CXR_META_MODULE_NAME:-}"  ]
then
	usage
fi

################################################################################
# Code beyond this point is not executed in stand-alone operation
################################################################################




