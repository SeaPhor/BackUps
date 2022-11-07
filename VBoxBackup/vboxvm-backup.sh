#!/bin/bash
#
####    
####    Author Shawn Miller
####    Date 18 January 2021
####    Forked from old script requireing ssh and root
#
##########################################################
####    Variables and Logging 
##########################################################
PROGNAME=$(basename $0)
RELVER="1.0.3-01"
RELDATE="18-Jan-2021"
SSHID=false
YELLOW=`tput setaf 3`
CYAN=`tput setaf 6`
LTYLLW=`tput setaf 11`   
LTCYN=`tput setaf 14`  
LTRED=`tput setaf 9`
BOLD=`tput bold`
RESET=`tput sgr0`

##########################################################
####    Start here rewrite
##########################################################
help_opts () {
    cat <<EOT

$YELLOW This script$RESET$LTRED REQUIRES$RESET$YELLOW 1 parameter- Unless you Hard-Code your VM-Name
RESET$CYAN $PROGNAME vmname

Other:
[<vmname>]    Hard-Code variable 'vmtarg=' to avoid need for arg/s
[help]    Shows this output
[snap]    Create snapshot - optional arg to add note
[back]    Create Backup

EOT
}
[[ $(echo $1) == "help" ]] && { help_opts; exit 0; }
exit 0
#
tmplog=/tmp/vmbak.baktmp
rdate=`date +%Y-%m-%d-%H:%M`
fdate=`date +%Y-%m-%d-%H-%M`
edate=`date +%Y-%m-%d-%H-%M`
bakdir="${HOME}/vmbaks"
logfile="${bakdir}/vmbaks.log"
[[ ! -d $bakdir ]] && { mkdir $bakdir; touch $logfile; }
vmtarg="BLANKNONE"
if [[ $(echo $vmtarg) == "BLANKNONE" ]]; then
    read -p "${YELLOW}Please enter the${LTCYN} vm-name${YELLOW} to be used...
    to exit script without entering vmname type exit${RESET} " invmname
    [[ $invname == "exit" ]] && exit 0
    [[ $invname == "" ]] && exit 0
    sed -i "s/BLANKNONE/$invmname/g" $progname #### or use '$0'?
fi    ####    TEST THIS!
stopcmd="$(VBoxManage controlvm $vmtarg acpipowerbutton)"
startcmd="$(VBoxManage startvm $vmtarg --type headless)"
snapcmd="$(VBoxManage snapshot $vmtarg take $vmtarg-$fdate)"
backcmd="$(VBoxManage export $vmtarg -o $vmtarg-$fdate.ova)"
#  First run check
#
##########################################################
####    Stopped Here
##########################################################

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
