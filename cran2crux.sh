#!/bin/bash
#
# cran2crux: Write CRUX ports for R modules from CRAN and Bioconductor
#
# Written by Petar Petrov, slackalaxy at gmail dot com
#

# Exit if something fails:
# -e: exit immediately if any command fails
# -u: treat unset variables as an error
# -o pipefail: pipelines fail if any command in the pipe fails
set -euo pipefail

PWD="$(pwd)"
DIRNAM="$(basename "$PWD")"

# Check where cran2crux is executed from
DRIVER_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Default installation dir for R scripts
INST_DIR="/usr/lib/cran2crux"

# Default configuration dir
ETC_DIR="/etc"

# Set path to RDS tmp files, specific for the user
RDS_PATH="/tmp/cran2crux-$(whoami)/"

# Command line arguments
arg_a="${1:-}"
arg_b="${2:-}"
arg_c="${3:-}"

# Display error message, following R's style...
error_message() {
	local MESSAGE="${1:-Unknown error}"
	echo "Error: ${MESSAGE}" >&2
	echo "Execution halted" >&2
	exit 1
}

# Path to R scripts; check if they exist in the same dir as cran2crux.sh
# (useful when testing the script), then check install location.
if [[ -f "$DRIVER_DIR/repos2db.R" && \
      -f "$DRIVER_DIR/old2new.R" && \
      -f "$DRIVER_DIR/cran2pkgfile.R" ]]; then
	echo "=== NOTE : Using cran2crux R scripts from "$DRIVER_DIR"!"
	R_SCRIPT_PATH="$DRIVER_DIR"
elif [[ -f "$INST_DIR/repos2db.R" && \
        -f "$INST_DIR/old2new.R" && \
        -f "$INST_DIR/cran2pkgfile.R" ]]; then
        R_SCRIPT_PATH="$INST_DIR"
else
	error_message "cran2crux R scripts not found"
fi

# Path to conf file; check if it exists in the same dir as cran2crux.sh
# (useful when testing the script), then check install location.
if [[ -f "$DRIVER_DIR/cran2crux.conf" ]]; then
	echo "=== NOTE : Using cran2crux.conf file from "$DRIVER_DIR"!"
	CONF_FILE="$DRIVER_DIR/cran2crux.conf"
elif [[ -f "$ETC_DIR/cran2crux.conf" ]]; then
        CONF_FILE="$ETC_DIR/cran2crux.conf"
else
	error_message "cran2crux.conf not found"
fi

help_menu() {
	echo "cran2crux - Create CRUX ports for R-packages"
	echo ""
	echo "Usage: cran2crux R-package [-r/-ro] <depth> OR cran2crux [-so/-u]"
	echo "[options]:"
	echo "  -r,   --recursive      generate ports for dependencies, recursively"
	echo "  -ro,  --recursive-opt  include ports for optional dependencies"
	echo "  -so,  --show-old       show outdated packages"
	echo "  -u,   --update         generate updated ports for outdated packages"
	echo "  -h,   --help           show this help"
	echo "<depth>:"
	echo "  integer >= 2           depth of the -r/-ro search (optional)"
}

# generic permissions check
perm_check() {
	local CHECK="${1}"
	
	# folder not readable	
	if [[ ! -r "$CHECK" ]]; then
		error_message "$CHECK is not readable"
	fi
	
	# folder not writeable
	if [[ ! -w "$CHECK" ]]; then
		error_message "$CHECK is not writable"
	fi
}

# check RDS folder and files permissions without syncing
rds_check() {
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
pwd_check() {
	perm_check "$PWD"
	if [[ -d "$PWD" ]] && [[ -n $(ls -A "$PWD" 2>/dev/null) ]]; then
		error_message "Folder '$DIRNAM' is not empty. Use a clean one to generate ports"
	fi	
}

# sync with upstream
repo_sync() {
	mkdir -p "$RDS_PATH"
	Rscript "$R_SCRIPT_PATH/repos2db.R" "$RDS_PATH" "$CONF_FILE"
}

# pkgfile_write arguments check ($arg_a, $arg_b, $arg_c)
pkgfile_args_check() {
	local module="${1:-}"
	local option="${2:-}"
	local depth="${3:-}"
	
	# module name starts with a dash
	if [[ "${module:0:1}" = "-" ]]; then
		error_message "Invalid R-package name or option '${module}'"
	fi

	# second option is invalid
	if [[ -n "$option" ]] && [[ "$option" != "-r" ]] && [[ "$option" != "-ro" ]] && [[ "$option" != "--recursive" ]] && [[ "$option" != "--recursive-opt" ]]; then
		error_message "Invalid option for creating port '${option}'"
	fi
    	
    	# is depth valid? try use it as a number
	if [[ -n "$depth" ]]; then	
    		if ! (( depth > 1 )) 2>/dev/null; then
    			error_message "Invalid integer '${depth}' (must be >= 2)"
    		fi
	fi
}

# Write Pkgfile
pkgfile_write() {
	local module="${1:-}"
	local option="${2:-}"
	local depth="${3:-}"
	
	
	# if no dependencies depth is specified, use "5" as default depth value
	if [[ -z "$depth" ]]; then
		depth="5"
	fi
	
	Rscript "$R_SCRIPT_PATH/cran2pkgfile.R" "$module" "$option" "$depth" "$RDS_PATH" "$CONF_FILE"
}

# exit if no R-package specified, printing help
if [[ "$arg_a" = "" ]]; then
	help_menu
	exit 0
fi

# print help
if [[ "$arg_a" = "-h" ]] || [[ "$arg_a" = "--help" ]]; then
	help_menu
	exit 0
fi

if [[ "$arg_b" = "-h" ]] || [[ "$arg_b" = "--help" ]]; then
	help_menu
	exit 0
fi

rds_check

# Check for updates of installed modules and exit
if [[ "$arg_a" = "-so" ]] || [[ "$arg_a" = "--show-old" ]]; then
	repo_sync
	Rscript "$R_SCRIPT_PATH/old2new.R" "$RDS_PATH" "$CONF_FILE"
	exit 0
fi

# Generate updated ports for installed modules
if [[ "$arg_a" = "-u" ]] || [[ "$arg_a" = "--update" ]]; then
	pwd_check
	repo_sync
	
	declare -a new_array=( $(Rscript "$R_SCRIPT_PATH/old2new.R" "$RDS_PATH" "$CONF_FILE" | sed '1d' | awk '{print $2}') )
	
	if [[ ${#new_array[@]} -eq 0 ]]; then
		echo "All packages are up to date."
		exit 0
	fi
	
	for module in "${new_array[@]}"; do
		pkgfile_write "$module" "" ""
	done
	exit 0
fi

# If we made it till here, just run the R script to generate port(s)
pkgfile_args_check "$arg_a" "$arg_b" "$arg_c"
pwd_check
repo_sync
pkgfile_write "$arg_a" "$arg_b" "$arg_c"
