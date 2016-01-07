#!/bin/bash
#
# Aipo is a groupware program developed by TOWN, Inc.
# Copyright (C) 2004-2016 TOWN, Inc.
# http://www.aipo.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

cd `dirname $0` || exit 1

. ./func.conf
. ../conf/jre.conf
. ../conf/tomcat.conf
. ../conf/postgresql.conf
. ../conf/aipo.conf

export JRE_HOME=$JAVA_HOME
export CATALINA_OPTS=$CATALINA_OPTS

echo "Aipo のリストアを開始します。"

function listfunc {
	unset count
	for DIR in $*
	do
		count=`expr $count + 1`
		echo "[$count] `expr substr $DIR 1 4`年`expr substr $DIR 5 2`月`expr substr $DIR 7 2`日`expr substr $DIR 9 2`時`expr substr $DIR 11 2`分"
	done
	echo "[0] キャンセル"
	echo "バックアップファイルを選んで番号を入力してください。"
	read select
	if [ $select = "0" ]; then
		echoError "リストアはキャンセルされました。"
		exit 1
	fi


	let str=`echo $* | cut -f $select -d " " `
	if [ `expr length "$str"` -le 0 ]; then
		listfunc $list
	fi
}

echoRestoreError() {
    echoError "Aipo のリストアに失敗しました。";
    echoError "$1";
    echo "Tomcat を開始しています。"
    sh $TOMCAT_HOME/bin/startup.sh > $TOMCAT_HOME/logs/startup.log 2>&1
}

cd $AIPO_HOME/backup
list=`ls | grep ............[0-9]`
if [ `expr length "$list"` -le 0 ]; then
	echoError "バックアップファイルが見つかりません。"
	exit 1
fi

listfunc $list
bg_dir=$str

vsnc=$AIPO_VERSION
isCR=`expr match $vsnc .*[0-9]$ `
if [ "$isCR" = "0" ]; then
    len=`expr length $vsnc`
    len=`expr $len - 1`
    vsn=`expr substr $vsnc 1 $len`
fi

tmp_str=`grep "=" "$AIPO_HOME/backup/$bg_dir/version.txt"`
vsn=`echo "$tmp_str" | cut -f 2 -d "=" - `
isCR=`expr match $vsn .*[0-9]$ `
if [ "$isCR" = "0" ]; then
    len=`expr length $vsn`
    len=`expr $len - 1`
    vsn=`expr substr $vsn 1 $len`
fi

echo "Version $vsn"
if [ $vsn !=  $vsnc ]; then
	echoError "バックアップファイルのバージョンが一致しません。"
	exit 1
fi

echo "Tomcat を停止しています。"
sh $TOMCAT_HOME/bin/shutdown.sh > $TOMCAT_HOME/logs/shutdown.log 2>&1
wait

echo "Aipo をリストアしています。"
sudo -u ${POSTGRES_USER} $POSTGRES_HOME/bin/pg_restore -Fc -c -U $POSTGRES_USER -p $POSTGRES_PORT $AIPO_HOME/backup/$bg_dir/aipo_db.dump -d org001 > $TOMCAT_HOME/logs/restore.log 2>&1 || { echoRestoreError "データベースリストア中にエラーが発生しました。"; exit 1; }

rm -rf $TOMCAT_HOME/data/*
cp -rf $AIPO_HOME/backup/$bg_dir/files $TOMCAT_HOME/data/ || { echoRestoreError "データコピー中にエラーが発生しました。"; exit 1; }
cp -rf $AIPO_HOME/backup/$bg_dir/mail $TOMCAT_HOME/data/ || { echoRestoreError "データコピー中にエラーが発生しました。"; exit 1; }

echo "Tomcat を開始しています。"
sh $TOMCAT_HOME/bin/startup.sh > $TOMCAT_HOME/logs/startup.log 2>&1

echoInfo "Aipo のリストアが完了しました。"
