#!/usr/bin/env bash
#
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAG=`tput setaf 5`
CYAN=`tput setaf 6`
LTRED=`tput setaf 9`
LTGRN=`tput setaf 10`
LTYLLW=`tput setaf 11`
LTBLU=`tput setaf 12`
LTMAG=`tput setaf 13`
LTCYN=`tput setaf 14`
#
BGBLU=`tput setab 4`
BGYLLW=`tput setab 3`
BGLYLLW=`tput setab 11`
#
ULINE=`tput smul`
NULINE=`tput rmul`
BOLD=`tput bold`
RESET=`tput sgr0`
#
usage_opts () {
	cat <<END
${LTCYN}#
##$BOLD$YELLOW   Description-$RESET$LTCYN
##    I started out having only one git remote repo, local network,
##        then I got a github account and maintained both, and when
##        MS aquired github, I installed GitLab Server locally, and
##        opened a Gitlab.com account and was maintaining all 4 repos.
##    This script is designed to manage and sync multiple GIT 
##        repositories and from multiple sources, i.e. github, gitlab,
##         and local/network remote repos.
##    It is based on the Idea that you want to edit code in 1 (ONE)
##        repo, sync those changes to all your local repos, and then
##        add/commit/pull/push all of them to the remote 'origin/s'
##    It will perform the following functions-
##    *   Log all output to a logfile, and rotate them depending
##            on size and number, with timestamps in the log and
##            on the tar backup filenames.
##    *   Perform a add/commit/pull/push on the ONE working local repo
##    *   Sync the ONE working local repo with all other local repos
##    *   Perform a add/commit/pull/push on all the other local repos
##$BOLD$YELLOW    Usage-$RESETLTCYN
##$LTYLLW    Modify this scripts variable path/s to your local git repo directory/s
##    To bypass the user/pass prompt, modify your .git/configs as such-
##$BOLD$LTCYN        url$RESET$LTCYN = https://${LTYLLW}User:PassWord${LTCYN}@github.com/repopath/repo.git$LTCYN
##    Run the script with$BOLD$LTYLLW no${LTCYN}$RESET$LTCYN options to perform all tasks without user input.
##    Run the script with$BOLD [${LTYLLW}help${LTCYN}]${RESET}${LTCYN} option to show this info and exit.
##    Run the script with$BOLD [${LTYLLW}ask${LTCYN}]${RESET}${LTCYN} option to input the commit message manually.
#
##$CYAN    seaphor@woodbeeco.com  $LTCYN
##$GREEN    SeaPhor on GitLab  https://gitlab.com/SeaPhor-Repos$LTCYN
##$RED    SeaPhor on GitHub  https://github.com/SeaPhor$LTCYN
##$LTRED    SeaPhor on Youtube$LTCYN
##$MAG    SeaPhor on IRC, #seaphor on Freenode Server$LTCYN
##$BOLD$LTMAG    SeaPhor$BLUE /$LTRED C4$RESET$LTCYN
#$RESET
END
}
	#USER=<username> #Un-Comment this line and replace PATH and <username> with actual if you need to specify a different PATH and user, OR, change the PATH value for the next line [HOMEDIR]
	HOMEDIR="${HOME}/MyGitRepos/home"
	LOGDIR="$HOMEDIR/logs"
	LOGFIL="$LOGDIR/syncrepos.log"
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
    tar -czvf $LOGDAT-syncrepos.log.tar.gz syncrepos.log >> $LOGFIL 2>&1
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
	HGITDIR="Puppet-Modules SeaPhor-Scripts suma-channel-mgr_5 TipsAndTricks BackUps"
	LGITDIR="Puppet-Modules SeaPhor-Scripts suma-channel-mgr_5 TipsAndTricks BackUps"
	OGITDIR="Puppet-Modules SeaPhor-Scripts suma-channel-mgr_5 TipsAndTricks BackUps"
if [[ "`echo $1`" == "ask" ]]; then
	echo -e "\nType your commit statement...\n"
	read ASKME
else
	ASKME="Script Auto Run"
fi
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
for i in $HGITDIR ; do rsync -arv --exclude='.git' --delete $HROOTDIR/$i/* $LROOTDIR/$i/. ; rsync -arv --exclude='.git' --delete $HROOTDIR/$i/* $OROOTDIR/$i/. ; ogit_lab ; done
#for i in $HGITDIR ; do rsync -arv --exclude='.git' --delete $HROOTDIR/$i/* $LROOTDIR/$i/. ; rsync -arv --exclude='.git' --delete $HROOTDIR/$i/* $OROOTDIR/$i/. ; git_lab ; ogit_lab ; done
}
case $1 in 
	help)
		usage_opts
		exit 0
		;;
	*)
		echo -e "\n $SYNCDAT DATE OF SYNC\n" >> $LOGFIL
		git_hub >> $LOGFIL 2>&1
		git_sync >> $LOGFIL 2>&1
		echo -e "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=\n" >> $LOGFIL
		;;
esac
exit $?
