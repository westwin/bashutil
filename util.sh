#!/bin/bash
#util functions

SVC_USER="wibapp"

#print INFO level log.
function info() {
    echo "[INFO]  [$(date '+%F-%T')] $1"
}

#print as an separator
function banner() {
    info " ------------------------------------------------------------------------"
    info " ------------------------------------------------------------------------"
    info "$1"
}

#print error msg in red to stderr.
function err(){
    echo -e "\e[31m[ERROR] [$(date '+%F-%T')] $@\e[0m" 1>&2
}

# print error msg and exit with status code 1
function fail-exit() {
  err "$1"
  exit 1
}

#print warning msg in BLUE to stdout.
function warn(){
    echo -e "\e[34m[WARN]  [$(date '+%F-%T')] $@\e[0m" 1>&2
}

#important reminder in red.
function reminder(){
    info " ------------------------------------------------------------------------"
    info " ------------------------------------------------------------------------"
    echo -e "\e[31m[IMPORTANT] [$(date '+%F-%T')] $@\e[0m"
}

#===  FUNCTION  ================================================================
#          NAME:  whoami-check
#   DESCRIPTION: check if current user is expected, usually to check if it is $SVC_USER.
#                If not, try to call the usage() then exit 1
#    PARAMETERS: [expected_user] , by default, it's $SVC_USER
#       RETURNS: 1 
#===============================================================================
function whoami-check ()
{
  local expected_user="${1:-$SVC_USER}"
  if [[ "$(whoami)" != "${expected_user}" ]]; then
    err "Please run with user of ${expected_user}."
    type usage >/dev/null 2>&1
    if [[ "$?" -eq 0 ]]; then
      usage
    fi
    exit 1
  fi
}    # ----------  end of function whoami-check  ----------

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# From http://serverfault.com/questions/177699/how-can-i-execute-a-bash-function-with-sudo/177764
# EXESUDO
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#
# Purpose:
# -------------------------------------------------------------------- #
# Execute a function with sudo
#
# Params:
# -------------------------------------------------------------------- #
# $1:   string: name of the function to be executed with sudo
#
# Usage:
# -------------------------------------------------------------------- #
# exesudo "funcname" followed by any param
#
# -------------------------------------------------------------------- #
# Created 01 September 2012              Last Modified 02 September 2012

function exesudo () {
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    #
    # LOCAL VARIABLES:
    #
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
 
    #
    # I use underscores to remember it's been passed
    local _funcname_="$1"
 
    local params=( "$@" )               ## array containing all params passed here
    local tmpfile="/dev/shm/$RANDOM"    ## temporary file
    local filecontent                   ## content of the temporary file
    local regex                         ## regular expression
    local func                          ## function source
 
 
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    #
    # MAIN CODE:
    #
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
 
    #
    # WORKING ON PARAMS:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
    #
    # Shift the first param (which is the name of the function)
    unset params[0]              ## remove first element
    # params=( "${params[@]}" )     ## repack array
 
 
    #
    # WORKING ON THE TEMPORARY FILE:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
    content="#!/bin/bash\n\n"
 
    #
    # Write the params array
    content="${content}params=(\n"
                                
    regex="\s+"
    for param in "${params[@]}"; do
        if [[ "$param" =~ $regex ]]; then
            content="${content}\t\"${param}\"\n"
        else
            content="${content}\t${param}\n"
        fi
    done
                                
    content="$content)\n"
    echo -e "$content" > "$tmpfile"
 
    #
    # Append the function source
    echo "#$( type "$_funcname_" )" >> "$tmpfile"
 
    #
    # Append the call to the function
    echo -e "\n$_funcname_ \"\${params[@]}\"\n" >> "$tmpfile"
 
 
    #
    # DONE: EXECUTE THE TEMPORARY FILE WITH SUDO
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    sudo bash "$tmpfile"
    rm "$tmpfile"
}

#how many cpu(s)
function cpu_number ()
{
  cat /proc/cpuinfo | grep processor | wc -l
}    # ----------  end of function cpu_number  ----------
