#!/bin/bash
#util functions

#print INFO level log.
function info() {
    echo [INFO] "$1"
}

#print as an separator
function banner() {
    info " ------------------------------------------------------------------------"
    info " ------------------------------------------------------------------------"
    info "$1"
}

#print error msg in red.
function err(){
    echo -e "\e[31m[ERROR] $@\e[0m"
}

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
