#!/bin/bash
#
##    baksync
##    Author/Founder    - Shawn Miller (seaphor@woodbeeco.com)
##    Colaborators      -
##    Date              - 2019 03 29
##    Description       - Bakup local files to NFS share/s in a cron job
##    Example crontab   - 1 */4 * * * /home/myuser/bin/baksync.sh
#
###########################################
####    Global Variables
###########################################
#
PROGNAME=$(basename $0)
PROGVERS="0.1.2-01"
PROGDATE="30 Mar 2019"
#
###########################################
####    Environmental Variables
###########################################
#
fdate="$(date +%Y-%m-%d_%H:%M:%S)"
logfil="bakup_rsync.log"
logdir="${HOME}/logging/rsyncs"
baklog="${logdir}/${logfil}"
#
###########################################
####    Execution
###########################################
#
[[ -d $logdir ]] || mkdir -p $logdir
if [[ "`mount | grep nfs`" == "" ]]; then
    sudo mount -a
    if [[ "`mount | grep nfs`" == "" ]]; then
        echo "$fdate - FAIL - can not mount NFS Share" >> $baklog
	exit 1
    else
        echo -e "\n${fdate} - Bakup Started" >> $baklog
        rsync -arv ${HOME}/.Per/. ${HOME}/nfs/myuser/.Per/. >> $baklog 2>&1
        rsync -arv ${HOME}/Documents/. ${HOME}/nfs/myuser/bak-Documents/. >> $baklog 2>&1
	rsync -arv ${HOME}/rpmbuild/. ${HOME}/nfs/myuser/bak-rpmbuild/. >> $baklog 2>&1
        echo "$fdate - Bakup Complete" >> $baklog
    fi
else
    echo -e "\n${fdate} - Bakup Started" >> $baklog
    rsync -arv ${HOME}/.Per/. ${HOME}/nfs/myuser/.Per/. >> $baklog 2>&1
    rsync -arv ${HOME}/Documents/. ${HOME}/nfs/myuser/bak-Documents/. >> $baklog 2>&1
    rsync -arv ${HOME}/rpmbuild/. ${HOME}/nfs/myuser/bak-rpmbuild/. >> $baklog 2>&1
    echo "$fdate - Bakup Complete" >> $baklog
fi
#
###########################################
####    LOGGING Data
###########################################
#
####    Mutable Variables
declare -i tarkeep=5
declare -i tarsize=10
logloc=/${logdir}
####    Non-Mutable Variables
ldate="$(date +%Y-%m-%d_%H-%M-%S)"
tarmax=$(du -s ${baklog} | awk '{print $1}')
tarname=${ldate}-${logfil}.tar.gz
declare -i tarcount=$(ls -1 ${logdir}/*.tar.gz | wc -l)
[[ ${tarmax} -ge ${tarsize} ]] && tardo=true || tardo=false
taroldst=$(ls -1rt ${logdir}/*.tar.gz | head -n 1)
####    Execution & Rotation
if ${tardo}; then
    echo "$fdate - Log Rotation Initiated" >> $baklog
    tar -czvf ${logdir}/${tarname} -C ${logdir}/ ${logfil}
    > ${baklog}
    echo "$fdate - Log Rotated- New Log" >> $baklog
fi
while [[ ${tarcount} -ge ${tarkeep} ]]; do
    rm -f ${taroldst}
done
#
exit 0

