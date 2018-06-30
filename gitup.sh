#!/bin/bash
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
for i in $HGITDIR ; do cd $HROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "Script Auto Run" ; git pull origin master ; git push origin master; done
}
#
function git_lab
{
for i in $LGITDIR ; do cd $LROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "Script Auto Run" ; git pull origin master ; git push origin master; done
}
#
function ogit_lab
{
for i in $OGITDIR ; do cd $OROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "Script Auto Run" ; git pull origin master ; git push origin master; done
}
#
function git_sync
{
for i in $LGITDIR ; do rsync -arv --exclude='.git' $LROOTDIR/$i/* $HROOTDIR/$i/. ; rsync -arv --exclude='.git' $LROOTDIR/$i/* $OROOTDIR/$i/. ; git_hub ; ogit_lab ; done
}
echo -e "\n $SYNCDAT\n" >> $LOGFIL
git_lab 2>&1 >> $LOGFIL
git_sync 2>&1 >> $LOGFIL
echo -e "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=\n" >> $LOGFIL
exit $?
