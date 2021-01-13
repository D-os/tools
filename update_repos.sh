#!/bin/bash
set -e

[ $# -lt 1 ] && { echo "Usage: `basename $0` android_branch" >&2; exit 1; }

ANDROID_BRANCH=$1
echo Will update repos to $ANDROID_BRANCH \( https://source.android.com/setup/start/build-numbers.html#source-code-tags-and-builds \)
echo


BASE=`dirname $0`
BASE=`readlink -f $BASE`
cd $BASE

function update_repo() {
	REPO=$1
	DIR=$2
	DEST=$3
	cd $BASE
	echo : $REPO $DIR $DEST
	[ -d $REPO ] || { echo "No such directory: $BASE/$REPO" >&2; exit 2; }
	cd $REPO
	git fetch
	git clean -fxd
	git checkout --quiet --progress tags/$ANDROID_BRANCH
	[ -n "$DIR" ] && git filter-branch --force --prune-empty --subdirectory-filter $DIR HEAD
	git push $DEST HEAD:refs/tags/$ANDROID_BRANCH
}

update_repo system-core base git@github.com:D-os/base.git
update_repo system-core libcutils git@github.com:D-os/libcutils.git
update_repo system-core libutils git@github.com:D-os/libutils.git
update_repo frameworks-native libs/binder git@github.com:D-os/libbinder.git
update_repo frameworks-native libs/binderthreadstate git@github.com:D-os/libbinderthreadstate.git
update_repo frameworks-native cmds git@github.com:D-os/cmds.git
update_repo system-tools-aidl '' git@github.com:D-os/aidl.git
update_repo system-tools-hidl '' git@github.com:D-os/hidl.git

echo Now:
echo git fetch -t
echo git rebase -i $ANDROID_BRANCH
