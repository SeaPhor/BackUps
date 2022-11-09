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
progname=$(basename $0)
relver="1.0.4-02"
reldate="09-Nov-2022"
SSHID=false
YELLOW=`tput setaf 3`
CYAN=`tput setaf 6`
LTYLLW=`tput setaf 11`   
LTCYN=`tput setaf 14`  
LTRED=`tput setaf 9`
GRN="$(tput setaf 2)"
LTGRN="$(tput setaf 10)"
BOLD=`tput bold`
RESET=`tput sgr0`

##########################################################
####    Start here rewrite
##########################################################
help_opts () {
    cat <<EOT

$YELLOW This script$RESET$LTRED REQUIRES$RESET$YELLOW 1 parameter- Unless you Hard-Code your VM-Name
$RESET$CYAN $progname vmname$YELLOW
    Optional- Can also take a snapshot prior to the backup.
$BOLD$LTCYN
Options:$RESET$LTCYN
[<vmname>]           Name of your VM to backup- Example:$LTGRN
                     $progname my-vm$LTCYN
[<vmname>] [snap]    Create snapshot - Will create the backup and a snapshot- Example:$LTGRN
                     $progname my-vm snap$LTCYN
[help]               Shows this output
$RESET
EOT
}
[[ $(echo $1) == "help" ]] && { help_opts; exit 0; }
[[ $(echo $2) != "snap" ]] && snap=false || snap=true
#
tmplog=/tmp/vmbak.baktmp
rdate=`date +%Y-%m-%d-%H:%M`
fdate=`date +%Y-%m-%d-%H-%M`
edate=`date +%Y-%m-%d-%H-%M`
bakdir="${HOME}/vmbaks"
logfile="${bakdir}/vmbaks.log"
[[ ! -d $bakdir ]] && { mkdir $bakdir; touch $logfile; }
list_vms=$(VBoxManage list vms)
list_runvms=$(VBoxManage list runningvms)
[[ ! $1 ]] && { echo " Requires 1 argument- vm-name from one of $list_vms ..."; exit 1; }
vmtarg=$1
if [[ $(grep $vmtarg $list_vms) == "" ]]; then
    echo "$vmtarg is NOT one of your VMs! Must be one of the following: "
    echo $list_vms
    exit 1
fi
#
stopcmd="$(VBoxManage controlvm $vmtarg acpipowerbutton)"
startcmd="$(VBoxManage startvm $vmtarg --type headless)"
snapcmd="$(VBoxManage snapshot $vmtarg take $vmtarg-$fdate)"
backcmd="$(VBoxManage export $vmtarg -o $vmtarg-$fdate.ova)"
#  First run check
#
##########################################################
####    Execution
##########################################################
#
###    Check Backups Number/Remove Set at 6 for this script
cd $bakdir
i="$(ls $bakdir | grep ova | wc -l)"
while [ $i -ge 6 ]
do
    ls -1tr $bakdir | grep .ova | head -n1 | xargs rm -rf
    i=$[$i-1]
done
#
#  Start Logging
echo -e "\n$rdate" >> $logfile
#
##########################################################
####    Snapshot
##########################################################
if [[ $snap ]]; then
    $snapcmd
fi
##########################################################
####    BackUp
##########################################################
#  Shutdown VM
chk_running () {
declare -i count=1
declare -i xtimes=6
untill (( count == xtimes )); do
    if [[ $(echo $list_runvms | grep $vmtarg) != "" ]]; then
        sleep 30
        ((++count))
    else
        declare -i count=6
    fi
done
}
if [[ $(echo $list_runvms | grep $vmtarg) != "" ]]; then
    $stopcmd
    sleep 30
    chk_running
fi
####    Need to test the while- remove if/then/else condition
if [[ $(echo $list_runvms | grep $vmtarg) != "" ]]; then
        echo "There is a problem shutting down the VM $vmtarg... exiting" 2>&1 >> $logfile
        exit 1
else
#  Start Export && Restart VM
    cd $bakdir
    VBoxManage export $vmtarg -o $vmtarg-$FDATE.ova 2>&1 >> $logfile && echo $rdate >> $logfile
    sleep 30
fi
#  Start VM
cd
VBoxManage startvm $vmtarg --type headless 2>&1 >> $logfile
echo -e "$edate\n" >> $logfile
exit $?
####  NOTES- Concept- need to make the backups ready for automation
####    Release 1.0.4-02 09-Nov-2022
####    added until loop for runningvms check

####    Release 1.0.4-01 09-Nov-2022
####    Added snapshot option and execution
####    Converted all CAP'd vars to lowercase
####    Removed all ssh and leveraged the VBoxManage actions

# grep -A 10 NOTES vboxvm-backup.sh | sed 's/####  //g'
