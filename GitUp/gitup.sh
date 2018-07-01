#!/bin/bash
#
if [[ "`echo $1`" == "help" ]]; then
	echo -e "
##    Description-
##    This script is designed to manage multiple GIT repositories
##        and from multiple sources, i.e. github, gitlab, and
##        local/network remote repos.
##    It is based on the Idea that you want to edit code in 1 (ONE)
##        repo, sync those changes to all your local repos, and then
##        add/commit/pull/push all of them to the remote 'origin/s'
##    It will perform the following functions-
##        Log all output to a logfile, and rotate them depending
##            on size and number, with timestamps in the log and
##            on the tar backup filenames.
##        Perform a add/commit/pull/push on the ONE working local repo
##        Sync the ONE working local repo with all other local repos
##        Perform a add/commit/pull/push on all the other local repos
##    Usage-
##    Modify the path/s to your local git repo directory/s
##    Run the script with no options to perform all tasks
##    Run the script with [help] option to show this info and exit.
"
	exit $?
else
	if [[ "`echo $1`" == "ask" ]]; then
		echo -e "\nType your commit statement...\n"
		read ASKME
	else
		ASKME="Script Auto Run"
	fi
fi
#
	#USER=<username> #Un-Comment this line and replace PATH and <username> with actual if you need to specify a different PATH and user, OR, change the PATH value for the next line [HOMEDIR]
	HOMEDIR=/home/$USER/MyGitRepos/home
	LOGDIR=$HOMEDIR/logs
	LOGFIL=$LOGDIR/syncrepos.log
	if [[ ! -d $LOGDIR ]]; then
		mkdir $LOGDIR
		touch $LOGFIL
	else
		if [[ ! -f $LOGFIL ]]; then
			touch $LOGFIL
		fi
	fi
	SYNCDAT=`date +%Y-%m-%d_%H:%M`
	LOGDAT=`date +%Y-%m-%d_%H.%M`
#
###    Check Log Size/Rotate
if [[ "`du -b $LOGFIL | awk '{print $1}'`" -ge "40960" ]]; then
    cd $LOGDIR
    tar -czvf $LOGDAT-syncrepos.log.tar.gz syncrepos.log
    > syncrepos.log
    cd
fi
#
###    Check Backups Number/Remove Set at 6 for this script
cd $LOGDIR
i="`ls $LOGDIR | grep 'tar.gz' | wc -l`"
while [ $i -ge 4 ]
do
ls -1tr $LOGDIR | grep tar.gz | head -n1 | xargs rm -rf
i=$[$i-1]
done
#
	#Change the values of the parent dirctory/s for your dirs
	HROOTDIR=$HOMEDIR/github
	OROOTDIR=$HOMEDIR/Ogitlab
	LROOTDIR=$HOMEDIR/gitlab
	#Change the values between the "quotes" with the repo/directory names for your repos
	HGITDIR="Puppet-Modules SeaPhor-Scripts suma-channel-mgr_5 TipsAndTricks"
	LGITDIR="Puppet-Modules SeaPhor-Scripts suma-channel-mgr_5 TipsAndTricks"
	OGITDIR="Puppet-Modules SeaPhor-Scripts suma-channel-mgr_5 TipsAndTricks"
function git_hub
{
for i in $HGITDIR ; do echo "$HROOTDIR $i" >> $LOGFIL ; cd $HROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "$ASKME" ; git pull origin master ; git push origin master; done
}
#
function git_lab
{
for i in $LGITDIR ; do echo "$LROOTDIR $i" >> $LOGFIL ; cd $LROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "$ASKME" ; git pull origin master ; git push origin master; done
}
#
function ogit_lab
{
for i in $OGITDIR ; do echo "$OROOTDIR $i" >> $LOGFIL ; cd $OROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "$ASKME" ; git pull origin master ; git push origin master; done
}
#
function git_sync
{
for i in $LGITDIR ; do rsync -arv --exclude='.git' --delete $LROOTDIR/$i/* $HROOTDIR/$i/. ; rsync -arv --exclude='.git' --delete $LROOTDIR/$i/* $OROOTDIR/$i/. ; git_hub ; ogit_lab ; done
}
echo -e "\n $SYNCDAT DATE OF SYNC\n" >> $LOGFIL
git_lab 2>&1 >> $LOGFIL
git_sync 2>&1 >> $LOGFIL
echo -e "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=\n" >> $LOGFIL
exit $?
