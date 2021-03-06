# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
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
# TODO: 
################################################################################
# Module Metadata. Leave "-" if no setting is wanted
################################################################################

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Creates a directory full of links for the postprocessors (mostly aqmfad)"

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}""
CXR_META_MODULE_TYPE=${CXR_TYPE_INSTALLER}

# If >0, this module supports testing
CXR_META_MODULE_NUM_TESTS=0

# This string describes special requirements this module has
# it is a space-separated list of requirement|value[|optional] tuples.
# If a requirement is not binding, optional is added at the end
CXR_META_MODULE_REQ_SPECIAL="exec|wget"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2010), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'

################################################################################
# Function: HDF_installer
#
# Downloads and compiles HDF for CAMx (together with zlib support)
#
function HDF_installer() 
################################################################################
{
	if [[ "$(common.user.getOK "Do you want to complile the zlib, HDF, netCDF and IOAPI libraries (needed for HDF and IOAPI support)?\nRequires about $CXR_LIB_MEGABYTES_REQUIRED MB of space." Y )" == true  ]]
	then
	
		local patch_all_dir
		local patch_platform_dir
		local currdir
		
		########################################
		# Setup
		########################################
		export MYLIBDIR=$(common.runner.evaluateRule "$MYLIBDIR_RULE" false MYLIBDIR_RULE)

		########################################
		# Check space
		########################################
		
		common.check.MbNeeded "$MYLIBDIR" "$CXR_LIB_MEGABYTES_REQUIRED"
		

		########################################
		# Create the target directories
		########################################
		
		main.log -a  "Starting installation - feel free to grab a cup of coffee or tea..."
		sleep 2
		
		mkdir -p $MYLIBDIR/zlib || main.dieGracefully "could not create $MYLIBDIR/zlib"
		mkdir -p $MYLIBDIR/hdf || main.dieGracefully "could not create to $MYLIBDIR/hdf"
		
		mkdir -p $MYLIBDIR/netcdf || main.dieGracefully "could not create $MYLIBDIR/netcdf"
		mkdir -p $MYLIBDIR/ioapi || main.dieGracefully "could not create $MYLIBDIR/ioapi"
		
		########################################
		# Zlib
		########################################
		
		main.log -a -b  "zlib"
	
		# Go to location
		cd $MYLIBDIR/zlib || main.dieGracefully "could not change to $MYLIBDIR/zlib"
	
		# Download
		common.install.downloadFile ${CXR_ZLIB_TAR_LOC} ${CXR_ZLIB_TAR} true
		
		# Untar 
		tar xvzf ${CXR_ZLIB_TAR}
		
		# Go to directory
		cd ${CXR_ZLIB_TAR_DIR} || main.dieGracefully "could not change to $CXR_ZLIB_TAR_DIR"
		
		# Configure
		./configure --shared --prefix=$MYLIBDIR/zlib || main.dieGracefully "Configure for zlib failed"
		
		# Compile
		make clean
		make && make install || main.dieGracefully "make for zlib failed"
		
		# Clean up
		cd $MYLIBDIR/zlib || main.dieGracefully "Could not move up"
		rm ${CXR_ZLIB_TAR}

		
		########################################
		# HDF
		########################################	

		main.log -a -b  "HDF5"
	
		# Go to location
		cd $MYLIBDIR/hdf || main.dieGracefully "could not change to $MYLIBDIR/hdf"
	
		# Download
		common.install.downloadFile ${CXR_HDF_TAR_LOC} ${CXR_HDF_TAR} true
		
		# Untar 
		tar xvzf ${CXR_HDF_TAR}
		
		# Go to directory
		cd ${CXR_HDF_TAR_DIR} || main.dieGracefully "could not change to $CXR_HDF_TAR_DIR"
		
		# Configure
		./configure --with-zlib=$MYLIBDIR/zlib --prefix=$MYLIBDIR/hdf || main.dieGracefully "Configure for hdf failed"
		
		# Compile
		make clean
		make && make install || main.dieGracefully "make for hdf failed"
		
		# Clean up
		cd $MYLIBDIR/hdf || main.dieGracefully "Could not move up"
		rm ${CXR_HDF_TAR}
	
				
		########################################
		# netcdf
		########################################
		
		main.log -a -b  "NetCDF"
		
		# Go to location
		cd $MYLIBDIR/netcdf || main.dieGracefully "could not change to $MYLIBDIR/netcdf"
		
		# Download
		common.install.downloadFile ${CXR_NETCDF_TAR_LOC} ${CXR_NETCDF_TAR} true

		# Untar 
		tar xvzf ${CXR_NETCDF_TAR}
		
		# Go to directory
		cd ${CXR_NETCDF_TAR_DIR} || main.dieGracefully "could not change to $CXR_NETCDF_TAR_DIR"
		
		./configure --enable-netcdf-4 --with-hdf5=$MYLIBDIR/hdf  --with-zlib=$MYLIBDIR/zlib --prefix=$MYLIBDIR/netcdf

		# Compile
		make clean
		make  && make install && make check || main.dieGracefully "make for netcdf failed"
		
		# Clean up
		cd $MYLIBDIR/netcdf || main.dieGracefully "Could not move up"
		rm ${CXR_NETCDF_TAR}
			
		########################################
		# IOAPI
		########################################
		main.log -a -b  "IOAPI"
		
		# export needed variable
		export BIN=$(uname -s)$(uname -r | cut -d. -f1)_x86pg
		
		# Go to location
		cd $MYLIBDIR/ioapi || main.dieGracefully "could not change to $MYLIBDIR/ioapi"
		
		# Download
		common.install.downloadFile ${CXR_IOAPI_TAR_LOC} ${CXR_IOAPI_TAR} true

		# Untar 
		tar xvzf ${CXR_IOAPI_TAR}
		
		# Go to directory
		cd ${CXR_IOAPI_TAR_DIR} || main.dieGracefully "could not change to $CXR_IOAPI_TAR_DIR"
		
		currdir="$(pwd)"
		
		# Disable PVM
		cp Makefile.nocpl Makefile
		
		
		########################################
		main.log  -a  "Setup Input directories containing patches..."
		########################################
		
		# We compile CAMx
		CXR_CURRENT_BINARY=ioapi
		
		# These directories might not exist!
		patch_all_dir=$(common.runner.evaluateRule "$CXR_PATCH_ALL_DIR_RULE" false CXR_PATCH_ALL_DIR_RULE) 
		patch_platform_dir=$(common.runner.evaluateRule "$CXR_PATCH_PLATFORM_DIR_RULE" false CXR_PATCH_PLATFORM_DIR_RULE)
		
		########################################
		main.log -a  "Applying patches..."
		########################################
		
		if [[ -d "$patch_all_dir"  ]]
		then
			common.install.applyPatch "$patch_all_dir" "$MYLIBDIR/ioapi/${CXR_IOAPI_TAR_DIR}"
		fi
		
		if [[ -d "$patch_platform_dir"  ]]
		then
			common.install.applyPatch "$patch_platform_dir" "$MYLIBDIR/ioapi/${CXR_IOAPI_TAR_DIR}"
		fi
		
		cd ${currdir} || main.dieGracefully "could not change to $currdir"
		
		make clean && make all && make install || main.dieGracefully "make for ioapi failed"
		
		# Clean up
		cd $MYLIBDIR/ioapi || main.dieGracefully "Could not move up"
		rm ${CXR_IOAPI_TAR}
		
		# Those directories are no longer needed
		if [[ "$(common.user.getOK "Do you want to remove the directories ${CXR_HDF_TAR_DIR}, ${CXR_ZLIB_TAR_DIR}, ${CXR_NETCDF_TAR_DIR} and ${CXR_IOAPI_TAR_DIR} (they are not needed anymore)?" )" == true  ]]
		then
			rm -r ${MYLIBDIR}/hdf/${CXR_HDF_TAR_DIR}
			rm -r ${MYLIBDIR}/zlib/${CXR_ZLIB_TAR_DIR}
			rm -r ${MYLIBDIR}/netcdf/${CXR_NETCDF_TAR_DIR}
			rm -r ${MYLIBDIR}/ioapi/${CXR_IOAPI_TAR_DIR}
		fi
		
		# Change to run dir
		cd "$CXR_RUN_DIR" || main.dieGracefully "Could not change to $CXR_RUN_DIR"
		
		main.log -a  "Done. Libraries should now be ready for the compilation of CAMx."
		
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