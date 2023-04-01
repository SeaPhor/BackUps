#!/bin/bash

####    Global Variables
progname=$(basename $0)
#
####    Path Variables
gitdir=/home/wbc/Documents/bak-Documents
dndir=/home/wbc/repos/DND-BOOKS
writdir=/home/wbc/repos/writing2
logdir=${HOME}/gitlogs
logfil=$logdir/$fildate.push.log
[[ -d $logdir ]] || mkdir -p $logdir
#
####    Time & Date Variables
intdate="$(date +%d\ %b\ %Y)"
fildate="$(date +%Y.%b.%d_%H.%M)"
timdate="$(date +%H:%M)"
#
####    Functions
gitup () {
    git pull origin master
    git add -A
    git commit -a -m "nightly commit and push $intdate"
    git push origin master
}
##############################
####    Execution
##############################
#
####    Begin Logging
echo -e "$intdate - Starting $progname" > $logfil
echo -e $timdate >> $logfil
#
####    Begin Git Pull/Push
for i in $gitdir $dndir $writdir
do
    echo -e "\n$i" | tee -a $logfil
    cd $i
    gitup | tee -a $logfil
done
#
####    Begin Log Rotation
if [[ $(ls -1 $logdir | wc -l) -ge "15" ]]; then
    cd $logdir
    find . -mtime +15 -exec rm {} \;
    echo "$fildate clean-up logs older than 15 days" >> clean-up.log
fi
#
####    Exit Cleanly
exit $0
#
