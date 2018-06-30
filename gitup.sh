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
for i in $HGITDIR ; do echo "$HROOTDIR $i" >> $LOGFIL ; cd $HROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "Script Auto Run" ; git pull origin master ; git push origin master; done
}
#
function git_lab
{
for i in $LGITDIR ; do echo "$LROOTDIR $i" >> $LOGFIL ; cd $LROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "Script Auto Run" ; git pull origin master ; git push origin master; done
}
#
function ogit_lab
{
for i in $OGITDIR ; do echo "$OROOTDIR $i" >> $LOGFIL ; cd $OROOTDIR/$i/ ; git checkout master ; git add * ; git commit -a -m "Script Auto Run" ; git pull origin master ; git push origin master; done
}
#
function git_sync
{
for i in $LGITDIR ; do rsync -arv --exclude='.git' $LROOTDIR/$i/* $HROOTDIR/$i/. ; rsync -arv --exclude='.git' $LROOTDIR/$i/* $OROOTDIR/$i/. ; git_hub ; ogit_lab ; done
}
echo -e "\n $SYNCDAT DATE OF SYNC\n" >> $LOGFIL
git_lab 2>&1 >> $LOGFIL
git_sync 2>&1 >> $LOGFIL
echo -e "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=\n" >> $LOGFIL
exit $?
