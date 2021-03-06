#
# This file contains defaults for CAMxRunner. 
# 
# Leave the next line intact, it is used for change detection
# Version: $Id$ 
#
# Written by Daniel C. Oderbolz (CAMxRunner@psi.ch),
# Released under the Creative Commons "Attribution-Share Alike 2.5 Switzerland"
# License, (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)
################################################################################

# Define IFS to be on the safe side
IFS=' 	
'

# Accept . as decimal point
export LC_NUMERIC=C

# used to tell the user how to start again
CXR_CALL="\$ ${0}"

################################################################################
# Bash settings     ############################################################
################################################################################

# We want to live on the safe side of town:
# Exit if any command returns non-zero 
# (means that $? cannot be checked anymore. Instead use 
# command || return $CXR_RET_ERROR)
# If you want to ignore failure (e. g. when calling expr) 
# use command || :
set -e

# Never use an undefined variable.
# This is a very strict requirement, but its also safe...
set -o nounset

# Bash sets HOSTTYPE too short (the only thing where tcsh is better)
# we want something like x86_64-linux
HOSTTYPE=$(uname -i)-$(echo "$(uname -s)" | tr "[:upper:]" "[:lower:]")

# This is our internal reference time (in Unix Epoch), used for Caching etc.
# TODO: This must be the minimum of all running instances
CXR_START_EPOCH="$(date "+%s")"

# This is our process number (to be used when exiting on error adn to kill the process group)
# Getting the pid is not easy, we do not want to create unnecessary processes...
# Note that we need to use out own tempfile mechanism here
tmp=$(mktemp /tmp/cxr_XXXXXXX)

# The pid is the parent of the awk process
# and the 4th field of /proc/self/stat is the Parent PID
awk '{print $4}' /proc/self/stat > $tmp
# read pid from file
CXR_PID=$(cat $tmp)

rm -f $tmp

# This pattern is used to identify numbers
#
#                    Line Boundaries ----+
#                    |                   |
#                    | Possible minus    |
#                    | |                 |
CXR_PATTERN_NUMERIC='^-?[0-9]+(\.[0-9]*)?$'

################################################################################
# Default Behaviour     ########################################################
################################################################################

# Statusses that the runner knows
CXR_STATUS_RUNNING=RUNNING
CXR_STATUS_SUCCESS=SUCCESS
CXR_STATUS_FAILURE=FAILURE
CXR_STATUS_TODO=TODO
# Only used for workers
CXR_STATUS_WAITING=WAITING 
CXR_STATUS_KILLED=KILLED	# Used to signal a worker that it must terminate

# Uncomment this for REALLY Verbose messages (directly from bash)
#set -xv

# Set this to true to disable locking.
# Dangerous, especially in parallel mode; should only be used when debugging
CXR_NO_LOCKING=false

# Set this to true to disable display of average concentrations
# (IC/BC/INST/AVG) Saves time, especially on 3D files,
# however, if somethings is strage in the neighbourhood,
# setting this to false may reveal important facts.
CXR_NO_CONC_CHECK=true

# Set this to true to disable all time measurements etc.
# if true, no ETA estimation is Possible
CXR_NO_TIME_MEASUREMENT=true

# If set >1, failed SQL statements are retried.
# Must be at least 1, otherwise no SQL is executed.
# We need this because if we cannet got a lock, the statement "fails"
CXR_DB_TRY_TIMES=5

# If a DB operation fails, we wait a bit until retry
CXR_DB_RETRY_WAIT_SECONDS=0.03

# Just for main.usage
progname=CAMxRunner.sh

# If we exit unexpectedly, we will indicate failure
CXR_STATUS=$CXR_STATUS_FAILURE

# Special key
CXR_SKIP_ALL=skip_all


# The indentation of the logging (improves readability)
CXR_LOG_INDENT=0

# If the variable CXR_ERROR_THRESHOLD is set to thes value,
# we do not check the number of errors during runtime
CXR_NO_ERROR_THRESHOLD=-1

# Threshold of errors that can happen before we stop. Set to -1 to ignore any errors,
# Set to 0 to stop at first error.
CXR_ERROR_THRESHOLD=5

# Number of digits calculate should use in divisions
CXR_NUM_DIGITS=4

# Max allowed indent
CXR_MAX_LOG_INDENT=8

# Sign to use to draw boxes (in log)
CXR_STAR='*'
CXR_STAR_T='#'

# Used by common.user.showProgress
CXR_PROGRESS_STATES=( '|' '/' '-' '\' )

# ' (For Editor only)

# The corresponding state variable
currentProgressState=0

# We define 3 box sizes
# 20
CXR_BOX_SMALL="********************"

# 40
CXR_BOX_LARGE="****************************************"
	
# 80
CXR_BOX_HUGE="********************************************************************************"


# These are needed for the user functions
CXR_SINGLE_LINE="-----------------------------------------------------------------------------"
CXR_DOUBLE_LINE="============================================================================="

# Max Parallel Procs
CXR_MAX_PARALLEL_PROCS=1

# If this variable is true, we are not really running (help etc.)
CXR_HOLLOW=false

# This variable allows to use the state DB for the installer
CXR_INSTALLER=installer


# Internal type constants for module handlers
# These are alse used to mark dependencies on whole types
# Note: a module must never have the same name as a module type!
CXR_TYPE_COMMON=common
CXR_TYPE_PREPROCESS_ONCE=preprocess_once
CXR_TYPE_PREPROCESS_DAILY=preprocess_daily
CXR_TYPE_MODEL=models
CXR_TYPE_POSTPROCESS_DAILY=postprocess_daily
CXR_TYPE_POSTPROCESS_ONCE=postprocess_once
CXR_TYPE_INSTALLER=${CXR_INSTALLER}

# Exit codes (implemented as bitmap, but not used as such yet)
# You could add those to signal more than one condition
# I am not sure if a value of more than 128 is supported, though...
# This is a little underused...
CXR_RET_OK=0
CXR_RET_ERROR=4
CXR_RET_ALREADY_RUN=8
CXR_RET_PARAM_ERROR=16
CXR_RET_CONTINUE_MISSING=32

# These are used to signal an issue in the modules
CXR_RET_ERR_PRECONDITIONS=64
CXR_RET_ERR_POSTCONDITIONS=128

# Definitions of the log levels
CXR_LOG_LEVEL_VRB=8
CXR_LOG_LEVEL_INF=4
CXR_LOG_LEVEL_WRN=2
CXR_LOG_LEVEL_ERR=1
CXR_LOG_LEVEL_ALW=0

CXR_LOG_PREFIX_ERR=ERR:
CXR_LOG_PREFIX_WRN=WRN:


# Here we set the default filter for screen and file messages
# Do not set these to CXR_LOG_LEVEL_ALW, it will not have
# the desired effect. (CXR_LOG_LEVEL_ALW is only used to report 
# messages)
CXR_LOG_LEVEL_SCREEN=${CXR_LOG_LEVEL_ERR}
CXR_LOG_LEVEL_FILE=${CXR_LOG_LEVEL_INF}

# This is used for twitter, SMS and Mail
# Which channels are used are controlled by
# CXR_SEND_SMS, CXR_SEND_TWITTER and CXR_SEND_EMAIL
CXR_LOG_LEVEL_EXTERNAL=${CXR_LOG_LEVEL_ERR}

# Note that you can configure the log-level 
# CXR_LOG_LEVEL_EXTERNAL
# to decide what to see there.
# As a minimum, you get a message when the run starts and when the run ends.

# If this Variable is true,Email will be sent
CXR_SEND_EMAIL=true

#If this Variable is true, SMS will be sent
CXR_SEND_SMS=false

# If this Variable is true, twitter wil be used
# Twitter allows us to publish our logs to a whole group of people
# To use it, create a ~/.twitterrc file (readable only to you)
# that sets the variables ACCOUNT and PASS
CXR_SEND_TWITTER=false

# Delimiter for ask and playfiles and other "DB-like" files
CXR_DELIMITER="|"


# A space used to delimit list elements
CXR_SPACE=" "


# This refix is added te all tempfiles
CXR_TMP_PREFIX=cxr_


#Normally, the state DB is in use
CXR_ENABLE_STATE_DB=true

# Define the prefix for disabled scripts (no dot please)
CXR_DISABLED_EXT=disabled

# Change this in case the name of the runner script changes
CXR_RUNNER_NAME=CAMxRunner.sh

# This is a special value that is used in many contexts
CXR_ALL=all

# Used to tell a single step from all steps
CXR_RUN_ALL=${CXR_ALL}

# For the alive file
CXR_ALIVE=alive

################################################################################
# Set inital values of features ################################################
################################################################################

# If CXR_RELOAD_CONF is true, the configration is reloaded before
# each new task. This is only needed if your configuration changes over time
# (e. g. "Use these windfiles for day 1 and 4"), otherwise it slows things down somewhat
CXR_RELOAD_CONF=false

# Warning level for system load in percent
# (as determined by ReaLoad)
CXR_LOAD_WARN_THRESHOLD=80

# Level where we bail out
CXR_LOAD_EXIT_THRESHOLD=90

# If this is true, we check memory availability
CXR_CHECK_MEMORY_USAGE=true

# Percentage of Memory that should be free upon starting a new task
CXR_MEM_FREE_PERCENT=20

# Parametes that control waiting
# Minutes we wait on a single event (file)
CXR_TIMEOUT_MINS=10

# Total timeout is 1 day
CXR_TOTAL_WAITING_MINS=$(( 24 * 60 ))

# Number of seconds we wait in each task iteration
# also used in the task functions, number of secods an idle task sleeps
CXR_WAITING_SLEEP_SECONDS=10

# When CXR_REPORT_INTERVAL * CXR_WAITING_SLEEP_SECONDS seconds have elapsed, 
# we report the Estimated Time of arrival
CXR_REPORT_INTERVAL=60

# This time in seconds is waited in each wait iteration for a lock
CXR_LOCK_SLEEP_SECONDS=0.01

# After this amount of seconds, we should stop to lock
# We use this lock to keep two processes from getting the same task,
# but also to keep exclusive, often long running modules alone.
# This must be at least as long as a single model task takes
CXR_LOCK_TIMEOUT_SEC=7200

# After this amount of seconds, a arallel worker gives up if
# dependencies are not satisfied
# If set to -1, we wait forever
CXR_DEPENDENCY_TIMEOUT_SEC=-1

# This is the max number of times all workers can be idle
# (consecutively)
# This mechanism allows to detect a locked up run faster than aboves timeouts
CXR_MAX_LOCKUP_COUNT=10

# Do we allow te write to linked output directories?
# If a run re-uses data of another run, it might be dangerous to allow this
# as the original runs data is not retained.
# Must be true if the CXR_TMP_DIR is a link.
CXR_ALLOW_WRITING_TO_LINKS=true

# If this is true, <common.runner.evaluateRule> will report all _FILE_RULEs that 
# resolve to links. Of course, this feature takes time
CXR_REPORT_LINKS=true

########################################
# Variables:  Parallel Task control
########################################

# If this is true, we allow a module to depend on 
# a module that is currently incative and has not yet finished
CXR_IGNORE_DISABLED_DEPENDENCIES=true

# If this is true, we ignore dependecies altogether (not recommended)
CXR_IGNORE_ANY_DEPENDENCIES=false

## End Task control

# Names of modules already checked
CXR_ANNOUNCED_MODULES=" "

# This variable is set within CAMxRunner.
# If true, we will not use an exclusive lock while the model runs.
# thi can be done if the number of CAMxRunner processes is le
# Number of CPUS avail - OMP_NUM_THREADS + 1
CXR_ALLOW_MODEL_CONCURRENCY=false

# If this is false, the temporary files will not be deleted
# Debug only!
CXR_REMOVE_TEMP_FILES=true

# If this is false, the temporarily decompressed files will not be deleted
# For the -L feature
CXR_REMOVE_DECOMPRESSED_FILES=true

# When set to true, the script logs even in a dry run
CXR_FORCE_LOG=false

# When set to true, the script logs
CXR_DO_FILE_LOGGING=true

# When set to true, CAMx is not run, only Input data is checked
CXR_DRY=false

# When set to true, CAMx is not run, only state information is cleared
CXR_CLEANUP=false

# When set to true, we show only info and quit
CXR_LIST_INFO=false

# If true, we prepare an external run
CXR_EXTERNAL=false

# When true, we display all modules
CXR_LIST_MODULES=false

# When set to true, CAMx is not run, only a rew run is created
CXR_CREATE_NEW_RUN=false

# When set to true,CAMx is not run, only the installation is run
CXR_INSTALL=false

# When set to true, we only test the CAMxRunner
CXR_RUN_TESTS=false

# When true, we disable set -e
CXR_TEST_IN_PROGRESS=false

#If non-empty, we will run these days (YYYY-MM-DD)
CXR_SINGLE_DAYS=

# When set to true, CAMx is not run, only other runners on the same rn are stopped
CXR_STOP_RUN=false

# When set to true, a lot of checking is not done
CXR_FAST=false

# When set to true, existing Output files are overwritten (see also CXR_SKIP_EXISTING)
CXR_FORCE=false

# If this is true, we wait for missing input
CXR_WAIT_4_INPUT=false

# When set to false, existing Output files are not skipped (we stop if they exist, unless -F is given)
CXR_SKIP_EXISTING=true

# When set to false, we no longer do change detection of input files.
# This is done by keeping MD5 Hashes of all input files encountered in a global place
CXR_INPUT_CHANGE_DETECTION=true

# When set to false, disables check for disk space for model runs
CXR_CHECK_MODEL_SPACE_REQUIRED=true

# When set to false, we no longer check the lengths of the paths of filenames
# This check is important for programs that are compiled with a certain pathlenght
# Most often, these values are much lower than the maximum allowed by the OS e. g. ( grep MAX_PATH /usr/include/linux/limits.h)
# On AFS we aso test if the total length of the filenames exceeds CXR_MAX_AFS_FN_LEN
CXR_CHECK_MAX_PATH=true

# Currently we assume this limit
CXR_MAX_PATH=240

# These settings are used to check if the converters etc. can handel files
# of the current grid size. Make sure all executables support at least these limits.
CXR_MAX_XDIM=300
CXR_MAX_YDIM=300
CXR_MAX_ZDIM=33
CXR_MAX_NSPEC=150

# On AFS, there is a limit of the total filename length
# of all files in a directory. The actual limit is not
# so straightforward (see man fileserver)
CXR_MAX_AFS_FN_LEN=960000

# If true, run CAMx , otherwise dont
CXR_RUN_MODEL=true

# If true, compress the output files upon completion
# The compressors are set in the config (common.compressor.*)
CXR_COMPRESS_OUTPUT=true

# This is a pattern that can be used to limit compression either to 
# specific files or specific modules that created the files
# is tested using "expr match"
# If it is empty, it has no effect
CXR_COMPRESS_OUTPUT_PATTERN=

# Sets the minimal size threshold for compression in MB
# Files smaller than this will not be compressed,
# even if the pattern matches
CXR_COMPRESS_THRESHOLD_MB=50

# If true, CAMxRunner will report the MD5 Hash of each input file
# We use MD5 instead of SHA1 because of speed reasons
# While it takes more time, this can save a lot of headache when comparing files
CXR_REPORT_MD5=true

# This Check variable makes sure certain things are only checked once and not for each day
CXR_CHECKED_ONCE=false

# Contains an explanatory extension for the logfile name
# is set according to the options set
CXR_LOG_EXT=""

################################################################################
################################################################################
# Now follows a default set of options that might be copied to a configuration file.
# The defaults given here should make sense most of the time.
# Note that this set is not complete, all model specific parameters like
# geometry etc. are defined in base.conf
################################################################################	
################################################################################

# With this flag you can indicate that already the first
# simulation day is a restart. Normally false.
# Useful for example to repeat just a part of a run.
CXR_START_WITH_RESTART=false

# This list is filled by -r
CXR_RUN_LIST=

################################################################################
# Disabled Modules (space-separated module names, ${CXR_SKIP_ALL} disables whole class)
################################################################################

CXR_DISABLED_DAILY_PREPROC=""

CXR_DISABLED_ONCE_PREPROC=""

CXR_DISABLED_DAILY_POSTPROC=""

CXR_DISABLED_ONCE_POSTPROC=""

CXR_DISABLED_MODEL=""

CXR_DISABLED_INSTALLER=""

################################################################################
# Enabled Modules (space-separated module names, stronger counterpart of the former variables)
################################################################################

CXR_ENABLED_DAILY_PREPROC=""

CXR_ENABLED_ONCE_PREPROC=""

CXR_ENABLED_DAILY_POSTPROC=""

CXR_ENABLED_ONCE_POSTPROC=""

CXR_ENABLED_MODEL=""

CXR_ENABLED_INSTALLER=""

################################################################################
# Directories 
# Attention: Put no variables in directory names that are not yet set here!
# E. g. any variable containing dates (like simulation year) will fail to expand!
# All Model/Version specific dirs are set in main.readConfig
################################################################################

# This is the directory where tempfiles go.
# We do not recommed to use /tmp because the space requirements
# might be significant (e. g. when decompressing files, we need a few GB per file)
# If you plan to use more than one machine in parallel, all need to use the same
# directory (hence it must be on a network FS)
# This is for efficiency reasons (to avoid decompressing the same files more than once)
CXR_TMP_DIR=~/tmp

# If we do not decompress in place, we decompress into this directory
# This is filled in common.state.init
CXR_TMP_DECOMP_DIR=

# The directory where the executables lie
CXR_BIN_DIR=${CXR_RUN_DIR}/bin

# The directory where the libraries lie
CXR_LIB_DIR=${CXR_RUN_DIR}/lib

# Here is the config
CXR_CONF_DIR=${CXR_RUN_DIR}/conf

# Here are the templates
CXR_TEMPLATES_DIR=${CXR_RUN_DIR}/templates

# Here are the modules
CXR_MODULES_DIR=${CXR_RUN_DIR}/modules

# External functions are loaded from here
CXR_COMMON_INPUT_DIR=${CXR_MODULES_DIR}/common

# Common installers are here
CXR_INSTALLER_INPUT_DIR=${CXR_MODULES_DIR}/${CXR_INSTALLER}

################################################################################
# Parameters to estimate space needed
################################################################################

# MB per 10^5 cells/species/timestep
# If no source apportionment is selected
CXR_C_SPACE_NONE=2.2046 

# The actual selection must be based on options
CXR_C_SPACE=${CXR_C_SPACE_NONE}

# Safety factor
CXR_F_MARGIN=1.1

# Fraction of space (of total run) we need in the tmp dir
CXR_TMP_SPACE_FACTOR=0.05

################################################################################
# Parameters to estimate time needed
################################################################################

# This variable will hold the estimated total time
CXR_TIME_TOTAL_ESTIMATED=0

# This is graphical - the max with of the progress bar
CXR_MAX_BAR_WIDTH=80

################################################################################
# Parameters for map conversion
################################################################################

CXR_MAP_EARTH_RADIUS_METRE=6370000

# Supported Projections
CXR_MAP_PROJECTION_LATLON=LATLON
CXR_MAP_PROJECTION_LAMBERT=LAMBERT
CXR_MAP_PROJECTION_POLAR=POLAR
CXR_MAP_PROJECTION_UTM=UTM
CXR_MAP_PROJECTION_SWISS=SWISS
CXR_MAP_PROJECTION_INDEX=INDEX


################################################################################
# Installer - specific settings (find more in the CAMx version specific .conf files)
################################################################################

# A comma-separated list of Probing tools
# Note that support of CAMxRunner is still limited in this area
CXR_SUPPORTED_CAMX_PROBING_TOOLS="None OSAT PSAT DDM PA RTRAC"

# A comma-separated list of parallel paradigms.
# CAMx 5.x also supports MPI
CXR_SUPPORTED_PARALLEL_PARADIGMS="None OMP MPI"

# A list of supported platforms for CAMx (could be determined using uname - but this is configures job!)
# Taken from the Makefile
CXR_SUPPORTED_PLATFORMS="dec pg_linux pg_linuxomp i_linux i_linuxomp ab_linux sgi sgiomp sun hp ibm"

# Directory rules to find patches. CXR_CURRENT_BINARY contains the name of the current binary (e. g. 'CAMx'), CXR_CURRENT_PLATFORM the platform we compile for (e. g. 'i_linuxomp')
CXR_PATCH_ALL_DIR_RULE='${CXR_INSTALLER_INPUT_DIR}/${CXR_MODEL}/${CXR_MODEL_VERSION}/patches/${CXR_CURRENT_BINARY}/all_platforms'
CXR_PATCH_PLATFORM_DIR_RULE='${CXR_INSTALLER_INPUT_DIR}/${CXR_MODEL}/${CXR_MODEL_VERSION}/patches/${CXR_CURRENT_BINARY}/$CXR_CURRENT_PLATFORM'

# before applying a patch, this number of lines is shown
CXR_PATCH_HEADER_LENGHT=20

################################################################################
# CAMxRunner specific settings
################################################################################

# Set this to false to disable CAMx in this run
CXR_RUN_MODEL=true

# Logs go here
CXR_LOG_OUTPUT_DIR=${CXR_RUN_DIR}/log

#State information is stored here
CXR_STATE_DIR=${CXR_RUN_DIR}/state/$CXR_RUN
mkdir -p $CXR_STATE_DIR

# Supported Types of Hashes/DBs
CXR_LEVEL_UNIVERSAL=universal
CXR_LEVEL_GLOBAL=global
CXR_LEVEL_INSTANCE=instance

# Suffix for sqlite files
CXR_DB_SUFFIX=sqlite

# Min Version of SQLite needed
CXR_MIN_SQLITE_VERSION=3.7

# Some state data is global to all runs (e. g. the hash used for change detection)
CXR_UNIVERSAL_DIR=${CXR_RUN_DIR}/state/$CXR_LEVEL_UNIVERSAL

# This universal DB file stores timing information
CXR_UNIVERSAL_TIMING_DB=${CXR_UNIVERSAL_DIR}/timing.sqlite

########################################
# Data that is global to all instances of a given run
########################################

# Directory where the global stuff goes
# Global data is normally not deleted
CXR_GLOBAL_DIR=$CXR_STATE_DIR/$CXR_LEVEL_GLOBAL

mkdir -p $CXR_GLOBAL_DIR

# If a run should fail abnormally, this file is created
CXR_GLOBAL_ABNORMAL_TERMINATION_FILE=$CXR_GLOBAL_DIR/abnormal_termination

# Remove this file, should it already exist
if [[ -e $CXR_GLOBAL_ABNORMAL_TERMINATION_FILE ]]
then
	rm -f "$CXR_GLOBAL_ABNORMAL_TERMINATION_FILE"
fi

# In this directory, we store all files used to call
# executables (except for the model)
CXR_JOBFILE_DIR=$CXR_GLOBAL_DIR/jobfiles

########################################
# Parallel Task execution. 
# This is global to all instances
########################################

# In this DB we store all information about tasks, 
# workers etc.
CXR_STATE_DB_FILE=$CXR_GLOBAL_DIR/tasks.${CXR_DB_SUFFIX}

########################################
# Logging
########################################

# Name of the Log file 
CXR_LOG=${CXR_LOG_OUTPUT_DIR}/${CXR_RUN}_$(date +"%Y_%m_%d_%H_%M")${CXR_LOG_EXT}.log
# This is the 0th logfile
CXR_LOGS[0]=$CXR_LOG

################################################################################
# Per-Instance Information
################################################################################

########################################
# Machine name
########################################

CXR_MACHINE="$(uname -n)"

########################################
#  Instance name PID@HOST
########################################
CXR_INSTANCE=${CXR_PID}@${CXR_MACHINE}


########################################
# This directory holds the instance-information
# The whole directory is removed after a run
# All files named CXR_INSTANCE_FILE_* are
# Created automatically in <common.state.init>
# The directories must be created explicitly there
########################################

CXR_ALL_INSTANCES_DIR=${CXR_STATE_DIR}/instances

CXR_INSTANCE_DIR=${CXR_ALL_INSTANCES_DIR}/${CXR_INSTANCE}
mkdir -p "${CXR_INSTANCE_DIR}"

# This file is touched by the controller so that we know its alive
CXR_INSTANCE_FILE_ALIVE=${CXR_INSTANCE_DIR}/${CXR_ALIVE}
touch $CXR_INSTANCE_FILE_ALIVE

# In this file, we store the error stack
CXR_INSTANCE_FILE_ERROR_STACK=${CXR_INSTANCE_DIR}/error.stack

# In this file, we store the days where issues where detected
CXR_INSTANCE_FILE_FAILED_DAYS=${CXR_INSTANCE_DIR}/failed.days

# In this file, we store temporay files of a run. 
# (e. g. AHOMAP Control files)
# These will be deleted after the run. To avoid any attacks,
# we use a random filename
CXR_INSTANCE_FILE_TEMP_LIST=${CXR_INSTANCE_DIR}/temp.list${RANDOM}

# Determine the name of the Continue file (must be this early because of lock manager)
# This is used to search for any continue files
CXR_CONTINUE=${CXR_RUNNER_NAME}.CONTINUE

# The whole file name -if it is deleted, this instance stops
# This file is created explictly in common.state.init
CXR_CONTINUE_FILE=${CXR_INSTANCE_DIR}/${CXR_CONTINUE}

####################################
# Hashes
####################################

# In this hash, we store files that where decompressed (for all instances)
CXR_GLOBAL_HASH_DECOMPRESSED_FILES=Decompressed_Files

# In this hash, we store all output files that have been generated
# This is used to compress output if needed or to delete output.
CXR_INSTANCE_HASH_OUTPUT_FILES=Output_Files

# In this hash, we store dummy files of a dry run.
# These will be deleted after the dry run
CXR_INSTANCE_HASH_DUMMY_FILES=Dummy_Files

# In this hash, we store links that got new targets
# These will be re-created after the run
CXR_INSTANCE_HASH_RELOCATED_LINKS=Relocated_Links

# This hash holds module-specific config items
CXR_INSTANCE_HASH_CONF=conf


################################################################################
# Supported model names.
################################################################################
CXR_SUPPORTED_MODELS="CAMx PMCAMx"
#                            |    | 
#                      Model 0    |
#                           Model 1 ...

# Supported CAMx Versions (space separated)
CXR_SUPPORTED_MODEL_VERSIONS[0]="4.42 4.51 5.10 5.20.1 5.30 5.40 5.41 6.00"
CXR_SUPPORTED_MODEL_VERSIONS[1]="2008"

# Comma separated list of subdirectories which must be in $CXR_RUN_DIR
CXR_RUN_SUBDIRS="bin conf doc log modules state templates"


# Comma separated list of subdirectories containig version-specific driectories
CXR_RUN_VERSION_SUBDIRS="bin modules/common modules/installer modules/model modules/preproc modules/postproc"


################################################################################
# Information relevant for compilation
################################################################################


################################################################################
# bin2asc conversion
################################################################################
#No leading dot please
CXR_ASC_EXT=asc


################################################################################
# Executables
################################################################################

# Decompression
CXR_GUNZIP_EXEC="$(main.getBinaryName gunzip true)"
CXR_BUNZIP2_EXEC="$(main.getBinaryName bunzip2 true)"

# Compression
CXR_GZIP_EXEC="$(main.getBinaryName gzip true)"
CXR_BZIP2_EXEC="$(main.getBinaryName bzip2 true)"
CXR_LZOP_EXEC="$(main.getBinaryName lzop true)"

# Hash generation
CXR_MD5_EXEC="$(main.getBinaryName md5sum true)"

# SQLite db engine (needed for Hashes)
CXR_SQLITE_EXEC="$(main.getBinaryName sqlite3 true)"

# This is a SQLITE Library for statistical functions
CXR_SQLITE_LIBFUNCTIONS="$(main.getLibraryName libsqlitefunctions.so sqlite3)"



if [[ -e $CXR_SQLITE_LIBFUNCTIONS ]]
then
	CXR_SQLITE_LIBFUNCTIONS_SUPPORTED=true
else
	CXR_SQLITE_LIBFUNCTIONS_SUPPORTED=false
fi

# The fallback compressor, if no entries are present in common.compressor.*
CXR_FALLBACK_COMPRESSOR_EXEC="$CXR_GZIP_EXEC -1"

# Fortran-77 Compiler (only needed when installing)
CXR_FORTRAN77_COMPILER_EXEC="$(main.getBinaryName pgf77 true)"

# Fortran-90 Compiler (only needed when installing)
CXR_FORTRAN90_COMPILER_EXEC="$(main.getBinaryName pgf90 true)"

# The C Compiler (used sparingly)
CXR_C_COMPILER_EXEC="$(main.getBinaryName gcc true)"

# This is the default FORTRAN compiler
CXR_FORTRAN_COMPILER_EXEC="$CXR_FORTRAN90_COMPILER_EXEC"

# API GENERATOR
CXR_API_DOC_EXEC=${CXR_BIN_DIR}/generate-api-doc.sh

# wget to download stuff (needed for installation and AHOMAP)
CXR_WGET_EXEC=$(main.getBinaryName wget true)

# needed for coordinate transformations
CXR_CS2CS_EXEC="$(main.getBinaryName cs2cs)"

# needed to convert dos-unix and back
CXR_DOS2UNIX_EXEC="$(main.getBinaryName dos2unix true)"
CXR_UNIX2DOS_EXEC="$(main.getBinaryName unix2dos true)"

# This is central to determine execution order
CXR_TSORT_EXEC="$(main.getBinaryName tsort)"

# this can be used to draw graphs
CXR_DOT_EXEC="$(main.getBinaryName dot true)"

#### It is recommended to compile the binaries
#### into binaries that carry the machine type in their name
#### CAMxRunner -I can do this for you.
#### 
#### The function main.getBinaryName then selects the most appropriate one.
#### replace with literal for your own choice

# Checker for landuse
CXR_SRFLND_EXEC=$(main.getBinaryName srflnd)

# The binary to convert bin2asc
CXR_BIN2ASC_EXEC=$(main.getBinaryName bin2asc)

# The binary to convert asc2bin
CXR_ASC2BIN_EXEC=$(main.getBinaryName asc2bin)

# The binary to convert Emission ascii to Bin
CXR_AIRCONV_EXEC=$(main.getBinaryName airconv)

# The binary to convert MM5 Input
CXR_UAMVASCII_EXEC=$(main.getBinaryName uamvascii)

# Binary to convert the other way
CXR_UAMVBINR_EXEC=$(main.getBinaryName uamvbinr)

# Yet another binary to convert MM5 Input
CXR_AIRASCII_EXEC=$(main.getBinaryName airascii)

# Needed to create constant IC/BC fields
CXR_ICBCPREP_EXEC=$(main.getBinaryName icbcprep)

# Avgdif
CXR_AVGDIF_EXEC=$(main.getBinaryName avgdif)

########################################
# Preprocessors
########################################	
CXR_AHOMAP_EXEC=$(main.getBinaryName ahomap)
CXR_TUV_EXEC=$(main.getBinaryName tuv)
CXR_O3MAP_EXEC=$(main.getBinaryName o3map)
CXR_METCONVERT_EXEC=$(main.getBinaryName metconvert)

########################################
# Postprocessors
########################################	
CXR_EXT_IPR_EXEC=$(main.getBinaryName ext_ipr)
CXR_EXT_IRR_EXEC=$(main.getBinaryName ext_irr)
CXR_VERTAVG_EXEC=$(main.getBinaryName vertavg)
CXR_PSAT_COMBINE_EXEC=$(main.getBinaryName psat_combine)
CXR_DIAGNOSE_PBL_EXEC=$(main.getBinaryName diagnose_pbl)

################################################################################
# Advanced Input check
################################################################################

# If this is true, the we will look for compressed versions of missing files
CXR_DETECT_COMPRESSED_INPUT_FILES=true

# If this is true, files will be decompressed where they are.
# This is not recommended, because the user might not have write permission in all
# source directories.
# If it is false, make sure that the directory CXR_TMP_DIR has enough space free...
CXR_DECOMPRESS_IN_PLACE=false

# To map filetypes to decompressors, use something like
# > common.conf.set "common.decompressor.zip=$CXR_GUNZIP_EXEC"
# in your config


################################################################################
################################################################################
# Model details
################################################################################
################################################################################

################################################################################
# Name/Path of the CAMx.in file
################################################################################

# A rule that must be expanded
CXR_MODEL_CTRL_FILE_RULE='${CXR_STATE_DIR}/CAMx.${CXR_DATE_RAW}.in'


########################################
# Options for the export of station-specific data
# Check if your extractor supports all these
########################################

# Which species should be extracted (all does all, otherwise, provide a space separated list)
CXR_STATION_SPECIES=${CXR_ALL}

# How should we normalize the concentrations? (nabel, physical, none)
CXR_NORM_METHOD=physical

# Format can be either CSV or IDL
CXR_STATION_FILE_FORMAT=IDL

# The format of the numbers to use
CXR_STATION_NUMBER_FORMAT=(5e14.7)

# when true, concentrations will be normalized
CXR_STATION_NORMALIZE_CONCENTRATIONS=true

# Using these values for normalization
CXR_STATION_NORMALIZE_TEMPERATURE_K=293
CXR_STATION_NORMALIZE_PRESSURE_PA=101300

# Station coordinates can be expressed in any projection
# supported by <common.map.LonLatToProjection>. 
CXR_STATION_PROJECTION="SWISS"

# Which grid(s) do we extract on
# make sure your CXR_STATION_FILE_RULE supports CXR_IGRID if you have more than one station here.
CXR_RUN_EXTRACTION_ON_GRID="3"



########################################
# Preparation of IC/BC/TC
########################################

# Method that is used to determine ic/bc/tc
# Currently supported: MOZART, MOZART_INCREMENT, MOZART_CONSTANT or ICBCPREP
#
# MOZART uses the data from the MOZART global CTM
# MOZART_CONSTANT uses our preprocessor but replaces the MOZART data by constant values
# MOZART_INCREMENT allows to selectively increment certain species by a specified value (in PPM)
# ICBCPREP uses the ENVIRON preprocessor icbcprep (resulting in constant IC and BC data)

CXR_IC_BC_TC_METHOD=MOZART

if [[ "$CXR_IC_BC_TC_METHOD" != MOZART  ]]
then
	# If we are not using MOZART, we need to define the constant values
	# or the increments.
	# If you are using MOZART_CONSTANT, you need to supply data for each element
	# of CXR_CAMX_MOZART_MAPPING because the preprocessors loops through that array

	# Here you need to define the species and the concentrations
	# (in ppm for gases, in ug/m**3 for aerosols) to use (format is "SPECIES:conc")
	# Depending on CXR_IC_BC_TC_METHOD, these are either increments or constant values.
	# Make sure the numbers are in Fortran 10.7 Format
	
	# Unset first - it's an array!
	unset CXR_IC_BC_TC_SPEC
	
	CXR_IC_BC_TC_SPEC[0]=O3:0.074740447 
	CXR_IC_BC_TC_SPEC[1]=CO:0.113577254 
	CXR_IC_BC_TC_SPEC[2]=FORM:0.000146525 
	CXR_IC_BC_TC_SPEC[3]=NO:0.000000436 
	CXR_IC_BC_TC_SPEC[4]=NO2:0.000035782 
	CXR_IC_BC_TC_SPEC[5]=HNO3:0.000045410 
	CXR_IC_BC_TC_SPEC[6]=PNA:0.000001336 
	CXR_IC_BC_TC_SPEC[7]=H2O2:0.001014395 
	CXR_IC_BC_TC_SPEC[8]=PAN:0.000176876 
	CXR_IC_BC_TC_SPEC[9]=CH4:1.843935728 
	CXR_IC_BC_TC_SPEC[10]=ALD2:0.000023972 
	CXR_IC_BC_TC_SPEC[11]=ETHA:0.000482804 
	CXR_IC_BC_TC_SPEC[12]=ISOP:0.000002357 
	CXR_IC_BC_TC_SPEC[13]=TOL:0.000009159 
fi

# This array describes the mapping of MOZART to CAMx species
# Prior to 2004, MOZART provides only 5 species
# The order is the same, so it is sufficient to change this parameter
# in the config file

# Unset first - it's an array!
unset CXR_CAMX_MOZART_MAPPING

# Syntax is CAMx:MOZART
CXR_CAMX_MOZART_MAPPING[0]=O3:O3_VMR_inst
CXR_CAMX_MOZART_MAPPING[1]=CO:CO_VMR_inst
CXR_CAMX_MOZART_MAPPING[2]=FORM:CH2O_VMR_inst
CXR_CAMX_MOZART_MAPPING[3]=NO:NO_VMR_inst
CXR_CAMX_MOZART_MAPPING[4]=NO2:NO2_VMR_inst
CXR_CAMX_MOZART_MAPPING[5]=HNO3:HNO3_VMR_inst
CXR_CAMX_MOZART_MAPPING[6]=PNA:HO2NO2_VMR_inst
CXR_CAMX_MOZART_MAPPING[7]=H2O2:H2O2_VMR_inst
CXR_CAMX_MOZART_MAPPING[8]=PAN:PAN_VMR_inst
CXR_CAMX_MOZART_MAPPING[9]=CH4:CH4_VMR_inst
CXR_CAMX_MOZART_MAPPING[10]=ALD2:CH3CHO_VMR_inst
CXR_CAMX_MOZART_MAPPING[11]=ETHA:C2H6_VMR_inst
CXR_CAMX_MOZART_MAPPING[12]=ISOP:ISOP_VMR_inst
CXR_CAMX_MOZART_MAPPING[13]=TOL:TOLUENE_VMR_inst

# Automatically count # species (no dummy)
CXR_NUMBER_OF_GCTM_SPECIES=$(( ${#CXR_CAMX_MOZART_MAPPING[@]} ))

####################
# Plotting BC data
####################

# If true, diagnostic plots are done
CXR_IC_BC_TC_DO_PLOT=true
# Where to put the plots
CXR_IC_BC_TC_PLOT_BASE_DIR=~/@plot
# Which time to plot (times 3 gives real time, so 3 is 15UTC)
CXR_IC_BC_TC_PLOT_TIME=5
# Create PNGs 
CXR_IC_BC_TC_DO_PNG=true
# Delete intermediate PS
CXR_IC_BC_TC_RM_PS=true

################################################################################
# SA Tools
################################################################################

# If this is false, we use an existing receptor file.
# Otherwise a new one is created
CXR_PSAT_CREATE_RECEPTOR_FILE=true

################################################################################
# Module set_permissions
################################################################################

# These permissions are used on the output
CXR_OUTPUT_DIR_PERMISSIONS=0755


################################################################################
# END OF FILE
################################################################################
