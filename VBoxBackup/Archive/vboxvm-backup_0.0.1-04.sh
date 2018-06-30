#!/bin/bash
#  Variables and Logging 
PROGNAME=$(basename $0)
RELVER="0.0.1-04"
RELDATE="24-Mar-2018"
#
YELLOW=`tput setaf 3`
CYAN=`tput setaf 6`
LTYLLW=`tput setaf 11`   
LTCYN=`tput setaf 14`  
LTRED=`tput setaf 9`
BOLD=`tput bold`
RESET=`tput sgr0`
OPTS="\n\t$YELLOW This script$RESET$LTRED REQUIRES$RESET$YELLOW 2 parameters-\n$RESET$CYAN $PROGNAME vmname hostname\n$RESET$LTYLLW  Optional$RESET$YELLOW 3rd parameter for storing VM backup\n  on a separate partition or remote NFS-\n$RESET$CYAN    $PROGNAME vmname hostname /path/to/directory [$RESET$LTCYN NO trailing /$RESET$CYAN ]\n$RESET$YELLOW    This script$RESET$LTRED REQUIRES$RESET$YELLOW using your$RESET$LTRED USER's$RESET$LTYLLW RSA-KEY$RESET$YELLOW pair to connect to the VM\n  as$RESET$LTRED ROOT$RESET$YELLOW to shut it down-\n$RESET$CYAN    ssh-gen-keygen && ssh-copy-id root@vmhostname$RESET$YELLOW => Input root password =>$RESET$CYAN ssh root@vmhostname$RESET$YELLOW to test.\n$RESET$LTYLLW    OR-\n$RESET$CYAN    ssh-gen-keygen && cat ~/.ssh/id_rsa.pub$RESET$YELLOW => HighLite all with NO whitespace and copy => ssh to vmhostname and become root =>$RESET$CYAN  vim ~/.ssh/authorized_keys$RESET$YELLOW  =>$RESET$LTCYN [o] to start insert-mode on a new line$RESET$YELLOW =>$RESET$LTCYN [SHIFT+INSERT] to Paste$RESET$YELLOW =>$RESET$LTCYN [:wq] to save and quit$RESET$YELLOW =>$RESET$LTCYN [CTRL+d] log out.\n$RESET$YELLOW    Once that is tested you can do [$RESET$CYAN echo 'RSAKEYSDONE' >> ~/RSAKEYSDONE.txt$RESET$YELLOW ]\n$RESET "
#  Check command and parameter syntax
if [[ "`echo $1`" == "" ]]; then
    echo -e $OPTS
    exit $?
else
    if [[ "`echo $2`" == "" ]]; then
        echo -e $OPTS
        exit $?
    fi
fi
#
#  KEEP THIS LINE #26 !!! Check for rsa
if [[ ! -s ~/RSAKEYSDONE.txt ]]; then
    ######## DELMEAFTR
    printf "$LTRED 
    ######## 
    #  
    #  RUN AS YOUR USER - NOT AS ROOT 
    #  !!!! REQUIRES ROOT RSA PRIVATE KEY FROM YOUR USER'S ACCOUNT !!!! 
    #  WHEN YOU HAVE DONE AND TESTED '> ssh-copy-id root@host' 
    #  PERFORM THE 'echo...' STATEMENT BELOW WHEN SSH-COPY-ID ABOVE IS DONE 
    #  READ THE 'READ-THE-README.MD' 
    #  
    ########$RESET  
    \n" 
    tail -n 5 $0 | grep 'RSAKEYSDONE'
    sleep 7
    echo -e $OPTS
    exit $? 
fi
#
#  KEEP THIS LINE #46 !!! Check for rsa
#
#
if [[ "`echo $3`" != "" ]]; then
    BAKDIR=$3/VMBackups
    LOGFILE=$BAKDIR/VMLog.log
else
    BAKDIR=~/VMBackups
    LOGFILE=~/VMBackups/VMLog.log
fi
TMPLOG=/tmp/vmbak.baktmp
RDATE=`date +%Y-%m-%d-%H:%M`
FDATE=`date +%Y-%m-%d-%H-%M`
VMTARG=$1  # from VBoxManage list vms
VMHOST=$2  # hostname or IP-Address of OS 
# or Hard-Code it yourself-
#VMTARG="vmname"  # from VBoxManage list vms
#VMHOST="hostname"  # hostname or IP-Address of OS 
STOPCMD="/sbin/shutdown -h now"
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
#    To enable script after configuring and testing your user's rsa key for root at remote vm run the following ~> echo "RSAKEYSDONE" >> ~/RSAKEYSDONE.txt
#    You can delete the lines if you want, but any new revision's will have it...
#    ~> sed -i '26,46d' vboxvm-backup*.sh 
#    empty line
