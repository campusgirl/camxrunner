# Processing modules are not meant to be executed stand-alone, so there is no
# she-bang and the permission "x" is not set.
#
# Common script for the CAMxRunner 
# See http://people.web.psi.ch/oderbolz/CAMxRunner 
#
# Version: $Id$ 
#
# Contains the Functions to manage parallel execution of modules.
# The most important aspect of this is the management of the varius dependencies 
# between modules.
#
# Prepares a pool of tasks, which are then harvested by Worker threads. 
# This pool is implemented as a <http://www.sqlite.org> DB.
# 
# The worker processes can run in parallel - even on different machines.
#
# Approach:
# First, a list of tasks is generated.
# This list is sorted according to the dependencies (topological sorting), so that tasks with no or few
# dependencies appear first -> execution plan.
# Then, we create a number of workers, which each get a unique entry of this list. 
# They check first if the dependencies are already fulfilled 
# if not they wait, otherwise the task starts.
# After successful execution, the worker gets the next task from the list.
# A task is identified by its module name, a day offset, and a invocation id. 
# The invocation id is useful for tasks that can be splitted further, like albedo_haze_ozone.
# This allows us to parallelize parts of a task.
#
# Written by Daniel C. Oderbolz (CAMxRunner@psi.ch).
# This software is provided as is without any warranty whatsoever. See doc/Disclaimer.txt for details. See doc/Disclaimer.txt for details.
# Released under the Creative Commons "Attribution-Share Alike 2.5 Switzerland"
# License, (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)
################################################################################
# TODO: Periodically check CXR_MAX_PARALLEL_PROCS
################################################################################
# Module Metadata. Leave "-" if no setting is wanted
################################################################################

# Either "${CXR_TYPE_COMMON}", "${CXR_TYPE_PREPROCESS_ONCE}", "${CXR_TYPE_PREPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_DAILY}","${CXR_TYPE_POSTPROCESS_ONCE}", "${CXR_TYPE_MODEL}" or "${CXR_TYPE_INSTALLER}"
CXR_META_MODULE_TYPE="${CXR_TYPE_COMMON}"

# If >0, this module supports testing
CXR_META_MODULE_NUM_TESTS=3

# This string describes special requirements this module has
# it is a space-separated list of requirement|value[|optional] tuples.
# If a requirement is not binding, optional is added at the end
CXR_META_MODULE_REQ_SPECIAL="exec|dot|optional exec|tsort"

# Add description of what it does (in "", use \n for newline)
CXR_META_MODULE_DESCRIPTION="Contains the functions to manage parallel task execution"

# URL where to find more information
CXR_META_MODULE_DOC_URL="http://people.web.psi.ch/oderbolz/CAMxRunner"

# Who wrote this module?
CXR_META_MODULE_AUTHOR="Daniel C. Oderbolz (2008 - 2009), CAMxRunner@psi.ch"

# Add license info if applicable (possibly with URL)
CXR_META_MODULE_LICENSE="Creative Commons Attribution-Share Alike 2.5 Switzerland (http://creativecommons.org/licenses/by-sa/2.5/ch/deed.en)"

# Do not change this line, but make sure to run "svn propset svn:keywords "Id" FILENAME" on the current file
CXR_META_MODULE_VERSION='$Id$'

################################################################################
# Function: common.parallel.formatDependency
#
# Creates a proper dependency string out of several inputs.
#
# Example:
# > echo "${dependency} $(common.parallel.formatDependency "$module_name" "$module_type" "$day_offset" "$iInvocation" "$nInvocations")" >> $output_file
# 
# Parameters:
# $1 - module name
# $2 - module type
# $3 - day offset
# $4 - iInvocation
# $5 - nInvocations
################################################################################
function common.parallel.formatDependency()
################################################################################
{
	local module_name
	local module_type
	local day_offset
	local iInvocation
	local nInvocations
	
	module_name="${1}"
	module_type="${2}"
	day_offset="${3}"
	iInvocation="${4}"
	nInvocations="${5}"

	# Create dependency string
	if [[ "$module_type" == "${CXR_TYPE_MODEL}" ||\
	      "$module_type" == "${CXR_TYPE_PREPROCESS_DAILY}" ||\
	      "$module_type" == "${CXR_TYPE_POSTPROCESS_DAILY}" ]]
	then
		# With day offset
		
		# Add invocation only if there is more than one
		if [[ $nInvocations -gt 1 ]]
		then
			echo "${module_name}${day_offset}@${iInvocation}" 
		else
			echo "${module_name}${day_offset}"
		fi
	else
		# Without day offset
		
		# Add invocation only if there is more than one
		if [[ $nInvocations -gt 1 ]]
		then
			echo "${module_name}@${iInvocation}"
		else
			echo "${module_name}"
		fi
	fi
}


################################################################################
# Function: common.parallel.createDependencyList
# 
# Collects all dependencies (resolved) of the modules to be executed in a file of the form
# independent_module dependent_module.
# The actual resolving is done in <common.module.resolveAllDependencies>.
# If a module has no dependencies, then the line is
# independent_module independent_module
# (see man tsort for details)
#
# Hashes:
# CXR_MODULE_TYPE_HASH ($CXR_HASH_TYPE_UNIVERSAL) - maps module names to their type
#
# CXR_ACTIVE_ALL_HASH ($CXR_HASH_TYPE_GLOBAL) - contains all active modules (dummy value)
# CXR_ACTIVE_ONCE_PRE_HASH ($CXR_HASH_TYPE_GLOBAL) - contains all active One-Time preprocessing modules (dummy value)
# CXR_ACTIVE_DAILY_PRE_HASH ($CXR_HASH_TYPE_GLOBAL) - contains all active daily preprocessing modules (dummy value)
# CXR_ACTIVE_MODEL_HASH ($CXR_HASH_TYPE_GLOBAL) - contains all active model modules (dummy value)
# CXR_ACTIVE_DAILY_POST_HASH ($CXR_HASH_TYPE_GLOBAL) - contains all active daily postprocessing modules (dummy value)
# CXR_ACTIVE_ONCE_POST_HASH ($CXR_HASH_TYPE_GLOBAL) - contains all active One-Time postprocessing modules (dummy value)
#
# Parameters:
# $1 - output_file to write list of dependencies for tsort to sort to
################################################################################
function common.parallel.createDependencyList()
################################################################################
{
	local output_file
	local tempfile
	local module
	local module_type
	local active_hashes
	local active_hash
	local raw_dependencies
	local dependency
	local day_offset
	local iInvocation
	local nInvocation
	local dep_string
	local active_modules
	local activeModuleKeys
	local keyString
	
	output_file="$1"
	
	# Add the different module types
	if [[ "$CXR_RUN_PRE_ONCE" == true ]]
	then
		active_hashes="${active_hashes} ${CXR_ACTIVE_ONCE_PRE_HASH}"
	fi
	
	if [[ "$CXR_RUN_PRE_DAILY" == true ]]
	then
		active_hashes="${active_hashes} ${CXR_ACTIVE_DAILY_PRE_HASH}"
	fi
	
	if [[ "$CXR_RUN_MODEL" == true ]]
	then
		active_hashes="${active_hashes} ${CXR_ACTIVE_MODEL_HASH}"
	fi
	
	if [[ "$CXR_RUN_POST_DAILY" == true ]]
	then
		active_hashes="${active_hashes} ${CXR_ACTIVE_DAILY_POST_HASH}"
	fi
	
	if [[ "$CXR_RUN_POST_ONCE" == true ]]
	then
		active_hashes="${active_hashes} ${CXR_ACTIVE_ONCE_POST_HASH}"
	fi
	
	# Loop through the module types in order
	for active_hash in $active_hashes
	do
		# Get all active modules of the current type
		oIFS="$IFS"
		keyString="$(common.hash.getKeys $active_hash $CXR_HASH_TYPE_GLOBAL)"
		IFS="$CXR_DELIMITER"
		# Turn string into array (we cannot call <common.hash.getKeys> directly here!)
		activeModuleKeys=( $keyString )
		# Reset Internal Field separator
		IFS="$oIFS"
		
		active_modules=""
		
		# Re-determine module type
		case $active_hash in
			${CXR_ACTIVE_ONCE_PRE_HASH}) 		module_type="${CXR_TYPE_PREPROCESS_ONCE}";;
			${CXR_ACTIVE_DAILY_PRE_HASH}) 	module_type="${CXR_TYPE_PREPROCESS_DAILY}";; 
			${CXR_ACTIVE_MODEL_HASH}) 			module_type="${CXR_TYPE_MODEL}";;
			${CXR_ACTIVE_DAILY_POST_HASH}) 	module_type="${CXR_TYPE_POSTPROCESS_DAILY}";;
			${CXR_ACTIVE_ONCE_POST_HASH}) 	module_type="${CXR_TYPE_POSTPROCESS_ONCE}";;
		esac
		
		# Loop through all active modules of this type
		for iKey in $( seq 0 $(( ${#activeModuleKeys[@]} - 1)) )
		do
			module="${activeModuleKeys[$iKey]}"

			# Get the raw dependencies
			raw_dependencies="$(common.module.getRawDependencies $module)"
			
			main.log -v "$module depedends on ${raw_dependencies:--}"
			
			# The number of invocations is not dependent on the day
			nInvocations=$(common.module.getNumInvocations "$module")
		
			# Loop through days
			for day_offset in $(seq 0 $((${CXR_NUMBER_OF_SIM_DAYS} -1 )) )
			do
				# Give some visual feedback
				common.user.showProgress

				# resolve the dependencies
				resolved_dependencies="$(common.module.resolveAllDependencies "$raw_dependencies" $day_offset )"
				
				for iInvocation in $(seq 1 $nInvocations )
				do
					# Are there any?
					if [[ "$resolved_dependencies" ]]
					then
						# Loop 
						for dependency in $resolved_dependencies
						do
							echo "${dependency} $(common.parallel.formatDependency "$module" "$module_type" "$day_offset" "$iInvocation" "$nInvocations")" >> "$output_file"
						done # Dependencies
					else
						# Add the module twice (see header), including all invocations
						dep_string="$(common.parallel.formatDependency "$module" "$module_type" "$day_offset" "$iInvocation" "$nInvocations")"
						echo $dep_string $dep_string >> "$output_file"
					fi
				done # invocations
				
			done # days
				
		done # current active modules

	done # hashes of active modules
	
	main.log -v "Removing duplicates..."
	tempfile="$(common.runner.createTempFile $FUNCNAME)"
	
	sort "$output_file" | uniq > "$tempfile"
	mv "$tempfile" "$output_file"
}

################################################################################
# Function: common.parallel.drawDependencyGraph
# 
# Creates an image of the dependency graphy using dot (graphviz)
# 
# Parameters:
# $1 - a file describing the dependencies in tsort format
# [$2] - an output file (extension must be any suported Graphviz filetype like pdf, ps, svg) 
# see also <http://www.graphviz.org/doc/info/output.html>
################################################################################
function common.parallel.drawDependencyGraph()
################################################################################
{
	local input_file
	local output_file
	local dot_file
	local elements
	
	# Extract the filetype (lowercase)
	local extension
	
	input_file="$1"
	output_file="${2:-$CXR_RUN_DIR/${CXR_RUN}_dep_$(date +"%Y_%m_%d_%H_%M").pdf}"
	dot_file=$(common.runner.createTempFile $FUNCNAME)
	extension="$(common.string.toLower "${output_file##*.}")"
	
	echo "digraph dependencies" > "$dot_file"
	echo "{" >> "$dot_file"
	
	# Now go through each entry of the file, the form is
	# independent_mod dependent_mod
	# if the two names are the same, ignore them
	# always exchange the order.
	# Dot has issues with the @ sign, we replace it by i for invocation
	while read line
	do
		# IFS is ok with space
		elements=($line)
		
		# Replace @
		indep=${elements[0]//@/_i}
		dep=${elements[1]//@/_i}
		
		if [[ $indep != $dep ]]
		then
			echo "    ${dep} -> ${indep} ;" >> "$dot_file"
		else
			main.log -v  "$indep equals $dep"
		fi
	
	done < "${input_file}"
	
	echo "}" >> "$dot_file"
	
	# Now call dot
	${CXR_DOT_EXEC} -T${extension} "${dot_file}" -o "${output_file}" 2>&1 | tee -a $CXR_LOG
	
	if [[ $(common.array.allElementsZero? "${PIPESTATUS[@]}") == false ]]
	then
		main.log -e  "Could not visualize the dependencies."
	else	
		main.log -a  "You find a visualisation of the modules dependencies in the file ${output_file}"
	fi
}

################################################################################
# Function: common.parallel.countAllTasks
#
# Returns the number of tasks known.
# 
#
################################################################################
function common.parallel.countAllTasks()
################################################################################
{
	# Find all entries in the table
	task_count="$(${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "SELECT COUNT(*) FROM tasks")"
	
	main.log -v "Found $task_count tasks in total"
	
	echo "$task_count"
}


################################################################################
# Function: common.parallel.countOpenTasks
#
# Returns the number of open tasks. 
# Make sure you call this in a critical section (lock acquired), otherwise 
# a race condition might occur
# 
#
################################################################################
function common.parallel.countOpenTasks()
################################################################################
{
	# Find only "TODO" entries
	task_count="$(${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "SELECT COUNT(*) FROM tasks WHERE STATUS='${CXR_STATE_TODO}'")"
	
	main.log -v "Found $task_count open tasks"
	
	echo "$task_count"
}

################################################################################
# Function: common.parallel.detectLockup
#
# Tests if all workers of a run are in a waiting state. This means that some dependency
# is not fullfilled but has not failed, so all Worker will have to wait forever
# (or until they waited CXR_DEPENDECY_TIMEOUT_SEC seconds).
# Since it is possible that this happens be coincidence, we keep a counter in
# a hash that we increase when all workers are idle and decrease when they are not.
# If a threshold is reached, we stop the run.
#
# Variables:
# CXR_MAX_LOCKUP_COUNT - the maximal number of consecutive idling allowed. 
#
# Hashes:
# Lockup (Global)
#
################################################################################
function common.parallel.detectLockup()
################################################################################
{
	local count
	local numRunning
	
	common.hash.has? Lockup $CXR_HASH_TYPE_GLOBAL LockupCount
	if [[ $_has == true ]]
	then
		count=$_value
	else
		count=0
	fi
	
	# Count the running workers
	numRunning="$(${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "SELECT COUNT(*) FROM workers WHERE STATUS='${CXR_STATE_RUNNING}'")"
	
	if [[ $numRunning -gt 0 ]]
	then
		# OK, at least one is running, decrease if above 0
		if [[ $count -gt 0 ]]
		then
			count=$(( $count - 1 ))
		fi
	else
		# Too bad, they are all waiting, increase
		count=$(( $count + 1 ))
	fi
	
	if [[ $count -gt ${CXR_MAX_LOCKUP_COUNT:-10} ]]
	then
		main.dieGracefully "It seems that all workers of this run wait for a dependency to be resolved - we will stop now!"
	fi
	
	# Store new count
	common.hash.put Lockup $CXR_HASH_TYPE_GLOBAL LockupCount $count
}


################################################################################
# Function: common.parallel.setNextTask
#
# Returns the id of the next task to execute and all its data in environment vars.
# Even though sqlite does locking, we protect this critical function with a lock.
# 
# If there are no more tasks, the empty string is returned.
# If all tasks are executed, deletes the continue file.
#
# We set these _vars:
#
# Output variables:
# _id
# _exclusive
# _module_name
# _day_offset
# _invocation
#
################################################################################
function common.parallel.setNextTask()
################################################################################
{
	# Acquire lock
	if [[ $(common.runner.getLock NextTask "$CXR_HASH_TYPE_INSTANCE") == false ]]
	then
		main.dieGracefully "Waiting for NextTask lock took too long"
	fi
	
	local task_count
	local potential_task_data
	
	task_count=$(common.parallel.countOpenTasks)

	# Are there open tasks at all?
	if [[ "$task_count" -eq 0 ]]
	then
		main.log  "All tasks have been processed, notifying system after security pause..."
		
		# there are no more tasks, remove all continue files after some waiting
		# The waiting should ensure that all tasks are past their check for do_we_continue
		sleep $CXR_WAITING_SLEEP_SECONDS
		
		common.state.deleteContinueFiles
		common.runner.releaseLock NextTask "$CXR_HASH_TYPE_INSTANCE"
		echo ""
		return $CXR_RET_OK
		
	else
		main.log -v "There are $task_count unfinished tasks - we choose the top one."
	fi
	
	# get first relevant entry in the DB
	potential_task_data="$(${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "SELECT id,module_name,module_type,exclusive,day_offset,invocation FROM tasks WHERE STATUS='${CXR_STATE_TODO}' ORDER BY id ASC LIMIT 1")"
	
	# Check status
	if [[ $? -ne 0 ]]
	then
		main.dieGracefully "could not find next task!"
	fi
	
	# we might not get a string
	if [[ -z "$potential_task_data" ]]
	then
		# No task!
		main.dieGracefully "could not find next task!"
	else
		# We got a task
		# parse
		
		oIFS="$IFS"
		IFS="$CXR_DELIMITER"
		set $potential_task_data
		IFS="$oIFS"
		
		_id="$1"
		_module_name="$2"
		_module_type="$3"
		_exclusive="$4"
		_day_offset="$5"
		_invocation="$6"
		
		# Assign it by an update
		${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "UPDATE tasks set  STATUS='${CXR_STATE_RUNNING}' WHERE id=$id"
		
		main.log -v "New task has id $id"
	fi
	
	# Release lock
	common.runner.releaseLock NextTask "$CXR_HASH_TYPE_INSTANCE"
}

################################################################################
# Function: common.parallel.changeTaskStatus
#
# Just updates the task db.
# As a precaution, we also notify the state DB on error (all modules should do this!)
#
# Parameters:
# $1 - id of task
# $2 - status (SUCCESS/FAILURE)
################################################################################
function common.parallel.changeTaskStatus()
################################################################################
{
	local id
	local status
	
	if [[ $# -ne 2 ]]
	then
		main.dieGracefully "needs a task descriptor and a status as input"
	fi
	
	id="$1"
	status="$2"
	
	main.log -v "Changing status of $id to $status"
	
	case $status in
	
		$CXR_STATUS_SUCCESS|$CXR_STATUS_FAILURE) 
			${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "UPDATE tasks set status='${status}' WHERE id=$id"
			;;

		*)
			main.dieGracefully "status $status not supported!"
	
	esac
}

################################################################################
# Function: common.parallel.waitingWorker
#
# Udates the status of a worker to waiting
#
# Parameters:
# $1 - pid of common.parallel.Worker
################################################################################
function common.parallel.waitingWorker()
################################################################################
{
	if [[ $# -ne 1  ]]
	then
		main.dieGracefully "needs a pid as input"
	fi
	
	local pid
	pid=$1
	 
	${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "UPDATE workers set status='${CXR_STATE_WAITING}' WHERE pid=$pid AND hostname='$CXR_MACHINE'"
	
	main.log -v   "common.parallel.Worker (pid: $pid) changed its state to waiting"
}

################################################################################
# Function: common.parallel.runningWorker
#
# Udates the status of a worker to running
#
# Parameters:
# $1 - pid of common.parallel.Worker
################################################################################
function common.parallel.runningWorker()
################################################################################
{
	if [[ $# -ne 1  ]]
	then
		main.dieGracefully "needs a pid as input"
	fi
	
	local pid
	pid=$1
	 
	${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "UPDATE workers set status='${CXR_STATE_RUNNING}' WHERE pid=$pid AND hostname='$CXR_MACHINE'"
	
	main.log -v   "common.parallel.Worker (pid: $pid) changed its state to running"
}


################################################################################
# Function: common.parallel.removeWorker
#
# kills the common.parallel.Worker of the given task_pid and alse removes it from the process list.
# 
# Parameters:
# $1 - the workers pid
################################################################################
function common.parallel.removeWorker()
################################################################################
{
	if [[ $# -ne 1 ]]
	then
		main.dieGracefully "needs a task_pid as input"
	fi
	
	local pid
	
	pid=$1
	
	# Kill the process
	kill $pid 2>/dev/null
	
	# Remove from DB
	${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "DELETE FROM workers WHERE pid=$pid AND hostname='$CXR_MACHINE'"
}

################################################################################
# Function: common.parallel.Worker
#
# This function is the workhorse of the parallel CAMxRunner. The Runner spawns one 
# or more of this functions to operate on the existing tasks.
# This can even be done from more than one machine.
#
# TODO: a worker that finishes must restore a consistent state, that is the current
# task must be "put back"
#
# The worker gets a new task via <common.parallel.setNextTask>
# then waits (using <common.module.areDependenciesOk?>)
# until the dependencies of this task are fullfilled. 
#
# Parameters:
# $1 - the worker id (internal number, just to tell log output on screen apart)
################################################################################
function common.parallel.Worker()
################################################################################
{
	# The ID is global
	CXR_WORKER_ID=${1}
	
	local tmp
	local task_pid
	local new_task_descriptor
	local new_task
	local oIFS
	local descriptor
	local task
	local exclusive
	local raw_dependencies
	local invocation
	local module_name
	local day_offset
	local start_epoch
	
	#Getting the pid is not easy, we do not want to create unnecessary processes...
	tmp=$(common.runner.createTempFile $FUNCNAME)
	
	# The pid is the parent of the awk process
	# and the 4th field of /proc/self/stat is the Parent PID
	awk '{print $4}' /proc/self/stat > $tmp
	# We add the machine name so that it is unique among all machines
	pid=$(cat $tmp)
	
	# Insert this worker
	${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "INSERT OR REPLACE workers (pid, hostname,status,epoch_m) VALUES ($pid,'$CXR_MACHINE','$CXR_STATE_WAITING',$(date "+%s"))"
	
	main.log -a -B  "parallel worker (pid ${pid}, id ${CXR_WORKER_ID} ) starts on $CXR_MACHINE..."

	# Do we have more than 1 process?
	# If so, define process-specific stuff
	if [[ -f "$CXR_LOG" && "$CXR_MAX_PARALLEL_PROCS" -gt 1 ]]
	then
		# Set task_pid-dependent logfile to disentangle things
		CXR_LOG=${CXR_LOG%.log}_${CXR_MACHINE}_${pid}.log
		
		main.log -a "This common.parallel.Worker will use its own logfile: ${CXR_LOG}"
	fi

	# We stay in this loop as long as the continue file exists
	while [[ -f "$CXR_CONTINUE_FILE" ]]
	do
		# Do we stop here?
		common.state.doContinue? || main.dieGracefully "Continue file no longer present."
		
		# We are not yet busy
		common.parallel.waitingWorker $pid
		
		# Is there enough free memory?
		if [[ "$(common.performance.getMemFreePercent)" -gt ${CXR_MEM_FREE_PERCENT:-0} ]]
		then
			# Enough Memory
			
			# common.parallel.setNextTask provides tasks in an atomic fashion
			# already moves the task descriptor into "running" position
			# Sets a couple of "background" variables
			# This is a blocking call (we wait until we get a task)
			common.parallel.setNextTask
			
			id=$_id
			
			# The task id might be empty due to errors
			if [[ "$id" ]]
			then
				main.log -v "New task received: $id"
				
				######################
				# task was already parsed by common.parallel.setNextTask
				######################
				
				module_name="$_module_name"
				day_offset="$_day_offset"
				invocation="$_invocation"
				exclusive="$_exclusive"
				
				main.log -v "module: $module_name day_offset: $day_offset invocation: $invocation"
				
				if [[ "$exclusive" == true ]]
				then
					# If exclusive, try to get lock
					if [[ $(common.runner.getLock Exclusive "$CXR_HASH_TYPE_GLOBAL") == false ]]
					then
						main.dieGracefully "There seeems to be another exclusive task running that takes too long."
					fi
				else
					# If not, just check if it is set
					common.runner.waitForLock Exclusive "$CXR_HASH_TYPE_GLOBAL"
					
					if [[ $_retval == false ]]
					then
						main.dieGracefully "There seeems to be another exclusive task running that takes too long."
					fi
				fi
				
				
				if [[ "$(common.hash.has? $CXR_MODULE_PATH_HASH $CXR_HASH_TYPE_UNIVERSAL $module_name true)" == true ]]
				then
					module_path="$(common.hash.get $CXR_MODULE_PATH_HASH $CXR_HASH_TYPE_UNIVERSAL $module_name true)"
				else
					main.dieGracefully "cannot find path of $module_name"
				fi
				
				raw_dependencies="$(common.module.getRawDependencies $module_name)"
				
				start_epoch=$CXR_EPOCH
				
				# We need to wait until all dependencies are ok
				until [[ "$(common.module.areDependenciesOk? "$raw_dependencies" "$day_offset" )" == true ]]
				do
					main.log -v "Waiting for dependencies of $module_name to be done for day $day_offset"
					
					# Tell the system we wait, then sleep
					common.parallel.waitingWorker $task_pid
					sleep $CXR_WAITING_SLEEP_SECONDS
					
					if [[ $(( $(date "+%s") - $start_epoch )) -gt $CXR_DEPENDECY_TIMEOUT_SEC ]]
					then
						main.dieGracefully "It took longer than CXR_DEPENDECY_TIMEOUT_SEC ($CXR_DEPENDECY_TIMEOUT_SEC) seconds to fullfill the dependencies of $module_name for day $day_offset"
					fi
				done
				
				# Time to work
				common.parallel.runningWorker $task_pid
				
				main.log -v "module: $module_name day_offset: $day_offset invocation: $invocation exclusive: $_exclusive"
				
				# Setup environment
				common.date.setVars "$CXR_START_DATE" "${day_offset:-0}"
				
				main.log -a -B "common.parallel.Worker $task_pid assigned to $module_name for $CXR_DATE"
				
				# Before loading a new module, remove old meta variables
				unset ${!CXR_META_MODULE*}
				
				# Export the module name
				CXR_META_MODULE_NAME=${module_name}
				
				# source the file to get the rest of the metadata
				source $module_path
				
				# Start Timing 
				common.performance.startTiming $CXR_META_MODULE_NAME
				
				# Now start the work.
				# The function we use is the Module name
				# We use the return status to determine if it was successful
				
				# we pass the invocation as argument
				# most modules simply ignore this.
				# If invocation is unset, we pass 1
				$CXR_META_MODULE_NAME ${invocation:-1} \
				&& common.parallel.changeTaskStatus $new_task_descriptor $CXR_STATUS_SUCCESS \
				|| common.parallel.changeTaskStatus $new_task_descriptor $CXR_STATUS_FAILURE
							
				# Stop Timing 
				common.performance.stopTiming $CXR_META_MODULE_NAME
				
				# There is a potential race-condition here...
				# It is not critical, since we use this only for ETA estimations
				CXR_TASKS_DONE=$(( $CXR_TASKS_DONE + 1 ))
	
				#Release resources if needed
				if [[ "$_exclusive" == true ]]
				then
					main.log  "Activating the assignment of new tasks again."
					common.runner.releaseLock Exclusive "$CXR_HASH_TYPE_GLOBAL"
				fi
			else
				main.log -v  "Worker $pid did not receive an assignment - maybe there are too many workers around"
				
				# This means that someone wants exclusive access
				# Tell the system we wait, then sleep
				common.parallel.waitingWorker $task_pid
				sleep $CXR_WAITING_SLEEP_SECONDS
				
			fi # Got a task?
		
		else
			# Not enough memory
			main.log -w "Worker $task_pid detected that we have less than ${CXR_MEM_FREE_PERCENT} % of free memory.\nReaLoad: $(common.performance.getReaLoadPercent) %. We wait..."
			
			# Tell the system we wait, then sleep
			common.parallel.waitingWorker $pid
			sleep $CXR_WAITING_SLEEP_SECONDS
		fi # Enough Memory?
			
	done
	
	# We have done our duty
	common.parallel.removeWorker $pid

	exit $CXR_RET_OK
}

################################################################################
# Function: common.parallel.spawnWorkers
#
# Parameters:
# $1 - number of workers to spawn
################################################################################
function common.parallel.spawnWorkers()
################################################################################
{
	local iWorker
	
	# The control thread is "Worker 0"
	CXR_WORKER_ID=0
	
	main.log  "We now create $1 worker threads"
	
	for iWorker in $(seq 1 $1)
	do
		# Create a worker and send it to background
		common.parallel.Worker $iWorker &
		
		# Wait a bit to avoid congestion
		main.log -a "We wait 60 seconds until we launch the next worker to see the memory demand"
		sleep 60
	done
}

################################################################################
# Function: common.parallel.removeAllWorkers
# 
# Removes all workers
# 
################################################################################
function common.parallel.removeAllWorkers()
################################################################################
{
	main.log  "We remove all workers on $CXR_MACHINE."
	
	for pid in $(${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" "SELECT pid FROM workers WHERE hostname='$CXR_MACHINE'")
	do
		common.parallel.removeWorker "$pid"
	done
}

################################################################################
# Function: common.parallel.cleanTasks
#
# Deletes the Task DB file.
#
#
################################################################################
function common.parallel.cleanTasks()
################################################################################
{
	main.log -v "Removing DB file ${CXR_TASK_DB_FILE}..."
	
	rm -f "${CXR_TASK_DB_FILE}"
}
################################################################################
# Function: common.parallel.waitForWorkers
#
# Basically a sleep function: we loop and check if the continue file is there.
#
################################################################################
function common.parallel.waitForWorkers()
################################################################################
{
		main.log  "Entering a wait loop (the work is carried out by background processes. I check every $CXR_WAITING_SLEEP_SECONDS seconds if all is done.)"
		
		while [ -f "$CXR_CONTINUE_FILE" ]
		do
			sleep $CXR_WAITING_SLEEP_SECONDS
			common.state.reportEta
		done
		
		main.log -B   "The Continue file is gone, all workers will stop asap."
		
		# OK, remove the workers now
		common.parallel.removeAllWorkers
}

################################################################################
# Function: common.parallel.init
# 
# Creates a sqlite database containing the tasks we need to execute.
# Tasks that already finished successfully are not added.
# Unless we allow multiple CAMxRunner instances and we are not the master, 
# we recreate the task infrastructure every run. 
# 
# Hashes:
# CXR_MODULE_PATH_HASH ($CXR_HASH_TYPE_UNIVERSAL) - maps module names to their path
# DBs:
# CXR_TASK_DB_FILE
################################################################################
function common.parallel.init()
################################################################################
{
	local running_tasks
	local running_task
	local task_id
	local tasksTodo
	local task
	local taskCount
	local task_file
	local line
	local module_name
	local day_offset
	local invocation
	local module_type
	local raw_date
	local my_stage
	local dep_file
	local sorted_file
	
	main.log -a "Initializing parallel subsystem, might take a while, depending on number of tasks...\n"
	
	# Reset the ID counter
	local current_id
	local task_file
	
	current_id=1
	
	# Init
	CXR_TIME_TOTAL_ESTIMATED=0
	
	# Check if we already have tasks 
	# Iff we have this and allow multiple, we use them.
	taskCount=$(common.parallel.countAllTasks)
	
	if [[	$taskCount -ne 0 && \
			${CXR_ALLOW_MULTIPLE} == true && \
			"$(common.state.countInstances)" -gt 1 ]]
	then
		# We are in a non-master multiple runner
		main.log -a -b "There is already a tasklist - we will use it.\nIf you want to start from scratch, delete all state info using\n ${CXR_CALL} -c\n"
	else
		# Redo everything
		
		# Delete contents, if any
		common.parallel.cleanTasks
		
		## Create the task db uisng a here-document
		${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" <<-EOT
		-- Get exclusive access
		PRAGMA main.locking_mode=EXCLUSIVE; 
		
		-- Drop tables
		DROP TABLE IF EXISTS tasks;
		DROP TABLE IF EXISTS workers;
		
		-- Table for tasks
		CREATE TABLE IF NOT EXISTS tasks 
		(id,
		module_name,
		module_type,
		exclusive,
		day_offset,
		invocation,
		status,
		epoch_m);
		
		-- Table for workers
		CREATE TABLE IF NOT EXISTS workers
		(pid,
		hostname,
		status,
		current_task,
		epoch_m);
		
		PRAGMA main.locking_mode=NORMAL; 
		
		EOT
		
		# Some tempfiles we need
		dep_file="$(common.runner.createTempFile dependencies)"
		sorted_file="$(common.runner.createTempFile tsort-out)"
		mixed_file="$(common.runner.createTempFile mixed_tasks)"
		
		main.log -a "\nCreating the list of dependencies...\n"
		
		main.log -a $(date +%T)
		common.parallel.createDependencyList "$dep_file"
		main.log -a $(date +%T)
		
		main.log -a  "\nOrdering tasks...\n"
		${CXR_TSORT_EXEC} "$dep_file" > "$sorted_file"
		
		if [[ $? -ne 0 ]]
		then
			main.dieGracefully "I could not figure out the correct order to execute the tasks. Most probably there is a cycle (Module A depends on B which in turn depends on A)"
		fi
		
		main.log -a -B "We will execute the tasks in this order:"
		cat "$sorted_file" | tee -a "$CXR_LOG" 
		
		main.log -a "\nFilling task DB $CXR_TASK_DB_FILE...\n"
		
		while read line 
		do
			# Visual feedback
			common.user.showProgress
			
			# each line contains something like "create_emissions0@1" or "initial_conditions"
			
			# We need to parse the line
			# this sets a couple of _variables
			common.module.parseIdentifier "$line"

			module_type="$(common.module.getType "$_module_name")"
			exclusive="$(common.module.getExclusive "$_module_name")"
			
			# Convert date
			raw_date="$(common.date.toRaw $(common.date.OffsetToDate "${_day_offset:-0}"))"
			my_stage="$(common.state.getStageName "$module_type" "$_module_name" "$raw_date" "$_invocation" )"
			
			# Is this known to have worked?
			if [[ "$(common.state.hasFinished? "$my_stage")" == false ]]
			then
				# estimate the runtime and add to total
				CXR_TIME_TOTAL_ESTIMATED=$(common.math.FloatOperation "$CXR_TIME_TOTAL_ESTIMATED + $(common.performance.estimateRuntime $_module_name)" -1 false)
				
				# we put this information into the DB
				${CXR_SQLITE_EXEC} "$CXR_TASK_DB_FILE" <<-EOT
				INSERT INTO tasks 
				(id,
				module_name,
				module_type,
				exclusive,
				day_offset,
				invocation,
				status,
				epoch_m)
				VALUES
				(
				 $current_id,
				'$_module_name',
				'$module_type',
				'$exclusive',
				${_day_offset:-0},
				${_invocation:-NULL},
				'TODO',
				$(date "+%s")
				);
				EOT
				
				# Increase ID
				current_id=$(( $current_id + 1 ))
				
			else
				main.log -v "Task $my_stage already finished."
			fi
		
		done < "$sorted_file"
		
		# Set the total number of tasks
		CXR_TASKS_TOTAL=$(( $current_id -1 ))
		CXR_TASKS_DONE=0
		
		main.log -v  "This run consists of $CXR_TASKS_TOTAL tasks."
		
		# pdf_file=$CXR_RUN_DIR/${CXR_RUN}_dep_$(date +"%Y_%m_%d_%H_%M").pdf
		# common.parallel.drawDependencyGraph "$dep_file" "$pdf_file"

	fi # Multiple mode?
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

	common.parallel.init
	
	########################################
	# Tests. If the number changes, change CXR_META_MODULE_NUM_TESTS
	########################################
	
	is "$(common.parallel.formatDependency test ${CXR_TYPE_MODEL} 1 2 12)" "test1@2" "common.parallel.formatDependency normal"
	is "$(common.parallel.formatDependency test ${CXR_TYPE_MODEL} 1 2 1)" "test1" "common.parallel.formatDependency only one invocation in total"
	is "$(common.parallel.formatDependency test ${CXR_TYPE_MODEL} "" "" "")" "test" "common.parallel.formatDependency empty parameters"
	
	########################################
	# teardown tests if needed
	########################################
	
}