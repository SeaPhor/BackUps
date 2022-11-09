#!/bin/bash
#  Variables and Logging 
TMPLOG=/tmp/vmbak.baktmp
BAKDIR=~/VMBackups
LOGFILE=~/VMBackups/VMLog.log
RDATE=`date +%Y-%m-%d-%H:%M`
FDATE=`date +%Y-%m-%d-%H-%M`
VMTARG=$1  # from VBoxManage list vms
VMHOST=$2  # hostname or IP-Address of OS 
# or
#VMTARG="vmname"  # from VBoxManage list vms
#VMHOST="hostname"  # hostname or IP-Address of OS 
STOPCMD="/sbin/shutdown -h now"
OPS="`printf 'you need to have 2 parameters- cmd vmname hostname'`"
LTRED=`tput setaf 9`
BOLD=`tput bold`
RESET=`tput sgr0`
#
#  Check command and parameter syntax
if [[ "`echo $1`" == "" ]]; then
    echo $OPS
    exit $?
else
    if [[ "`echo $2`" == "" ]]; then
        echo $OPS
        exit $?
    fi
fi
#  First run check
if [[ ! -d $BAKDIR ]]; then
    mkdir $BAKDIR
    touch $LOGFILE
fi
#  Set tmp log
touch $TMPLOG
#  Start Logging
echo -e "\n$RDATE" >> $LOGFILE
#  Shutdown VM
ssh -q root@$VMHOST $STOPCMD 2>&1 >> $TMPLOG
sleep 60
#  Start Export && Restart VM
cd $BAKDIR
VBoxManage export $VMTARG -o $VMTARG-$FDATE.ova 2>&1 >> $TMPLOG && echo $RDATE >> $TMPLOG
cd
VBoxManage startvm $VMTARG --type headless 2>&1 >> $TMPLOG
ssh -q root@$VMHOST uptime 2>&1 >> $TMPLOG
#  Compile and complete LogFile
cat $TMPLOG >> $LOGFILE
echo -e "$RDATE\n" >> $LOGFILE
#  Clean up /tmp and exit
rm /tmp/*.baktmp
exit $?
###  NOTES-
##    NEED- LogFile rotation/cleanup function
##    NEED- VM .ova cleanup function
#
