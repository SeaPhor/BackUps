#!/bin/bash
#  Variables and Logging 
PROGNAME=$(basename $0)
RELVER="1.2.1-01"
RELDATE="17-Jul-2020"
SSHID=false
YELLOW=`tput setaf 3`
CYAN=`tput setaf 6`
LTYLLW=`tput setaf 11`   
LTCYN=`tput setaf 14`  
LTRED=`tput setaf 9`
BOLD=`tput bold`
RESET=`tput sgr0`
OPTS="\n\t$YELLOW This script$RESET$LTRED REQUIRES$RESET$YELLOW 2 parameters-\n$RESET$CYAN $PROGNAME vmname hostname\n$RESET$LTYLLW  Optional$RESET$YELLOW 3rd parameter for storing VM backup\n  on a separate partition or remote NFS-\n$RESET$CYAN    $PROGNAME vmname hostname /path/to/directory [$RESET$LTCYN NO trailing /$RESET$CYAN ]\n$RESET$YELLOW    This script$RESET$LTRED REQUIRES$RESET$YELLOW using your$RESET$LTRED USER's$RESET$LTYLLW RSA-KEY$RESET$YELLOW pair to connect to the VM\n  as$RESET$LTRED ROOT$RESET$YELLOW to shut it down-\n$RESET$CYAN    ssh-gen-keygen && ssh-copy-id root@vmhostname$RESET$YELLOW => Input root password =>$RESET$CYAN ssh root@vmhostname$RESET$YELLOW to test.\n$RESET$LTYLLW    OR-\n$RESET$CYAN    ssh-gen-keygen && cat ~/.ssh/id_rsa.pub$RESET$YELLOW => HighLite all with NO whitespace and copy => ssh to vmhostname and become root =>$RESET$CYAN  vim ~/.ssh/authorized_keys$RESET$YELLOW  =>$RESET$LTCYN [o] to start insert-mode on a new line$RESET$YELLOW =>$RESET$LTCYN [SHIFT+INSERT] to Paste$RESET$YELLOW =>$RESET$LTCYN [ESC] to exit insert mode and [:wq] to save and quit$RESET$YELLOW =>$RESET$LTCYN [CTRL+d] log out.\n$RESET$YELLOW    Once that is tested you can do\n [$RESET$CYAN echo 'RSAKEYSDONE' >> ~/RSAKEYSDONE.txt$RESET$YELLOW ]\n$RESET "
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
    echo -e "\n\t Do you want this script to set this up for you? \n [y/N] (n)\n"
    read SETSSH
    if [[ "`echo $SETSSH`" == "y" ]]; then
        SSHID=true
    else
        exit $?
    fi
fi
#  KEEP THIS LINE #51 !!! Check for rsa
#
#
if $SSHID; then
    if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
        ssh-keygen
    else
        ssh-copy-id root@$2
    fi
    echo 'RSAKEYSDONE' >> ~/RSAKEYSDONE.txt
fi
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
EDATE=`date +%Y-%m-%d-%H-%M`
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
#
###    Check Log Size/Rotate
if [[ "`du -b $LOGFILE | awk '{print $1}'`" -ge "4096" ]]; then
    cd $BAKDIR
    tar -czvf $RDATE-VMLog.log VMLog.log
    > VMLog.log
    cd
fi
#
###    Check Backups Number/Remove Set at 6 for this script
cd $BAKDIR
i="`ls $BAKDIR | grep ova | wc -l`"
while [ $i -ge 6 ]
do
ls -1tr $BAKDIR | grep .ova | head -n1 | xargs rm -rf
i=$[$i-1]
done
#
#  Start Logging
echo -e "\n$RDATE" >> $LOGFILE
#  Shutdown VM
ssh -q -i ~/.ssh/id_rsa root@$VMHOST $STOPCMD 2>&1 >> $TMPLOG
sleep 60
#  Start Export && Restart VM
cd $BAKDIR
if ! ping -c 1 $2 > /dev/null 2>&1
    then
        VBoxManage export $VMTARG -o $VMTARG-$FDATE.ova 2>&1 >> $TMPLOG && echo $RDATE >> $TMPLOG
    else
        sleep 60
        if ! ping -c 1 $2 > /dev/null 2>&1
            then
                VBoxManage export $VMTARG -o $VMTARG-$FDATE.ova 2>&1 >> $TMPLOG && echo $RDATE >> $TMPLOG
            else
                echo -e "\n\t $2 Has NOT shutdown after 2 minutes!\n\t Aborting...\n" >> $TMPLOG
                echo -e "\n\t $2 Has NOT shutdown after 2 minutes!\n\t Aborting...\n"
                cat $TMPLOG >> $LOGFILE
                rm /tmp/*.baktmp
                exit $?
        fi
fi
cd
VBoxManage startvm $VMTARG --type headless 2>&1 >> $TMPLOG
ssh -q -i ~/.ssh/id_rsa root@$VMHOST uptime 2>&1 >> $TMPLOG
#  Compile and complete LogFile
cat $TMPLOG >> $LOGFILE
echo -e "$EDATE\n" >> $LOGFILE
#  Clean up /tmp and exit
rm /tmp/*.baktmp
exit $?
###  NOTES-
##    DONE- NEED- LogFile rotation/cleanup function
##    DONE- NEED- VM .ova cleanup function
#    To enable script after configuring and testing your user's rsa key for root at remote vm run the following ~> echo "RSAKEYSDONE" >> ~/RSAKEYSDONE.txt
#    You can delete the lines if you want, but any new revision's will have it...
#    ~> sed -i '26,51d' vboxvm-backup*.sh 
#    empty line
