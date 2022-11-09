#!/bin/bash
#  Variables and Logging 
PROGNAME=$(basename $0)
RELVER="0.0.1-03"
RELDATE="24-Mar-2018"
#
#
#  KEEP THIS LINE #8 !!! Check for rsa
if [[ ! -s ~/RSAKEYSDONE.txt ]]; then
    ######## DELMEAFTR
    printf "$LTRED $BOLD
    ######## 
    #  START OF DELETE 
    #  RUN AS YOUR USER - NOT AS ROOT 
    #  !!!! REQUIRES ROOT RSA PRIVATE KEY FROM YOUR USER'S ACCOUNT !!!! 
    #  WHEN YOU HAVE DONE AND TESTED '> ssh-copy-id root@host' 
    #  PERFORM THE 'echo...' STATEMENT BELOW WHEN SSH-COPY-ID ABOVE IS DONE 
    #  READ THE 'READ-THE-README.MD' 
    #  END OF DELETE 
    ########$RESET  
    \n" 
    tail -n 5 $0 
    exit $? 
fi
#
#
#
#  KEEP THIS LINE #28 !!! Check for rsa
#
#
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
OPS=`echo -e "you need to have 2 parameters- $PROGNAME vmname hostname"`
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
ssh -q -i ~/.ssh/id_rsa root@$VMHOST $STOPCMD 2>&1 >> $TMPLOG
sleep 60
#  Start Export && Restart VM
cd $BAKDIR
VBoxManage export $VMTARG -o $VMTARG-$FDATE.ova 2>&1 >> $TMPLOG && echo $RDATE >> $TMPLOG
cd
VBoxManage startvm $VMTARG --type headless 2>&1 >> $TMPLOG
ssh -q -i ~/.ssh/id_rsa root@$VMHOST uptime 2>&1 >> $TMPLOG
#  Compile and complete LogFile
cat $TMPLOG >> $LOGFILE
echo -e "$FDATE\n" >> $LOGFILE
#  Clean up /tmp and exit
rm /tmp/*.baktmp
exit $?
###  NOTES-
##    NEED- LogFile rotation/cleanup function
##    NEED- VM .ova cleanup function
#    To enable script after configuring and testing your user's rsa key for root at remote vm run the following on your script
#    ~> echo "#    RSAKEYSDONE" >> ~/RSAKEYSDONE.txt
#    You can delete the lines if you want, but any new revision's will have it...
#    ~> sed -i '8,28d' vboxvm-backup*.sh 
#    empty line
