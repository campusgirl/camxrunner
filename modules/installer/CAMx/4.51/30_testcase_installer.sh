# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Installer for CAMx 4.51
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
#
# Written by Daniel C. Oderbolz (CAMxRunner@psi.ch).
# This software is provided as is without any warranty whatsoever. See doc/Disclaimer.txt for details.
# Released under the Creative Commons "Attribution-Share Alike 2.5 Switzerland"
# License, (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)
################################################################################
# TODO: 
################################################################################
# Module Metadata. Leave "-" if no setting is wanted
################################################################################

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Installs and prepares the ENVIRON test case"

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}""

CXR_META_MODULE_TYPE="${CXR_TYPE_POSTPROCESS_DAILY}"

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
# Function: CAMx_installer
#
# Downloads and prepares the ENVIRON Testcase for CAMx 4.51
#
function testcase_installer() 
################################################################################
{
	
	
	if [[ "$(common.user.getOK "Do you want to install the ${CXR_MODEL_VERSION} testcase to $TESTCASE_DIR?\n\nRequires about $CXR_CAMX_TESTCASE_MEGABYTES_REQUIRED MB of space." Y )" == true  ]]
	then
		mkdir -p $TESTCASE_DIR || main.dieGracefully "Could not create $TESTCASE_DIR"
		
		########################################
		# Check space
		########################################
		common.check.MbNeeded "$TESTCASE_DIR" "$CXR_CAMX_TESTCASE_MEGABYTES_REQUIRED"
		
		cd $TESTCASE_DIR || main.dieGracefully "Could change to $TESTCASE_DIR"
		
		########################################
		main.log  "Downloading three files - might take a while..."
		sleep 2
		########################################
		
		# Get the 3 files
		common.install.downloadFile ${CXR_CAMX_TESTCASE_TGZ_MET_LOC} ${CXR_CAMX_TESTCASE_TGZ_MET} true
		common.install.downloadFile ${CXR_CAMX_TESTCASE_TGZ_IN_LOC} ${CXR_CAMX_TESTCASE_TGZ_IN} true
		common.install.downloadFile ${CXR_CAMX_TESTCASE_TGZ_OUT_LOC} ${CXR_CAMX_TESTCASE_TGZ_OUT} true
		
		########################################
		main.log  "Unpacking tar files..."
		########################################
		
		# Untar
		tar xzvf ${CXR_CAMX_TESTCASE_TGZ_MET} || main.dieGracefully "could not untar $CXR_CAMX_TESTCASE_TGZ_MET"
		tar xzvf ${CXR_CAMX_TESTCASE_TGZ_IN} || main.dieGracefully "could not untar $CXR_CAMX_TESTCASE_TGZ_IN"
		tar xzvf ${CXR_CAMX_TESTCASE_TGZ_OUT} || main.dieGracefully "could not untar $CXR_CAMX_TESTCASE_TGZ_OUT"
		
		if [[ "$(common.user.getOK "Do you want to remove the tar files?\nRecommended, they are large and unneeded." Y )" == true  ]]
		then
			rm ${CXR_CAMX_TESTCASE_TGZ_MET}
			rm ${CXR_CAMX_TESTCASE_TGZ_IN}
			rm ${CXR_CAMX_TESTCASE_TGZ_OUT}
		fi
		
		########################################
		main.log  "Renaming testcase files for use with CAMxRunner run CAMx-v${CXR_MODEL_VERSION}.ENVIRON_testcase"
		########################################	
		
		# Run renamer
		${CXR_RUN_DIR}/testcase/${CXR_MODEL}/${CXR_MODEL_VERSION}/rename_inputs4CAMxRunner.sh
		
		main.log  "Done. You should now have a working testcase for CAMx ${CXR_MODEL_VERSION}.\nStart if with the run CAMx.v${CXR_MODEL_VERSION}.ENVIRON_testcase\nThe expected output is in ${CXR_RUN_DIR}/testcase/${CXR_MODEL_VERSION} and the new model output will be in ${CXR_RUN_DIR}/testcase/${CXR_MODEL_VERSION}/outputs after the run."
			
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