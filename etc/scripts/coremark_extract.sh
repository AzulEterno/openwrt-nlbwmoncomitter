# Created Date: Mo Jul 2023
# Author: Azuroso
# -----
# Last Modified: Mon Jul 10 2023
# Modified By: Azuroso
# -----
# Copyright (c) 2023 Azuroso
# -----
# HISTORY:
# Date      	By	Comments
# ----------	---	---------------------------------------------------------

# Get Core mark Scores and store it in json

is_debuging=0

if [[ $is_debuging ]] ; then
    core_markoutput=`cat /etc/scripts/test_input.txt`
else
    core_markoutput=$1
fi

grep -Eo " : ([0-9]+\.[0-9]+) /" $1 | grep -Eo "([0-9]+\.[0-9]+)"