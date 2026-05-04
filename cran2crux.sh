#!/bin/bash
#
# cran2crux: Write CRUX ports for R modules from CRAN
#
# Written by Petar Petrov, slackalaxy at gmail dot com
#

if [ ! -d "$(pwd)" ] ; then
	echo "=====> ERROR: current dir does not exist."
	exit 1
fi

# path to R scripts; export, because it's called from functions
R_SCRIPT_PATH="/usr/lib/cran2crux"
export R_SCRIPT_PATH

# path to RDS tmp files, specific for the user
RDS_PATH="/tmp/cran2crux-$(whoami)/"
export RDS_PATH

# what command line arguments mean
module="$1"
option="$2"
depth="$3"

PWD=$(pwd)
DIRNAM=$(basename $PWD)
export PWD
export DIRNAM


help_menu(){
	echo "usage: $(basename $0) Module [options] <dependencies depth>"
	echo ""
	echo "[options]:"
	echo "  -r,   --recursive        create ports for dependencies, recursively"
	echo "  -ro,  --recursive-opt    create ports for optional dependencies, too"
	echo "  -so,  --show-old         check for updates of installed modules"
	echo "  -u,   --update           generate updated ports for outdated modules"
	echo "  -h,   --help             print help and exit"
	echo ""
	echo "<dependencies depth>:"
	echo "   integer > 0             set higher (>10) if dependencies list is large"
}

# generic permissions check
perm_check(){
	local CHECK="${1}"
	
	# folder not readable	
	if [[ ! -r "$CHECK" ]]; then
		echo "=====> ERROR: $CHECK is not readable."
		exit 1
	fi
	
	# folder not writeable
	if [[ ! -w "$CHECK" ]]; then
		echo "=====> ERROR: $CHECK is not writable."
		exit 1
	fi
}

# check RDS folder and files permissions without syncing
rds_check(){
	# folder exists, just check
	if [[ -d "$RDS_PATH" ]]; then
		perm_check "$RDS_PATH"
	fi
	
	# file(s) exist, just check
	if [[ -f "$RDS_PATH/old.rds" ]]; then
		perm_check "$RDS_PATH/old.rds"
	fi
	
	if [[ -f "$RDS_PATH/pkgsdb.rds" ]]; then
		perm_check "$RDS_PATH/pkgsdb.rds"
	fi
}

# check current work dir
pwd_check(){

	perm_check $PWD

	if [ ! -z "$(ls -A $PWD)" ]; then
		echo "=====> ERROR: $DIRNAM is not empty. Use a clean one to generate ports."
		exit 1
	fi	
}

# sync with upstream
repo_sync(){
	mkdir -p $RDS_PATH
	Rscript $R_SCRIPT_PATH/repos2db.R "$RDS_PATH"
}

# exit if no module specified, printing help
if [[ "$1" = "" ]]; then
	echo "===== 'Module' not specified!"
	help_menu
	exit 0
fi

# print help
if [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]; then
	help_menu
	exit 0
fi

if [[ "$2" = "-h" ]] || [[ "$2" = "--help" ]]; then
	help_menu
	exit 0
fi

rds_check

# Check for updates of installed modules and exit
if [[ "$1" = "-so" ]] || [[ "$1" = "--show-old" ]]; then
	repo_sync
	Rscript $R_SCRIPT_PATH/old2new.R "$RDS_PATH"
	exit 0
fi

# Generate updated ports for installed modules
if [[ "$1" = "-u" ]] || [[ "$1" = "--update" ]]; then
	pwd_check
	repo_sync
	declare -a new_array=( $( Rscript $R_SCRIPT_PATH/old2new.R "$RDS_PATH" | sed '1d' | awk '{print $2}' | tr '\n' ' ' ) )
	
	if [ ${#new_array[@]} -eq 0 ]; then
		echo "All packages are up to date."
		exit 0
	fi
	
	option=""
	depth=""
	
	for module in ${new_array[@]}; do
		Rscript $R_SCRIPT_PATH/cran2pkgfile.R "$module" "$option" "$depth" "$RDS_PATH"
	done
	exit 0
fi

# module name starts with a dash
if [ "${1:0:1}" = "-" ]; then
	echo "=====> ERROR: invalid module name $1"
	exit 1
fi

# second option is invalid
if [[ ! -z "$2" ]] && [[ "$2" != "-r" ]] && [[ "$2" != "-ro" ]] && [[ "$2" != "--recursive" ]] && [[ "$2" != "--recursive-opt" ]]; then
	echo "=====> ERROR: invalid option $2"
	exit 1
fi

# dependencies depth is invalid
if [[ ! -z "$3" ]] && [[ ! "$3" -gt 0 ]]; then
	echo "=====> ERROR: invalid integer $3"
	exit 1
fi

# if no dependencies depth is specified, use "5" as default depth value
if [[ -z "$3" ]]; then
	depth="5"
fi

# run the R script
pwd_check
repo_sync
Rscript $R_SCRIPT_PATH/cran2pkgfile.R "$module" "$option" "$depth" "$RDS_PATH"
