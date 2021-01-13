#!/bin/bash
set -e
### This tool splits Android repositories to separate libraries.
### It will checkout given Android release tag, filter-out specific directory
### and then push library to separate repository tag, to rebase code over.
### For available Android branches see:
### https://source.android.com/setup/start/build-numbers.html#source-code-tags-and-builds

[ $# -lt 1 ] && { echo -e "Usage: `basename $0` android_branch\n" >&2; sed -n '/^### /s/^### //p' "$0" >&2; exit 1; }

ANDROID_BRANCH=$1
echo Will update repos to $ANDROID_BRANCH
echo


BASE=`dirname $0`
BASE=`readlink -f $BASE`
cd $BASE

function check_repo() {
	REPO=$1
	SRC=$2
	if [ -d $REPO ]; then
		[ -d $REPO/.git ] || { echo "Not a git repository: $BASE/$REPO" >&2; exit 2; }
	else
		git clone $SRC $REPO
	fi
}

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

check_repo system-core https://android.googlesource.com/platform/system/core
check_repo frameworks-native https://android.googlesource.com/platform/frameworks/native
check_repo system-tools-aidl https://android.googlesource.com/platform/system/tools/aidl
check_repo system-tools-hidl https://android.googlesource.com/platform/system/tools/hidl

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
